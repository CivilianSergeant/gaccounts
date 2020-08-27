import 'package:gaccounts/persistance/interfaces/DDL.dart';

class BusinessTypesTable implements DDL{
  String _tableName = "business_types";

  String get tableName{
    return _tableName;
  }

  @override
  String createDDL() {
    return "CREATE TABLE "+_tableName+" ("
        "id INTEGER PRIMARY KEY AUTOINCREMENT,"
        "title VARCHAR(150),"
        "code VARCHAR(20),"
        "parent_id INTEGER"
        ")";
  }

  @override
  List<String> createIndexes() {
    // TODO: implement createIndexes
    throw UnimplementedError();
  }

  @override
  String dropDDL() {
    return "DROP TABLE IF EXISTS " + _tableName;
  }


  static String seed(){
    return "INSERT INTO business_types (id,title,code,parent_id) VALUES (1,'Sole Proprietorship','BTSP',0),"
        " (2,'Partership','BTP',0),(3,'Grocery Stores','BTSP01',1),(4,'Fruit Stores', 'BTSP02',1);";
  }


}