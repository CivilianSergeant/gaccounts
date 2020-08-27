import 'package:gaccounts/persistance/entity/Profile.dart';
import 'package:gaccounts/persistance/repository/BaseRepository.dart';
import 'package:gaccounts/persistance/tables/ProfilesTable.dart';

class ProfileRepository extends BaseRepository{

  ProfileRepository():super(ProfilesTable().tableName);


}