import 'package:gaccounts/persistance/interfaces/DDL.dart';

class ProfilesTable implements DDL{
  String _tableName = "profiles";

  String get tableName{
    return this._tableName;
  }

  @override
  String createDDL() {
    return "CREATE TABLE "+_tableName+" ("
        "profile_id INTEGER PRIMARY KEY AUTOINCREMENT,"
        "name VARCHAR(150),"
        "email VARCHAR(200),"
        "address VARCHAR(500),"
        "phone_no VARCHAR(30),"
        "business_scale_id INTEGER DEFAULT NULL,"
        "business_type_id INTEGER DEFAULT NULL"
        ")";
  }

  @override
  List<String> createIndexes() {
    
  }

  @override
  String dropDDL() {
    return "DROP TABLE IF EXISTS " + _tableName;
  }

}