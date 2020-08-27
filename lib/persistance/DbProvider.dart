import 'package:gaccounts/config/AppConfig.dart';
import 'package:gaccounts/persistance/entity/AccTrxMaster.dart';
import 'package:gaccounts/persistance/tables/AccTrxDetailsTable.dart';
import 'package:gaccounts/persistance/tables/AccTrxMastersTable.dart';
import 'package:gaccounts/persistance/tables/BusinessTypeChartAccountsTable.dart';
import 'package:gaccounts/persistance/tables/BusinessTypesTable.dart';
import 'package:gaccounts/persistance/tables/ChartAccountsTable.dart';
import 'package:gaccounts/persistance/tables/ProfilesTable.dart';
import 'package:gaccounts/persistance/tables/UsersTable.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DbProvider{
  DbProvider._();
  static final DbProvider db = DbProvider._();
  static Database _database;
  static int _dbVersion=1;

  Future<Database> get database async {
    if (_database != null){
      return _database;
    }


    _database = await initDB();
    return _database;
  }

  Future<void> _createTables(Database db) async{
    await db.execute(UsersTable().createDDL()).then((_){
      AppConfig.log(UsersTable().tableName+" Created");
    });

    await db.execute(ProfilesTable().createDDL()).then((_){
      AppConfig.log(ProfilesTable().tableName+" Created");
    });

    await db.execute(BusinessTypesTable().createDDL()).then((_){
      AppConfig.log(BusinessTypesTable().tableName+" Created");
//      db.execute(BusinessTypesTable.seed());
    });

    await db.execute(ChartAccountsTable().createDDL()).then((_){
      AppConfig.log(ChartAccountsTable().tableName+" Created");
    });

    await db.execute(BusinessTypeChartAccountsTable().createDDL()).then((_){
      AppConfig.log(BusinessTypeChartAccountsTable().tableName+" Created");
    });

    await db.execute(AccTrxMastersTable().createDDL()).then((_){
      AppConfig.log(AccTrxMastersTable().tableName+" Created");
    });
    
    await db.execute(AccTrxDetailsTable().createDDL()).then((_){
      AppConfig.log(AccTrxDetailsTable().tableName+" Created");
    });
  }

  void _createIndexes(Database db) {



//    List<String> guarantorIndexes = GuarantorsTable().createIndexes();
//    guarantorIndexes.forEach((String cmd) async {
//      await db.execute(cmd);
//    });


  }

  Future<void> _dropTables(Database db) async{
    await db.execute(UsersTable().dropDDL()).then((_){
      AppConfig.log(UsersTable().tableName+" DROPPED");
    });
    await db.execute(ProfilesTable().dropDDL()).then((_){
      AppConfig.log(ProfilesTable().tableName+" DROPPED");
    });

    await db.execute(BusinessTypesTable().dropDDL()).then((_){
      AppConfig.log(BusinessTypesTable().tableName+" DROPPED");
    });
    await db.execute(ChartAccountsTable().dropDDL()).then((_){
      AppConfig.log(ChartAccountsTable().tableName+" DROPPED");
    });

    await db.execute(BusinessTypeChartAccountsTable().dropDDL()).then((_){
      AppConfig.log(BusinessTypeChartAccountsTable().tableName+" DROPPED");
    });

    await db.execute(AccTrxMastersTable().dropDDL()).then((_){
      AppConfig.log(AccTrxMastersTable().tableName+" DROPPED");
    });

    await db.execute(AccTrxDetailsTable().dropDDL()).then((_){
      AppConfig.log(AccTrxDetailsTable().tableName+" DROPPED");
    });
  }

  initDB() async {
    String dbPath = await getDatabasesPath();
    String path = join(dbPath, "gaccounts_app_storage.db");

    return await openDatabase(path,version: _dbVersion,
        onOpen: (db) {

        },
        onCreate: (Database db, int version) async {
            this._createTables(db).then((_) {
              this._createIndexes(db);
            });
        },
        onUpgrade: (Database db, int oldVersion , int newVersion) async{
          this._dropTables(db).then((_){
            this._createTables(db);
          });
        }
    );
  }

}