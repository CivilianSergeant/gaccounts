import 'package:gaccounts/persistance/interfaces/DDL.dart';

class ChartAccountsTable implements DDL{

  String _tableName = "chart_accounts";

  String get tableName{
    return this._tableName;
  }

  @override
  String createDDL() {
    return "CREATE TABLE "+_tableName+" ("
        "id INTEGER PRIMARY KEY AUTOINCREMENT,"
        "acc_id INTEGER,"
        "acc_name VARCHAR(150),"
        "acc_code VARCHAR(150),"
        "acc_level INTEGER,"
        "first_level VARCHAR(11),"
        "second_level VARCHAR(11),"
        "third_level VARCHAR(11),"
        "fourth_level VARCHAR(11),"
        "fifth_level VARCHAR(11),"
        "category_id INTEGER,"
        "nature VARCHAR(11),"
        "group_id INTEGER,"
        "voucher_type VARCHAR(11),"
        "is_transaction TINYINT(1),"
        "is_selected TINYINT(1),"
        "is_sync TINYINT(1) DEFAULT 0"
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