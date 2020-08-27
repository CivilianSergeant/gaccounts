import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gaccounts/persistance/entity/User.dart';
import 'package:gaccounts/persistance/repository/UserRepository.dart';
import 'package:gaccounts/persistance/services/UserService.dart';
import 'package:gaccounts/screens/ChartAccountScreen.dart';
import 'package:gaccounts/screens/SettingsScreen.dart';
import 'package:gaccounts/widgets/OverviewButton.dart';
import 'package:gaccounts/widgets/Sidebar.dart';
import 'package:imei_plugin/imei_plugin.dart';



class DashboardScreen extends StatefulWidget{



  @override
  State<StatefulWidget> createState() => _DashboardScreenState();

}

class _DashboardScreenState extends State<DashboardScreen>{

  UserService userService = UserService(userRepo: UserRepository());


  @override
  void didChangeDependencies() {
    Map<String,dynamic> obj = ModalRoute.of(context).settings.arguments;
//    obj['']
    userService.checkCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: Padding(
            padding: const EdgeInsets.only(left:60),
            child: Align(

              alignment: Alignment.centerLeft,
              child:Text("gAccounts",style: TextStyle(

                ),
              ),
            ),
          )
        ),
        drawer: SafeArea(
          child: Sidebar(),
        ),
        body: SafeArea(
          child: Container(
            padding: EdgeInsets.all(10),
            child: Column(

              children: <Widget>[
                SizedBox(height: 20,),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    OverviewButton(color: Colors.deepOrange,text: "Payment",),
                    OverviewButton(color: Color(0xff005e5e),text: "Recieve",)
                  ],
                ),
                SizedBox(height: 10,),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    OverviewButton(color: Color(0xf5f05e5e),text: "Purchase",),
                    OverviewButton(color: Colors.orange,text: "Sale",)

                  ],
                )
              ],
            )
          ),
        ),
      );
  }

}