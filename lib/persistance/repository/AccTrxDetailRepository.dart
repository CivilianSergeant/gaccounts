import 'package:gaccounts/config/AppConfig.dart';
import 'package:gaccounts/persistance/entity/AccTrxDetails.dart';
import 'package:gaccounts/persistance/repository/BaseRepository.dart';
import 'package:gaccounts/persistance/tables/AccTrxDetailsTable.dart';
import 'package:sqflite/sqflite.dart';

class AccTrxDetailRepository extends BaseRepository{
  AccTrxDetailRepository() : super(AccTrxDetailsTable().tableName);

  Future<int> addDetails(int masterId, List<AccTrxDetail> details) async{
    Batch batch = (await getDBInstance()).batch();
    int i=0;
    details.forEach((detail) {
      detail.trxMasterId = masterId;
      batch.insert(tableName, detail.toMap());
      i++;
    });

    await batch.commit(noResult: true);
    return i;
  }

  Future<int> updateDetails(List<AccTrxDetail> details) async {
    Database db = await getDBInstance();
    int i=0;
    Batch batch = db.batch();
    for(AccTrxDetail element in details){
      if(element.trxDetailId!=null) {
        batch.update(tableName, {
          "narration": element.narration,
          "credit": element.credit,
          "debit": element.debit
        }, where: "trx_detail_id=?", whereArgs: [element.trxDetailId]);
      }else{
        batch.insert(tableName, element.toMap());
      }
      i++;
    }
    await batch.commit(noResult: true);

    return i;
  }


  

}