import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gaccounts/config/AppConfig.dart';
import 'package:gaccounts/persistance/entity/User.dart';
import 'package:gaccounts/persistance/repository/ProfileRepository.dart';
import 'package:gaccounts/persistance/repository/UserRepository.dart';
import 'package:gaccounts/persistance/services/UserService.dart';
import 'package:gaccounts/screens/DashboardScreen.dart';
import 'package:gaccounts/screens/SettingsScreen.dart';
import 'package:gaccounts/screens/interfaces/Validator.dart';
import 'package:gaccounts/services/PhoneAuthService.dart';
import 'package:gaccounts/services/network.dart';
import 'package:gaccounts/widgets/ActionButton.dart';
import 'package:gaccounts/widgets/OtpVerificationView.dart';
import 'package:gaccounts/widgets/PhoneField.dart';
import 'package:gaccounts/widgets/TextFieldExt.dart';
import 'package:gaccounts/widgets/services/PhoneFieldService.dart';
import 'package:toast/toast.dart';



FirebaseAuth firebaseAuth = FirebaseAuth.instance;

class RegistrationScreen extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _RegistrationScreenState();

}

class _RegistrationScreenState extends State<RegistrationScreen>{

  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  StreamController otpStreamer = StreamController.broadcast();
  StreamController registerButtonStreamer = StreamController.broadcast();
  StreamController otpButtonStreamer = StreamController.broadcast();

  String key1;
  String key2;
  String key3;
  String key4;
  String key5;
  String key6;

  String imei;

  bool isOtpEnabled = false;
  String verificationId;
  RegistrationValidator validator;
  bool processRegister = false;

  @override
  void initState() {
    key1 = "";
    key2 = "";
    key3 = "";
    key4 = "";
    key5 = "";
    key6 = "";
    validator = RegistrationValidator(context:context);

  }


  @override
  void didChangeDependencies() {
    Map<String,dynamic> obj = ModalRoute.of(context).settings.arguments;
    imei = obj['imei'];
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: SingleChildScrollView(

        child: showView(),
      ),

    );
  }

  Widget showView(){
    if(isOtpEnabled){
      return OtpView();
    }

    return RegistrationView();
  }

  handleOtpClick(value) async {

    otpButtonStreamer.sink.add(1);
    String smsCode = value['key1']+
        value['key2']+value['key3']+value['key4']+value['key5']+
        value['key6'];

    await validator.handleOtpSubmit(this.verificationId,smsCode,(){
      otpButtonStreamer.sink.add(2);
    });

    AppConfig.log(smsCode);
  }

  Widget OtpView(){

//    return StreamBuilder(
//      stream: otpStreamer.stream,
//      builder: (BuildContext context, AsyncSnapshot snapshot){
//        if(snapshot.data != null) {
//          key1 = snapshot.data[0];
//          key2 = snapshot.data[1];
//          key3 = snapshot.data[2];
//          key4 = snapshot.data[3];
//          key5 = snapshot.data[4];
//          key6 = snapshot.data[5];
          return OtpVerificationView(
            value1: key1,
            value2: key2,
            value3: key3,
            value4: key4,
            value5: key5,
            value6: key6,
            buttonStream: otpButtonStreamer.stream,
            onActionClick: handleOtpClick,
          );
//        }else{
//          return Container(
//              color: Colors.white,
//              width: MediaQuery.of(context).size.width,
//              height: MediaQuery.of(context).size.height,
//              child: Column(
//
//              children: <Widget>[
//                SizedBox(
//                height: 120,
//                ),
//                Text("OTP VERIFICATION",style: TextStyle(
//                fontSize: 30,
//                fontWeight: FontWeight.w600,
//                color: Colors.teal
//                ),),
//                SizedBox(height: 40,),
//                Text("Loading", style:TextStyle(color:Color(0xff0e4b61)))
//              ]
//              )
//          );
//        }


  }

  Widget RegistrationView(){
    return Container(
      color: Colors.white,
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 120,
          ),
          Text("REGISTRATION",style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.w600,
              color: Colors.teal
          ),),
          SizedBox(height: 40,),
          TextFieldExt(hintText: "Name",icon: Icons.person,topPad: 15,
            controller: nameController,borderRadius: 50,),
          PhoneField(controller: phoneController,callback: phoneFieldService.DialingCode),
          TextFieldExt(hintText: "Email",icon: Icons.email,topPad: 0,
            keyboardType: TextInputType.emailAddress,
            controller: emailController,borderRadius: 50,),
          TextFieldExt(hintText: "Address",icon: Icons.location_on,topPad: 15,
            controller: addressController,borderRadius: 50,),

          SizedBox(height: 10,),
          StreamBuilder(
            stream: phoneFieldService.getDialingCode,
            builder: (BuildContext context,AsyncSnapshot snapshot){
              return Padding(
                padding: EdgeInsets.only(left: 20,right: 20,top: 10),
                child: ActionButton(
                  stream: registerButtonStreamer.stream,
                  caption: "REGISTER",onTap: () async{


                  var dialingCode = snapshot.data;
                  validator.setData({
                    'name': nameController.text,
                    'email': emailController.text,
                    'address': addressController.text,
                    'phoneNo': phoneController.text,
                    'dialingCode': dialingCode,
                    'imei': imei
                  });
                  if(processRegister){
                    AppConfig.log("AL EXECED");
                    return;
                  }
                  setState(() {
                    processRegister = true;
                    registerButtonStreamer.sink.add(1);
                  });
                  if(validator.validate()){
                      if(await validator.submit((){
                      String phoneNo = dialingCode + phoneController.text;


                      firebaseAuth.verifyPhoneNumber(
                          phoneNumber: phoneNo, timeout: Duration(seconds: 60),
                          verificationCompleted: autoVerify, verificationFailed: (AuthException ex){
                        AppConfig.log(ex);
                      }, codeSent: manualVerify, codeAutoRetrievalTimeout: (String vId){
                        AppConfig.log("TIMED OUT:"+ vId);
                      });

                    })){
                      Navigator.of(context).pushReplacementNamed('/dashboard');
                    }else{
                      AppConfig.log("SOMETHING WRONG");
                    }
                    setState(() {
                      processRegister = false;
                      registerButtonStreamer.sink.add(null);
                    });

                  }else{
                    setState(() {
                      processRegister = false;
                      registerButtonStreamer.sink.add(null);
                    });
                  }


                },),
              );
            },
          ),

        ],
      ),
    );
  }

  void autoVerify(AuthCredential credential) async{

    AppConfig.log("HERE ====");

    List<String> segments = credential.toString().split("zzb:");
    if(segments.length>1) {
      String code = segments.elementAt(1).substring(6, 12);
      AppConfig.log(code);
      if(code.length==6){
//      var code = jsonObj['jsonObject']['zzb'];
//      var key1 = code.toString().substring(0,1);
//      var key2 = code.toString().substring(1,2);
//      var key3 = code.toString().substring(2,3);
//      var key4 = code.toString().substring(3,4);
//      var key5 = code.toString().substring(4,5);
//      var key6 = code.toString().substring(5,6);
//      List<String> data  = [key1,key2,key3,key4,key4,key5,key6];
//      t.sink.add(data);
//
      }
    }

    AuthResult result = await firebaseAuth.signInWithCredential(credential);
    if(result.user != null) {
      UserService userService = UserService(userRepo: UserRepository());
      User currentUser = await userService.checkCurrentUser();
      bool verified = await userService.savePhoneVerification('auto', result.user.uid, currentUser.syncId);
      if(verified){
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) =>  SettingsScreen()
        ));
      }
    }
  }

  void manualVerify(String verificationId, [int forceToken]){

    List<String> data  = ["","","","","",""];
    otpStreamer.sink.add(data);
    setState(() {


      processRegister = false;
      registerButtonStreamer.sink.add(2);
      otpButtonStreamer.sink.add(null);
      this.isOtpEnabled = true;

    });
    this.verificationId = verificationId;
  }

  @override
  void dispose() {
    phoneFieldService.dispose();
    otpStreamer.close();
    otpButtonStreamer.close();
    registerButtonStreamer.close();
    super.dispose();
  }
}

