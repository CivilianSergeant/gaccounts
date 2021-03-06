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

  Future<double> getBankOpeningBalance(String date) async{
    double received = 0;
    double payment = 0;
    double openingBalance = 0;
    Database db = await detailRepository.getDBInstance();

    String sql = "SELECT atm.*, atd.narration, atd.credit,atd.debit,ca.acc_code,ca.acc_name from ${masterRepo.tableName} atm"
        " JOIN ${detailRepository.tableName} atd ON atd.trx_master_id = atm.trx_master_id"
        " JOIN chart_accounts ca ON ca.acc_id = atd.acc_id"
        " WHERE strftime('%s',atm.trx_date) < strftime('%s','${date}') AND ca.acc_level=3 AND ca.acc_name = 'Cash at Bank'";

    AppConfig.log(sql);
    List<dynamic> results = await db.rawQuery(sql);


    AppConfig.log(results,line: "138",className: "AccTrxMasterService");

    results.forEach((element) {

        received += element['credit'];
        payment += element['debit'];

    });


    openingBalance = received - payment;
    return openingBalance;
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

   Future<List<Map<String,dynamic>>> getVoucherSummary(String voucherType) async {

     String sql = "SELECT atm.*, atd.narration, sum(atd.credit) as credit ,sum(atd.debit) as debit,ca.acc_code,ca.acc_name from ${masterRepo
         .tableName} atm"
         " JOIN ${detailRepository
         .tableName} atd ON atd.trx_master_id = atm.trx_master_id"
         " JOIN chart_accounts ca ON ca.acc_id = atd.acc_id  AND ca.group_id != 3 AND ca.is_selected=1 "
         " WHERE atm.voucher_type LIKE '%${voucherType}%'"
         " Group BY atm.voucher_type";

     Database db = await masterRepo.getDBInstance();
     return await db.rawQuery(sql);

   }


  
  String _getPrevMonth(String startDate){
    DateTime dt = DateTime.parse(startDate);
    int month = (dt.month-1);
    month = (month<1)? 12 :month;
    String prevMonth = (month<10)? '0'+(month).toString() : (month).toString();
    return prevMonth;
  }

  String _getPrevMonthLastDate(String startDate){
    String prevMonth = _getPrevMonth(startDate);
    DateTime dt = DateTime.now();
    int _prevMonth = int.parse(prevMonth);
    String lastDate = "30";
    switch(_prevMonth){
      case 1:
      case 3:
      case 5:
      case 7:
      case 8:
      case 10:
      case 12:
        lastDate="31";
        break;
    }
    int year = (_prevMonth==12)? (dt.year-1) : (dt.year);
    return "${year}-${prevMonth}-${lastDate}";

  }

  Future<Map<String,dynamic>> getAccountsBalance(String startDate, String endDate,{bool upToPrev}) async{
    String sql ="SELECT atm.*, SUM(atd.credit) as credit , SUM(atd.debit) debit,ca.acc_code from ${masterRepo.tableName} atm"
        " JOIN ${detailRepository.tableName} atd ON atd.trx_master_id = atm.trx_master_id"
        " JOIN chart_accounts ca ON ca.acc_id = atd.acc_id"
        " WHERE strftime('%s',atm.trx_date) <= strftime('%s','${endDate}') "
        " AND strftime('%s',atm.trx_date) > strftime('%s','${startDate}')"
        " GROUP BY atd.acc_id";

    DateTime dt = DateTime.parse(startDate);
    int year = dt.month;
    String prevMonth = _getPrevMonth(startDate);
    AppConfig.log(prevMonth,line:"161",className: "AccTrxMasterService");

    String sql1 ="SELECT atm.*, SUM(atd.credit) as credit , SUM(atd.debit) debit,ca.acc_code from ${masterRepo.tableName} atm"
        " JOIN ${detailRepository.tableName} atd ON atd.trx_master_id = atm.trx_master_id"
        " JOIN chart_accounts ca ON ca.acc_id = atd.acc_id";
    if(upToPrev !=null && upToPrev){
      sql1 += " WHERE strftime('%s',atm.trx_date) < strftime('%s','${startDate}')";
    }else {
      sql1 += " WHERE atm.trx_date like '${year}-${prevMonth}%'";
    }
     sql1 +=   " GROUP BY atd.acc_id";

    Database db = await masterRepo.getDBInstance();
    List<Map<String,dynamic>> currenResults =  await db.rawQuery(sql);
    List<Map<String,dynamic>> prevResults = await db.rawQuery(sql1);

    currenResults.forEach((element) {
//      AppConfig.log(element,line:"161",className: "AccTrxMasterService");
    });
    return {'current':currenResults,'prev':prevResults};
       // " AND atm.voucher_type in ('cash-purchase','cash-sale','received','payment','bank')";
  }

   Future<Map<String,dynamic>> getBalanceSheet(String startDate) async{

     String sql ="SELECT atm.*, SUM(atd.credit) as credit , SUM(atd.debit) debit,ca.acc_code from ${masterRepo.tableName} atm"
         " JOIN ${detailRepository.tableName} atd ON atd.trx_master_id = atm.trx_master_id"
         " JOIN chart_accounts ca ON ca.acc_id = atd.acc_id"
         " WHERE strftime('%s',atm.trx_date) <= strftime('%s','${startDate}') "
         " GROUP BY atd.acc_id";


     String prevMonthLastDate = _getPrevMonthLastDate(startDate);
     AppConfig.log(startDate,line:"161",className: "AccTrxMasterService");
     AppConfig.log(prevMonthLastDate,line:"161",className: "AccTrxMasterService");

     String sql1 ="SELECT atm.*, SUM(atd.credit) as credit , SUM(atd.debit) debit,ca.acc_code from ${masterRepo.tableName} atm"
         " JOIN ${detailRepository.tableName} atd ON atd.trx_master_id = atm.trx_master_id"
         " JOIN chart_accounts ca ON ca.acc_id = atd.acc_id";

       sql1 += " WHERE strftime('%s',atm.trx_date) <= strftime('%s','${prevMonthLastDate}')";

     sql1 +=   " GROUP BY atd.acc_id";

     Database db = await masterRepo.getDBInstance();
     List<Map<String,dynamic>> currenResults =  await db.rawQuery(sql);
     List<Map<String,dynamic>> prevResults = await db.rawQuery(sql1);

     currenResults.forEach((element) {
//      AppConfig.log(element,line:"161",className: "AccTrxMasterService");
     });
     return {'current':currenResults,'prev':prevResults};
     // " AND atm.voucher_type in ('cash-purchase','cash-sale','received','payment','bank')";
   }

}