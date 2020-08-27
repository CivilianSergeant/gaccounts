import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gaccounts/config/AppConfig.dart';
import 'package:gaccounts/persistance/DbProvider.dart';
import 'package:gaccounts/persistance/entity/User.dart';
import 'package:gaccounts/persistance/repository/UserRepository.dart';
import 'package:gaccounts/persistance/services/UserService.dart';
import 'package:gaccounts/screens/DashboardScreen.dart';
import 'package:gaccounts/screens/SettingsScreen.dart';
import 'package:gaccounts/screens/LoginScreen.dart';
import 'package:imei_plugin/imei_plugin.dart';
import 'package:sqflite/sqflite.dart';



class SplashScreen extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _SplashScreenState();

}

class _SplashScreenState extends State<SplashScreen>{



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          child: Center(child:Column(
            children: <Widget>[
              SizedBox(height: 150,),
              Text("gAccounts", style: TextStyle(
                  color: Color(0xff0f4f6f),
                  fontWeight: FontWeight.bold,
                  fontSize: 40
              ),),
              SizedBox(height: 70,),
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xff0e4b61)),
              ),
              SizedBox(height: 70,),
              Text("Loading ... ")
            ],
          )),
        ),
      ),
    );
  }

  @override
  void initState() {
    initDb().then((_) => checkCurrentUser());
  }

  Future<void> initDb() async {
    AppConfig.log("HERE INIT DB");
    final Database db = await DbProvider.db.database;
  }

  Future<void> checkCurrentUser() async {
    String imei = await ImeiPlugin.getImei(shouldShowRequestPermissionRationale: false);
    var service = UserService(userRepo: UserRepository());
    User user = await service.findUserByIMEI(imei);
    if(imei.toString().contains("Permission Denied")){
      exit(0);
    }else{
      if(user == null){

        Navigator.of(context).pushReplacementNamed('/register',arguments: {
          "imei": imei
        });
      }else{
        AppConfig.log(user.toMap());
        if(!user.isVerified){
          //show login screen
          Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (context) => LoginScreen()
          ));
//          Navigator.of(context).pushReplacementNamed('/dashboard');
        }else if(user.businessTypeId==0 || user.businessTypeId == null){
          Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) => SettingsScreen()
          ));
        }else{
          Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (context) => DashboardScreen()
          ));
        }
      }
      //AppConfig.debug("User"+user.toMap().toString());
      //
    }
  }
}