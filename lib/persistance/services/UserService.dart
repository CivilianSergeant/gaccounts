import 'package:gaccounts/config/ApiUrl.dart';
import 'package:gaccounts/config/AppConfig.dart';
import 'package:gaccounts/persistance/entity/Profile.dart';
import 'package:gaccounts/persistance/entity/User.dart';
import 'package:gaccounts/persistance/interfaces/Repository.dart';
import 'package:gaccounts/persistance/repository/BusinessTypeRepository.dart';
import 'package:gaccounts/persistance/repository/UserRepository.dart';
import 'package:gaccounts/persistance/services/BusinessTypeService.dart';
import 'package:gaccounts/services/network.dart';
import 'package:imei_plugin/imei_plugin.dart';
import 'package:toast/toast.dart';

class UserService extends NetworkService{
  UserRepository userRepo;

  UserService({
    this.userRepo
  });

  Future<User> checkCurrentUser() async {
    String imei = await ImeiPlugin.getImei(
        shouldShowRequestPermissionRationale: false);
    User user = await findUserByIMEI(imei);
    return user;
  }

  Future<User> findUserByIMEI(String imei) async {
    return await userRepo.find(where: "imei=?",whereArgs: [imei],firstOnly: true);
  }

  Future<Map<String,dynamic>> registerUser(dynamic data) async{

    var message = '';
    var code = 200;

    Profile profile = Profile(
      name: data['name'],
      email: data['email'],
      address: data['address'],
      phoneNo: data['phoneNo']
    );

    User user = User(
      imei: data['imei'],
      username:data['phoneNo'],
      verifiedId: null,
      isVerified: false,
      userId: null
    );

    AppConfig.log(user);
    AppConfig.log(profile);

    setUrl(getApiUrl("register"));

    dynamic result = await post(data,header:{
      'Content-Type':'application/json'
    });

    code = result['status'];
    if(result == null){
      return {'status':false,'message':'Something wrong'};
    }

    int saved;
    if(result != null && result['status'] == 200){

      user.syncId = result['account']['id'];
      saved = await userRepo.save({'profile':profile,'user':user});
      List<dynamic> businessTypes = result['businessTypes'];
      BusinessTypeService businessTypeService = new BusinessTypeService(repository: BusinessTypeRepository());
      businessTypeService.addBusinessTypesFromServer(businessTypes);

    }else if(result !=null && result['status'] == 202){
      user.syncId = result['account']['id'];
      user.userId = result['account']['userId'];
      user.verifiedId = result['account']['verifiedId'];
      user.isVerified = result['account']['verified'];
      List<dynamic> businessTypes = result['businessTypes'];
      BusinessTypeService businessTypeService = new BusinessTypeService(repository: BusinessTypeRepository());
      businessTypeService.addBusinessTypesFromServer(businessTypes);
      saved = await userRepo.save({'profile':profile,'user':user});
      message = result['message'];

      AppConfig.log("SAVED:${saved}");

    }else if(result != null && result['status']==500){
      saved=0;
      message=result['message'];
    }


    return (saved != null && saved>0)? {'status':code,'message':message}:
    {'status':code,'message':message};

  }

  Future<bool> savePhoneVerification(String vId, String uid,int id) async{

    setUrl(getApiUrl("user-verified"));
    var data = {
      'id' : id,
      'userId':uid,
      'verificationId':vId
    };
    dynamic result = await post(data,header:{
      'Content-Type':'application/json'
    });
    AppConfig.log(result);
    int updated = await userRepo.updateUserVerification(vId,uid,id);
    return (updated>0)? true : false;
  }

  Future<int> updateBusinessType(User user, int businessTypeId) async {
    user.businessTypeId=businessTypeId;
    return await userRepo.updateBusinessType(user);
  }

  Future<int> updateDownloadVoucherFlag(User user) async {
    user.downloadVoucher=true;
    return await userRepo.updateDownloadVoucherFlag(user);
  }
}