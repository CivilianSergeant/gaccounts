import 'dart:async';

import 'package:country_code_picker/country_code_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gaccounts/config/AppConfig.dart';
import 'package:gaccounts/persistance/entity/User.dart';
import 'package:gaccounts/persistance/repository/UserRepository.dart';
import 'package:gaccounts/persistance/services/UserService.dart';
import 'package:gaccounts/screens/SettingsScreen.dart';
import 'package:gaccounts/screens/interfaces/Validator.dart';
import 'package:gaccounts/widgets/ActionButton.dart';
import 'package:gaccounts/widgets/OtpVerificationView.dart';
import 'package:gaccounts/widgets/PhoneField.dart';
import 'package:gaccounts/widgets/services/PhoneFieldService.dart';
import 'package:toast/toast.dart';

FirebaseAuth firebaseAuth = FirebaseAuth.instance;

class LoginScreen extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _LoginScreenState();
  
}

class _LoginScreenState extends State<LoginScreen>{

  TextEditingController phoneController = TextEditingController();
  StreamController otpStreamer = StreamController.broadcast();
  StreamController otpButtonStreamer = StreamController.broadcast();
  StreamController loginButtonStreamer = StreamController.broadcast();

  bool isOtpEnabled = false;
  String verificationId;
  LoginValidator validator;
  String key1;
  String key2;
  String key3;
  String key4;
  String key5;
  String key6;

  @override
  Widget build(BuildContext context) {

    return showView();
  }


  @override
  void initState() {
    validator = LoginValidator(context:context);
  }

  showView(){
    if(isOtpEnabled){
      return OtpView();
    }

    return LoginView();
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
  }

  Widget LoginView(){
    return Scaffold(
      body: SingleChildScrollView(

        child: Container(
          color: Colors.white,
          height: MediaQuery.of(context).size.height,
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 140,
              ),
              Text("LOGIN",style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w600,
                  color: Colors.teal
              ),),
              SizedBox(height: 40,),
              PhoneField(controller: phoneController,callback: phoneFieldService.DialingCode),
              StreamBuilder(
                stream: phoneFieldService.getDialingCode,
                builder: (BuildContext context, AsyncSnapshot snapshot){
                  return Padding(
                    padding: EdgeInsets.only(left: 20,right: 20,top: 10),
                    child: ActionButton(
                      stream: loginButtonStreamer.stream,
                      caption: "LOGIN  BY  PHONE",
                      onTap: () async {

                       // processRegister = true;
                        loginButtonStreamer.sink.add(1);

                      var dialingCode = snapshot.data;
                      validator.setData({
                        "phoneNo":phoneController.text,
                        "dialingCode":dialingCode,
                      });
                      if(validator.validate()){

                        String phoneNo = dialingCode + phoneController.text;
                        AppConfig.log("HEREERRRRRR"+phoneNo);
                        await firebaseAuth.verifyPhoneNumber(
                            phoneNumber: phoneNo, timeout: Duration(seconds: 60),
                            verificationCompleted: autoVerify, verificationFailed: (AuthException ex){
                            AppConfig.log(ex.message);
                        }, codeSent: manualVerify, codeAutoRetrievalTimeout: (String vId){
                          AppConfig.log("TIMED OUT:"+ vId);
                        });
//                        validator.submit((){
//
//                        });
                      }else{
                        loginButtonStreamer.sink.add(null);
                        Toast.show(validator.getError(),context,
                            duration: Toast.LENGTH_LONG,
                            gravity: Toast.CENTER);
                      }
//                        loginButtonStreamer.sink.add(null);
//                      setState(() {
////                        processRegister = false;

//                      });
                    },),
                  );
                },
              )

            ],
          ),
        ),
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
        loginButtonStreamer.sink.add(2);
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) =>  SettingsScreen()
        ));
      }
    }
  }

  void manualVerify(String verificationId, [int forceToken]){

    List<String> data  = ["1","2","3","4","5","6"];
    AppConfig.log("Withing Manual Verify");
    setState(() {
      this.otpStreamer.sink.add(data);
      loginButtonStreamer.sink.add(2);
      otpButtonStreamer.sink.add(null);
      this.isOtpEnabled = true;

    });
    this.verificationId = verificationId;
  }

  @override
  void dispose() {
    otpStreamer.close();
    otpButtonStreamer.close();
    loginButtonStreamer.close();
    super.dispose();
  }
}

class LoginValidator implements FormValidator{
  dynamic data;
  BuildContext context;
  LoginValidator({this.context});

  @override
  setData<T>(T data) {
    this.data = data;
  }

  @override
  submit(Function stateChange) {
    AppConfig.log(data);
  }

  @override
  validate() {
    if(data['phoneNo'] == null || data['phoneNo']==""){
      error = "Phone No Required";
      return false;
    }

    return true;
  }

  handleOtpSubmit(String verificationId,String smsCode,Function callback) async{

    AuthCredential credential = PhoneAuthProvider.getCredential(verificationId: verificationId, smsCode: smsCode);
    AuthResult result = await firebaseAuth.signInWithCredential(credential);
    if(result.user != null) {
      AppConfig.log(result.user.displayName);

      UserService userService = UserService(userRepo: UserRepository());
      User currentUser = await userService.checkCurrentUser();
      bool verified = await userService.savePhoneVerification(verificationId, result.user.uid, currentUser.syncId);
      if(verified){
        callback();
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) =>  SettingsScreen()
        ));
      }
    }
  }

  @override
  getError(){
    return this.error;
  }

  @override
  String error;

}