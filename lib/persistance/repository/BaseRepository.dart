import 'package:gaccounts/config/AppConfig.dart';
import 'package:gaccounts/persistance/DbProvider.dart';
import 'package:gaccounts/persistance/interfaces/Repository.dart';
import 'package:sqflite/sqflite.dart';

class BaseRepository implements Repository{
  String _tableName;

  get tableName{
    return _tableName;
  }

  BaseRepository(String tableName){
    this._tableName = tableName;
  }

  @override
  Future<dynamic> findById(int id) async{
    final Database db = await DbProvider.db.database;
    List<Map<String,dynamic>> maps = await db.query(_tableName,where: "id=?", whereArgs: [id]);
    return (maps.length>0)? maps.first : null;
  }

  @override
  find({String where, List<dynamic> whereArgs,bool firstOnly})  async {
    final Database db = await DbProvider.db.database;
    List<Map<String,dynamic>> maps = await db.query(_tableName,where: where, whereArgs: whereArgs);

    return (firstOnly != null && firstOnly == true)?
    ((maps.length>0)? maps.first : null ) : maps;
  }

  @override
  Future<int> save(dynamic obj) async{
    AppConfig.log("SAVE EXECUTED FROM BASE");
    final Database db = await DbProvider.db.database;
    Map<String,dynamic> map = obj.toMap();
    return await db.insert(_tableName, map,conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> update(int id, Map<String,dynamic> data) async{
    final Database db = await DbProvider.db.database;
    return await db.update(_tableName, data,where:"id=?",whereArgs: [id]);
  }

  Future<void> truncate() async {
    final Database db = await DbProvider.db.database;
    await db.execute("DELETE FROM "+_tableName);
  }

  Future<Database> getDBInstance() async{
    return await DbProvider.db.database;
  }
}