import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gaccounts/config/AppConfig.dart';
import 'package:gaccounts/persistance/entity/User.dart';
import 'package:gaccounts/persistance/repository/AccTrxMasterRepository.dart';
import 'package:gaccounts/persistance/repository/ProfileRepository.dart';
import 'package:gaccounts/persistance/repository/UserRepository.dart';
import 'package:gaccounts/persistance/services/AccTrxMasterService.dart';
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

  UserService userService = UserService(userRepo: UserRepository(profileRepo: ProfileRepository()));
  Map<String,dynamic> payment;
  Map<String,dynamic> receipt;
  Map<String,dynamic> purchase;
  Map<String,dynamic> sale;

  String name;

  @override
  void didChangeDependencies() {
    Map<String,dynamic> obj = ModalRoute.of(context).settings.arguments;



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
          child: Sidebar(name: name,),
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
                    OverviewButton(color: Colors.deepOrange,text: "Payment",total: (payment!=null)? payment['debit']:0,),
                    OverviewButton(color: Color(0xff005e5e),text: "Recieve",total:(receipt!=null)?receipt['credit']:0)
                  ],
                ),
                SizedBox(height: 10,),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    OverviewButton(color: Color(0xf5f05e5e),text: "Purchase",total:(purchase!=null)?purchase['debit']:0),
                    OverviewButton(color: Colors.orange,text: "Sale",total: (sale!=null)? sale['credit']:0,)

                  ],
                )
              ],
            )
          ),
        ),
      );
  }

  @override
  void initState() {
    loadDashBoardData();
  }

  Future<void> loadDashBoardData() async{
    AccTrxMasterService accTrxMasterService = AccTrxMasterService(masterRepo: AccTrxMasterRepository());
    List<Map<String,dynamic>> payments = [];
    payments = await accTrxMasterService.getVoucherSummary('payment');
    List<Map<String,dynamic>> receipts = await accTrxMasterService.getVoucherSummary('received');
    List<Map<String,dynamic>> purchases = await accTrxMasterService.getVoucherSummary('cash-purchase');
    List<Map<String,dynamic>> sales = await accTrxMasterService.getVoucherSummary('cash-sales');

    AppConfig.log(payments,line:"103",className: "Dashboard");
    AppConfig.log(receipts,line:"103",className: "Dashboard");
    AppConfig.log(purchases,line:"103",className: "Dashboard");
    AppConfig.log(sales,line:"103",className: "Dashboard");
    User user = await userService.checkCurrentUser();
    Map<String,dynamic> profile = await userService.getProfile(user.profileId);
    AppConfig.log(profile);
    setState(() {
      name = (profile!=null)? profile['name']:'';
      payment = (payments.length>0)? payments.first : null;
      receipt = (receipts.length>0)? receipts.first:null;
      purchase = (purchases.length>0)? purchases.first: null;
      sale     = (sales.length>0)? sales.first:null;
    });


  }
}
