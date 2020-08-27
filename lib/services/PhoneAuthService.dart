import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gaccounts/config/AppConfig.dart';
import 'package:toast/toast.dart';

abstract class PhoneAuthService{

  static FirebaseAuth auth =  FirebaseAuth.instance;

  static verifyPhone(String phoneNo, BuildContext context,
      Function autoVerify, Function manualVerify){

    var verificationCompleted = (AuthCredential authCredential){
      autoVerify(authCredential, auth);
    };

    var verificationFailed = (AuthException exception){
      Toast.show(exception.message,context,
      duration: Toast.LENGTH_LONG,gravity: Toast.CENTER);
    };

    var codeSent = (String verificationID, [int forceToken]){
      manualVerify(verificationID, forceToken, auth);
    };

    var autoRetrievalTimeout = (String verificationId){
      AppConfig.log("Timeout "+verificationId);
    };

    auth.verifyPhoneNumber(
        phoneNumber: phoneNo,
        timeout: Duration(seconds: 60),
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed,
        codeSent: codeSent,
        codeAutoRetrievalTimeout: autoRetrievalTimeout);

  }

  static getInstance(){
    return auth;
  }

}