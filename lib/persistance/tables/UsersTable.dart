import 'package:gaccounts/persistance/interfaces/DDL.dart';

class UsersTable implements DDL{

  String _tableName = "users";

  String get tableName{
    return this._tableName;
  }

  @override
  String createDDL() {
   return "CREATE TABLE "+_tableName+" ("
       "id INTEGER PRIMARY KEY AUTOINCREMENT,"
       "profile_id INTEGER,"
       "business_type_id INTEGER DEFAULT 0,"
       "user_id VARCHAR(20),"
       "username VARCHAR(20),"
       "is_verified TINYINT(1) DEFAULT 0,"
       "verified_id VARCHAR(500),"
       "imei VARCHAR(150),"
       "sync_id INTEGER,"
       "download_voucher TINYINT(1) DEFAULT 0"
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