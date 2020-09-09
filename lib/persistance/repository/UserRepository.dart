import 'package:gaccounts/config/AppConfig.dart';
import 'package:gaccounts/persistance/DbProvider.dart';
import 'package:gaccounts/persistance/entity/Profile.dart';
import 'package:gaccounts/persistance/entity/User.dart';
import 'package:gaccounts/persistance/interfaces/Repository.dart';
import 'package:gaccounts/persistance/repository/BaseRepository.dart';
import 'package:gaccounts/persistance/tables/ProfilesTable.dart';
import 'package:gaccounts/persistance/tables/UsersTable.dart';
import 'package:sqflite/sqflite.dart';

class UserRepository extends BaseRepository{

  Repository _profile;

  UserRepository({Repository profileRepo}):super(UsersTable().tableName){
    this._profile = profileRepo;
  }

  @override
  Future<User> findById(int id) async{
    dynamic map = super.findById(id);
    return (map !=null)? User.fromJSON(map) : null;
  }

  Future<Map<String,dynamic>> getProfile(int id) async{
    Database db = await getDBInstance();
    List<Map<String,dynamic>> maps = await db.query(ProfilesTable().tableName,where: "profile_id=?",whereArgs: [id]);
    return (maps.length>0)? maps.first : null;
  }

  @override
  find({String where, List<dynamic> whereArgs,bool firstOnly})  async {
    final Database db = await DbProvider.db.database;
    List<Map<String,dynamic>> maps = await db.query(tableName,where: where, whereArgs: whereArgs);

    return (firstOnly != null && firstOnly == true)?
        ((maps.length>0)? User.fromJSON(maps.first) : null ) : maps;
  }

  @override
  Future<int> save(dynamic obj) async{
    Profile profile = obj['profile'];
    User user = obj['user'];
    int profileId = await _profile.save(profile);
    user.profileId = profileId;
    user.downloadVoucher=false;
    int userInserted = await super.save(user);
    return userInserted;
  }

  Future<int> updateUserVerification(String vid, String uid, int id) async{
    final Database db = await DbProvider.db.database;
    return db.update(tableName, {"verified_id":vid,"user_id":uid,"is_verified":1},where: "sync_id=?",whereArgs: [id]);
  }

  Future<int> updateBusinessType(User user) async{
    final Database db = await DbProvider.db.database;
    return db.update(tableName, {"business_type_id":user.businessTypeId},where:"id=?",whereArgs: [user.id],conflictAlgorithm:
    ConflictAlgorithm.replace);
  }

  Future<int> updateDownloadVoucherFlag(User user) async{
    final Database db = await DbProvider.db.database;
    int downLoadVoucher = (user.downloadVoucher)? 1:0;
    return db.update(tableName, {"download_voucher":downLoadVoucher},where:"id=?",whereArgs: [user.id],conflictAlgorithm:
    ConflictAlgorithm.replace);
  }


}