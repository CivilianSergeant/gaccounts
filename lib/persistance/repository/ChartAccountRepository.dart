import 'package:gaccounts/config/AppConfig.dart';
import 'package:gaccounts/persistance/DbProvider.dart';
import 'package:gaccounts/persistance/repository/BaseRepository.dart';
import 'package:gaccounts/persistance/tables/ChartAccountsTable.dart';
import 'package:sqflite/sqflite.dart';

class ChartAccountRepository extends BaseRepository{
  ChartAccountRepository() : super(ChartAccountsTable().tableName);

  Future<void> truncate() async {
    final Database db = await DbProvider.db.database;
    await db.execute("DELETE FROM "+tableName);
  }

  Future<List<Map<String,dynamic>>> findAll() async{
    final Database db = await DbProvider.db.database;
    List<Map<String,dynamic>> maps = await db.query(ChartAccountsTable().tableName,orderBy: 'acc_code asc');
//    maps.forEach((element) {
//      print(element);
//    });
    return maps;
  }

  Future<int> setAccountActive(int value,int accId) async {
    final Database db = await DbProvider.db.database;
    return await db.update(ChartAccountsTable().tableName,
        {'is_selected':value},where: 'acc_id=?',whereArgs: [accId]);
  }

  Future<List<Map<String,dynamic>>> getTypedAccounts({String type}) async {
    final Database db = await DbProvider.db.database;
    return await db.query(ChartAccountsTable().tableName,where:"voucher_type LIKE '%${type}%' AND group_id != 3 AND is_selected=1"
        ,orderBy: "acc_code asc");
  }

  Future<Map<String,dynamic>> getSingleTypedAccount({String type}) async {
    final Database db = await DbProvider.db.database;
    List<Map<String,dynamic>> maps = await db.query(ChartAccountsTable().tableName,where:"voucher_type LIKE '%${type}%'");
    if(type=='received'){
      maps.forEach((element) {
        AppConfig.log("HERE: "+element.toString());
      });

      return (maps.length>0)? maps.first:{};
    }
    return (maps.length>0)? maps.first:{};
  }
}