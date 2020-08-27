import 'package:gaccounts/persistance/interfaces/DDL.dart';

class AccTrxDetailsTable implements DDL{

  String _tableName = "acc_trx_details";

  String get tableName{
    return this._tableName;
  }

  @override
  String createDDL() {
    return "CREATE TABLE "+_tableName+" ("
        "trx_detail_id INTEGER PRIMARY KEY AUTOINCREMENT,"
        "trx_master_id INTEGER,"
        "acc_id INTEGER,"
        "credit REAL,"
        "debit REAL,"
        "narration VARCHAR(255),"
        "is_active TINYINT(1),"
        "in_active_date VARCHAR(20),"
        "user_id INTEGER,"
        "create_date VARCHAR(20)"
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

}