class RegistrationValidator implements FormValidator{
  dynamic data;
  String error;
  BuildContext context;
  Function showOtpViewer;
  bool isOtpSend;
  RegistrationValidator({this.context});
  String verificationId;
  User currentUser;

  @override
  validate() {
    if(data['name'] == null || data['name']==""){
      error = "Name Required";
      Toast.show(getError(), context,duration:
      Toast.LENGTH_LONG,gravity: Toast.CENTER);
      return false;
    }
    if(data['phoneNo'] == null || data['phoneNo']==""){
      error = "Phone No Required";
      Toast.show(getError(), context,duration:
      Toast.LENGTH_LONG,gravity: Toast.CENTER);
      return false;
    }

    return true;
  }

  getError(){
    return error;
  }

  @override
  submit(Function callback) async {


     UserService userService = UserService(userRepo: UserRepository(
       profileRepo: ProfileRepository()
     ));

     data['phoneNo'] = data['dialingCode']+data['phoneNo'];

     AppConfig.log(data);
     bool netStatus = await NetworkService.check();
     if(!netStatus){
       Toast.show("Sorry! Internet not available.", context,
       duration: Toast.LENGTH_LONG,gravity: Toast.CENTER);
       return false;
     }
     var registered = await userService.registerUser(data);

     User user = await userService.checkCurrentUser();
     AppConfig.log(user);

     if(registered['status'] == 200){


       if(user == null){
         AppConfig.log("here");
         Toast.show("Sorry! Unable to create User. Try again later", context,
             duration: Toast.LENGTH_LONG,gravity: Toast.CENTER);
         return false;
       }



       if(user != null && !user.isVerified){

          currentUser = user;

            callback(); // firebase call
            return false;


       }else{
         return true;
       }

     }else if(registered['status']==202){

       Toast.show(registered['message'], context,
           duration: Toast.LENGTH_LONG, gravity: Toast.CENTER);
       if(user!= null && !user.isVerified){
         currentUser = user;

         callback(); // firebase call
         return false;
       }
       if(user.businessTypeId==null || user.businessTypeId==0){
         Navigator.of(context).pushReplacement(MaterialPageRoute(
             builder: (context) =>  SettingsScreen()
         ));
         return false;
       }
       return false;
     }else{
       Toast.show(registered['message'], context,duration:Toast.LENGTH_LONG,
       gravity: Toast.CENTER);
     }
     return false;
  }

  @override
  setData<T>(T data) {
    this.data = data;
  }

  handleOtpSubmit(String verificationId,String smsCode,Function callback) async{

    AuthCredential credential = PhoneAuthProvider.getCredential(verificationId: verificationId, smsCode: smsCode);
    AuthResult result = await firebaseAuth.signInWithCredential(credential);
    if(result.user != null) {
      AppConfig.log(result.user.displayName);

      UserService userService = UserService(userRepo: UserRepository());
//      User currentUser = await userService.checkCurrentUser();
      bool verified = await userService.savePhoneVerification(verificationId, result.user.uid, currentUser.syncId);
      if(verified){
        callback();
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) =>  SettingsScreen()
        ));
      }
    }
  }

  // make validator at registration class member variable create it on initstate
  // create method for manual otp verification & call onpressed of otp form
  // test whole process 

}