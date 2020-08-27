import 'package:gaccounts/persistance/repository/BaseRepository.dart';
import 'package:gaccounts/persistance/tables/AccTrxMastersTable.dart';
import 'package:sqflite/sqflite.dart';

class AccTrxMasterRepository extends BaseRepository{

  AccTrxMasterRepository() : super(AccTrxMastersTable().tableName);

  Future<dynamic> findByVoucherNo(String voucherNo) async{
    return find(where:"voucher_no=?",whereArgs: [voucherNo],firstOnly: true);
  }

  Future<void> updateAll() async{
    Database db = await getDBInstance();
    db.update(tableName, {'is_posted':0});
  }

}