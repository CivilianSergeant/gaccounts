import 'package:gaccounts/config/ApiUrl.dart';
import 'package:gaccounts/config/AppConfig.dart';
import 'package:gaccounts/persistance/DbProvider.dart';
import 'package:gaccounts/persistance/entity/ChartAccount.dart';
import 'package:gaccounts/persistance/entity/User.dart';
import 'package:gaccounts/persistance/repository/ChartAccountRepository.dart';
import 'package:gaccounts/persistance/tables/ChartAccountsTable.dart';
import 'package:gaccounts/services/network.dart';
import 'package:sqflite/sqflite.dart';

class ChartAccountService extends NetworkService{
  ChartAccountRepository repo;

  ChartAccountService({this.repo});

  Future<List<dynamic>> getChartAccountByBusinessTypeFromServer(int id) async{
//    List<dynamic> chartAccounts = [];
//    AppConfig.debug(getApiUrl('chart-accounts-by-btype',paramValue:id.toString()));
    setUrl(getApiUrl('chart-accounts-by-btype',paramValue:id.toString()));

    Map<String,dynamic> result = await fetch();
    List<dynamic> parentChartAccounts = result['parentChartAccounts'];
    await remove();
    await addChartAccounts(parentChartAccounts);
    return result['chartAccounts'];
  }

  Future<List<Map<String,dynamic>>> getParentAccounts() async{
    Database db = await repo.getDBInstance();
    String sql="SELECT * FROM ${repo.tableName} WHERE acc_level IN (1,2)";
    return db.rawQuery(sql);
  }

  Future<List<Map<String,dynamic>>> getChildAccounts() async{
    Database db = await repo.getDBInstance();
    String sql="SELECT * FROM ${repo.tableName} WHERE acc_level IN (3)";
    return db.rawQuery(sql);
  }

  Future<List<Map<String,dynamic>>> getIncomeAccounts() async{
    Database db = await repo.getDBInstance();
    String sql="SELECT * FROM ${repo.tableName} WHERE acc_level=3 AND first_level=9 AND nature=2";
    return db.rawQuery(sql);
  }

  Future<List<Map<String,dynamic>>> getExpenseAccounts() async{
    Database db = await repo.getDBInstance();
    String sql="SELECT * FROM ${repo.tableName} WHERE acc_level=3 AND first_level=5 AND nature=3";
    return db.rawQuery(sql);
  }

  Future<Map<String,dynamic>> getthirdLevelAccCode(String secondLevel) async{
      if(! await checkNetwork()){
        return {'status':-2,'message': 'Please Check Internet available'};
      }
      setUrl(getApiUrl('max-accCode-by-code',paramValue: secondLevel));
      Map<String,dynamic> result = await fetch();
      AppConfig.log(result);
      if(result!=null && result['status']==200){
        dynamic chartAccount = result['chartAccount'];
        String accCode = (int.parse(chartAccount['accCode'].toString())+1).toString();
        return {
          'status':1,
          'accCode': accCode
        };
      }
      return {'status':-1,'message':'Something wrong try again later'};
  }


  Future<List<dynamic>> getSyncableChartAccounts() async {
    List<dynamic> accounts = await repo.find(where: 'is_sync=0');
    return accounts;
  }

  Future<dynamic> addChartAccount(ChartAccount acc, User user) async {

    if(! await checkNetwork()){
      return {'status':-2,'message':'Please Check Internet Connection available'};
    }
    setUrl(getApiUrl('chart-account-new'));
    Map<String,dynamic> result = await post({
      'user':{
        'id':user.syncId,
        'businessTypeId':user.businessTypeId
      },
      'chartAccount':{
        'accId':acc.accId,
        'accCode':acc.accCode,
        'accName':acc.accName,
        'accLevel':acc.accLevel,
        'firstLevel':acc.firstLevel,
        'secondLevel':acc.secondLevel,
        'thirdLevel':acc.thirdLevel,
        'fourthLevel':acc.fourthLevel,
        'fifthLevel':acc.fifthLevel,
        'categoryId':acc.categoryId,
        'nature':acc.nature,
        'groupId':acc.groupId,
        'voucherType':acc.voucherType,
        'isTransaction':acc.isTransaction,

      }
    },header: { 'Content-Type':'application/json'});
    AppConfig.log(result);
    if(result['status'] == 202){

      return {'status':-1,'message':result['message']};
    }

    if(result['status']==200){
      acc.accId = int.parse(result['chartAccount']['accId'].toString());
      acc.isSync=true;
      acc.isSelected=true;
      return {'status': await repo.save(acc),'message':'Chart Account Saved Successfull'};
    }

  }

