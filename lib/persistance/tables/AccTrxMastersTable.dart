import 'package:gaccounts/persistance/interfaces/DDL.dart';

class AccTrxMastersTable implements DDL{

  String _tableName = "acc_trx_master";

  String get tableName{
    return this._tableName;
  }

  @override
  String createDDL() {
    return "CREATE TABLE "+_tableName+" ("
        "trx_master_id INTEGER PRIMARY KEY AUTOINCREMENT,"
        "office_id INTEGER,"
        "trx_date VARCHAR(50),"
        "auto_voucher_no integer,"
        "voucher_no VARCHAR(150),"
        "voucher_type VARCHAR(20),"
        "is_posted TINYINT(1) DEFAULT 0,"
        "user_id INTEGER,"
        "create_date VARCHAR(50)"
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