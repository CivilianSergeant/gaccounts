import 'package:gaccounts/config/AppConfig.dart';
import 'package:gaccounts/persistance/DbProvider.dart';
import 'package:gaccounts/persistance/entity/BusinessType.dart';
import 'package:gaccounts/persistance/repository/BaseRepository.dart';
import 'package:gaccounts/persistance/tables/BusinessTypesTable.dart';
import 'package:sqflite/sqflite.dart';

class BusinessTypeRepository extends BaseRepository{
  BusinessTypeRepository() : super(BusinessTypesTable().tableName);

  Future<List<Map<String,dynamic>>> findParentType() async{
    List<Map<String,dynamic>> maps = await super.find(where:"parent_id=?",whereArgs:[0]);
    return maps;
  }

  Future<List<Map<String,dynamic>>> findChildType(int parentId) async{
    List<Map<String,dynamic>> maps = await super.find(where:"parent_id=?",whereArgs:[parentId]);
    return maps;
  }

  Future<int> addBusinessTypes(List<dynamic> businessTypes,{Function uiCallback}) async{
    final Database db = await DbProvider.db.database;
    int i=0;
    Batch batch = db.batch();
    for(dynamic businessType in businessTypes){
      Map<String,dynamic> map = (BusinessType(
          id: int.parse(businessType['id'].toString()),
          title: businessType['title'],
          code: businessType['code'],
          parentId: int.parse(businessType['parentId'].toString())
      )).toMap();
      AppConfig.log(map);
      batch.insert(BusinessTypesTable().tableName,map);
      i++;
    }

    await batch.commit(noResult: true);
    return i;
  }



}