  Future<dynamic> findAccountByCode(String code) async {
    return await repo.find(where:'acc_code=?',whereArgs: [code],firstOnly: true);
  }

  Future<dynamic> findAccountByCodeFromServer(String code) async {
    if(! await checkNetwork()){
      return {"netStatus":false,'account':null};
    }
    setUrl(getApiUrl('chart-account-by-code',paramValue: code));
    Map<String,dynamic> result = await fetch();

    AppConfig.log(result);

    return {"netStatus":true,'account':result['account']};
  }

  Future<int> addChartAccounts(List<dynamic> accounts) async{
    final Database db = await DbProvider.db.database;
    int i=0;
    Batch batch = db.batch();
    for(dynamic account in accounts){

      Map<String,dynamic> map = (ChartAccount(
          accId: int.parse(account['accId'].toString()),
          accName: account['accName'],
          accCode: account['accCode'],
          accLevel: int.parse(account['accLevel'].toString()),
          firstLevel: account['firstLevel'],
          secondLevel:account['secondLevel'],
          thirdLevel: account['thirdLevel'],
          fourthLevel: account['fourthLevel'],
          fifthLevel: account['fifthLevel'],
          categoryId: int.parse(account['categoryId'].toString()),
          nature: account['nature'],
          groupId: int.parse(account['groupId'].toString()),
          voucherType: account['voucherType'],
          isTransaction: account['transaction'],
          isSelected: (account['groupId']==3)? true: account['selected'],
          isSync: true

      )).toMap();

//      AppConfig.debug(map);

      batch.insert(ChartAccountsTable().tableName,map);
      i++;
    }

    await batch.commit(noResult: true);
    return i;
  }

  Future<int> updateChartAccount(Map<String,dynamic> chartAccount) async {

    return await repo.update(chartAccount['id'], {
      'acc_name':chartAccount['acc_name'],
      'is_sync':0
    });
  }

  Future<int> syncedChartAccount(Map<String,dynamic> chartAccount) async {

    return await repo.update(chartAccount['id'], {
      'acc_name':chartAccount['acc_name'],
      'is_sync':1
    });
  }

  Future<void> remove() async{
    await repo.truncate();
  }

  Future<List<Map<String,dynamic>>> getChartAccounts() async{
    return await repo.findAll();
  }

  Future<int> activeAccount(int value, int accId) async{
    return await repo.setAccountActive(value, accId);
  }

  Future<List<Map<String,dynamic>>> getCommonChartAccounts() async {
    return await repo.getTypedAccounts(type:'common');
  }

  Future<List<Map<String,dynamic>>> getReceivedChartAccounts() async {
    return await repo.getTypedAccounts(type: 'received');
  }

  Future<List<Map<String,dynamic>>> getPaymentChartAccounts() async {
    return await repo.getTypedAccounts(type: 'payment');
  }

  Future<List<Map<String,dynamic>>> getBankChartAccounts() async {
    List<Map<String,dynamic>> maps = await repo.getTypedAccounts(type: 'bank');
    List<Map<String,dynamic>> bankAccounts = [];
    Map<String,dynamic> map = maps.first;

    Map<String,dynamic> account1 = {
      'acc_id':map['acc_id'],
      'acc_name':map['acc_name'],
      'acc_code':map['acc_code'],
      'voucher_type':map['voucher_type'],
      'isPayable': true,
      'isReceivable':false
    };

    Map<String,dynamic> account2 = {
      'acc_id':map['acc_id'],
      'acc_name':map['acc_name'],
      'acc_code':map['acc_code'],
      'voucher_type': map['voucher_type'],
      'isPayable': false,
      'isReceivable':true
    };

    String name = map['acc_name'];
    account1['acc_name'] = name + " (Deposit)";
    bankAccounts.add(account1);
    account2['acc_name'] = name + " (Withdraw)";
    bankAccounts.add(account2);
     return bankAccounts;
  }

  Future<Map<String,dynamic>> getCashAccount() async {
    return await repo.getSingleTypedAccount(type:'cash');
  }

  Future<Map<String,dynamic>> getPayableAccount() async {
    return await repo.getSingleTypedAccount(type:'credit');
  }

  Future<Map<String,dynamic>> getReceivableAccount() async {
    return await repo.getSingleTypedAccount(type:'received');
  }

}