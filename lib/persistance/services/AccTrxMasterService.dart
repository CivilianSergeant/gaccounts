import 'package:gaccounts/config/AppConfig.dart';
import 'package:gaccounts/persistance/entity/AccTrxDetails.dart';
import 'package:gaccounts/persistance/entity/AccTrxMaster.dart';
import 'package:gaccounts/persistance/repository/AccTrxMasterRepository.dart';
import 'file:///C:/Users/ASUS/IdeaProjects/gaccounts/lib/persistance/repository/AccTrxDetailRepository.dart';
import 'package:gaccounts/services/network.dart';
import 'package:sqflite/sqflite.dart';

class AccTrxMasterService extends NetworkService{

   final AccTrxMasterRepository masterRepo;
   final AccTrxDetailRepository detailRepository = AccTrxDetailRepository();

   AccTrxMasterService({this.masterRepo});

  Future<dynamic> hasMaster(){
    String searchingValue = '00001-'+(DateTime.now()).year.toString();
    AppConfig.log(searchingValue);
    return masterRepo.find(where:"voucher_no=?",whereArgs: [searchingValue],
    firstOnly: true);
  }

   Future<Map<String,dynamic>> getLastVoucherNo() async{

     Database db = await masterRepo.getDBInstance();
     List<Map<String,dynamic>> results = await db.rawQuery("SELECT MAX(voucher_no) voucher_no FROM acc_trx_master limit 1");
     return (results.length>0) ? results.first : null;
   }

  Future<List<Map<String,dynamic>>> getVouchers() async{
    Database db = await masterRepo.getDBInstance();
    String sql = "select atm.trx_master_id,atm.voucher_no,is_posted,atm.trx_date,atm.voucher_type,"
        " sum(atd.credit) credit, sum(atd.debit) debit "
        " from acc_trx_master atm"
        " join acc_trx_details atd on atd.trx_master_id = atm.trx_master_id "
        " group by atm.trx_master_id ORDER BY atm.trx_master_id DESC";

    List<Map<String,dynamic>> maps = await db.rawQuery(sql);
    AppConfig.log(maps);
    return maps;
  }

  Future<List<dynamic>> getSyncableVouchers() async {
    List<dynamic> results = await masterRepo.find(where: 'is_posted=0');
    return results;
  }

  Future<dynamic> getDetails(int trxMasterId) async {
    dynamic maps = await detailRepository.find(where:"trx_master_id =?",whereArgs: [trxMasterId]);
    return maps;
  }

  Future<int> updateTransactions(List<AccTrxDetail> details) async{
    AppConfig.log("HERE WITHIN SERVICE: "+detailRepository.toString());
     int updated = await detailRepository.updateDetails(details);
     return updated;
  }

  Future<int> syncVoucher(Map<String,dynamic> voucher) async{
    Database db = await masterRepo.getDBInstance();
    return await db.update(masterRepo.tableName, {'is_posted':1},
        where: 'trx_master_id=?',whereArgs: [voucher['trx_master_id']]);

  }


  Future<int> saveTransactions(AccTrxMaster master,List<AccTrxDetail> details) async{
      dynamic masterExist = await masterRepo.findByVoucherNo(master.voucherNo);
      if(masterExist!=null){
        AppConfig.log(masterExist.toString());
        return -1;
      }
      int masterSaved = await masterRepo.save(master);
      if(masterSaved>0){
        int detailsAdded = await detailRepository.addDetails(masterSaved,details);

        if(detailsAdded>0){
          return 2;
        }
        return 1;
      }
      return 0;
  }

  Future<double> getOpeningBalance(String voucherType,String date) async{

    double received = 0;
    double payment = 0;
    double openingBalance = 0;
    Database db = await detailRepository.getDBInstance();

    String sql = "SELECT atm.*, atd.narration, atd.credit,atd.debit,ca.acc_code,ca.acc_name from ${masterRepo.tableName} atm"
        " JOIN ${detailRepository.tableName} atd ON atd.trx_master_id = atm.trx_master_id"
        " JOIN chart_accounts ca ON ca.acc_id = atd.acc_id"
        " WHERE strftime('%s',atm.trx_date) < strftime('%s','${date}') AND atd.narration LIKE 'cash-in-hand%'";

    AppConfig.log(sql);
    List<dynamic> results = await db.rawQuery(sql);

    AppConfig.log(results);

    results.forEach((element) {
      if(voucherType!=null){
        if(element['narration'].toString().contains(voucherType)){
          received += element['credit'];
          payment += element['debit'];
        }
      }else {
        received += element['credit'];
        payment += element['debit'];
      }
    });

    //if(voucherType=='cash-purchase'){
      openingBalance = received - payment;
    //}



    return openingBalance.abs();
  }

  Future<int> updateVoucher(int id,{dynamic data}) async{
    Database db = await masterRepo.getDBInstance();
    return await db.update(masterRepo.tableName, {'is_posted':0,'trx_date':data['trx_date']},where:'trx_master_id=?',whereArgs: [id]);
  }

  Future<void> updateAll() async{
    masterRepo.updateAll();
  }

  Future<void> removeAll() async{
    masterRepo.truncate();
    detailRepository.truncate();
  }

  Future<List<Map<String,dynamic>>> getCashBook(String date) async{
    DateTime d = DateTime.parse(date);
    String sql ="SELECT atm.*, atd.narration, atd.credit,atd.debit,ca.acc_code,ca.acc_name from ${masterRepo.tableName} atm"
        " JOIN ${detailRepository.tableName} atd ON atd.trx_master_id = atm.trx_master_id"
        " JOIN chart_accounts ca ON ca.acc_id = atd.acc_id"
        " WHERE atm.trx_date LIKE '${d.toString().substring(0,10)}%' "
        " AND atm.voucher_type in ('cash-purchase','cash-sale','received','payment','bank')";


    AppConfig.log(sql);
    Database db = await masterRepo.getDBInstance();
    return await db.rawQuery(sql);
  }

}