import 'package:gaccounts/persistance/interfaces/DDL.dart';

class BusinessTypeChartAccountsTable implements DDL{

  String _tableName = "business_type_chart_accounts";

  String get tableName{
    return _tableName;
  }

  @override
  String createDDL() {
    return "CREATE TABLE "+_tableName+" ("
        "id INTEGER PRIMARY KEY AUTOINCREMENT,"
        "chart_account_id INTEGER,"
        "business_type_id INTEGER"
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