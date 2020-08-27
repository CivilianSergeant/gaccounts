import 'package:gaccounts/config/ApiUrl.dart';
import 'package:gaccounts/config/AppConfig.dart';
import 'package:gaccounts/persistance/entity/AccTrxDetails.dart';
import 'package:gaccounts/persistance/entity/AccTrxMaster.dart';
import 'package:gaccounts/persistance/entity/User.dart';
import 'package:gaccounts/persistance/repository/AccTrxMasterRepository.dart';
import 'package:gaccounts/persistance/repository/ChartAccountRepository.dart';
import 'package:gaccounts/persistance/repository/UserRepository.dart';
import 'package:gaccounts/persistance/services/AccTrxMasterService.dart';
import 'package:gaccounts/persistance/services/ChartAccountService.dart';
import 'package:gaccounts/persistance/services/UserService.dart';
import 'package:gaccounts/services/network.dart';
import 'dart:convert';

class SyncService extends NetworkService{

  Future<dynamic> syncData() async{
    if(! await checkNetwork()){
      return {'status':-2,'message':'Please Check internet available'};
    }
    ChartAccountService caService = ChartAccountService(repo: ChartAccountRepository());
    AccTrxMasterService accTrxMaster = AccTrxMasterService(masterRepo: AccTrxMasterRepository());
    UserService userService = UserService(userRepo: UserRepository());
    User user = await userService.checkCurrentUser();

    List<dynamic> vouchers = await accTrxMaster.getSyncableVouchers();
    AppConfig.log(vouchers);
    List<dynamic> _vouchers = [];
    vouchers.forEach((element)  async  {
      List<dynamic> details = await accTrxMaster.getDetails(element['trx_master_id']);
      List<dynamic> _details = [];
      details.forEach((element) {
        _details.add({
          'trx_detail_id': element['trx_detail_id'],
          'trx_master_id': element['trx_master_id'],
          'acc_id': element['acc_id'],
          'credit': element['credit'],
          'debit': element['debit'],
          'narration': (element['narration'].toString().trim() != '')? element['narration'].toString() : null,
          'is_active': element['is_active'],
          'in_active_date': (element['in_active_date']!=null)? element['in_active_date'] : null,
          'user_id': element['user_id'],
          'create_date': (element['create_date']!=null)? element['create_date'].toString() : null
        });
      });
      _vouchers.add({
        'trx_master_id':element['trx_master_id'],
        'office_id':element['office_id'],
        'trx_date':(element['trx_date']!=null)? element['trx_date'].toString() : null,
        'voucher_no': element['voucher_no'].toString(),
        'voucher_type': element['voucher_type'].toString(),
        'user_id':element['user_id'],
        'create_date':(element['create_date']!=null)? element['create_date'].toString() : element['trx_date'].toString(),
        'details':_details
      });
    });


    Map<String,dynamic> data = {
      'chartAccounts': [],
      'vouchers':_vouchers
    };

    List<dynamic> caList = await caService.getSyncableChartAccounts();
    data['chartAccounts'] = caList;

    AppConfig.log(jsonEncode(data));
//    return {'status':-1,'message':'test'};
    if(caList.length==0 && vouchers.length==0){
      return {'status':1,'message':'Everything Syncronized already. Nothing to upload'};
    }

    setUrl(getApiUrl('sync-data'));
    dynamic result = await post({'username':user.username,'deviceCode':user.imei,'uploadedData':jsonEncode(data)},
    header: {'Content-Type':'application/json'});

    if(result['status']==200) {

      caList.forEach((element) {
        caService.syncedChartAccount(element);
      });

      vouchers.forEach((element) {
        accTrxMaster.syncVoucher(element);
      });

      return {'status': 1, 'message': 'Data Uploaded succesfully'};
    }else{
      return {'status':-1, 'message': result['message']};
    }
  }

  Future<dynamic> syncDataDownload(User user) async {
    if(! await checkNetwork()){
      return {'status':-2,'message':'Please Check internet available'};
    }

    setUrl(getApiUrl('sync-download-imei',paramValue:user.syncId.toString()));

    Map<String,dynamic> result = await fetch();
    AppConfig.log(result);
    if(result!= null && result['status']==200){

      List<dynamic> masters = result['accTrxMasters'];
      AccTrxMasterService accTrxMasterService = AccTrxMasterService(masterRepo: AccTrxMasterRepository());

      masters.forEach((element) async {
        List<String> segment = element['voucherNo'].toString().split('-');
        int index = int.parse(segment[0]);

        List<dynamic> _details = element['accTrxDetails'];
        List<AccTrxDetail> details = [];
        _details.forEach((_detail) {
           details.add(AccTrxDetail(
             accId: _detail['accId'],
             credit: _detail['credit'],
             debit: _detail['debit'],
             narration: _detail['narration'],
             userId: int.parse(_detail['createUser'].toString()),
             createDate: _detail['createDate']
           ));
        });


        await accTrxMasterService.saveTransactions(AccTrxMaster(
          voucherNo: element['voucherNo'],
          autoVoucherNo: index,
          voucherType: element['voucherTypeApp'],
          officeId: element['officeId'],
          userId: element['officId'],
          trxDate: element['trxDate'],
          isPosted: element['posted']
        ),details);
      });

      UserService userService = UserService(userRepo: UserRepository());
      await userService.updateDownloadVoucherFlag(user);

      return {'status':1,'message':'Download vouchers completed'};
    }
    return {'status':-1,'message': 'Sorry! try again later'};
  }
}