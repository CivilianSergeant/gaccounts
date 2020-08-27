import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gaccounts/config/AppConfig.dart';
import 'package:gaccounts/persistance/repository/AccTrxMasterRepository.dart';
import 'package:gaccounts/persistance/repository/ChartAccountRepository.dart';
import 'package:gaccounts/persistance/services/AccTrxMasterService.dart';
import 'package:gaccounts/persistance/services/ChartAccountService.dart';
import 'package:gaccounts/persistance/services/SyncService.dart';
import 'package:gaccounts/screens/ChartAccountScreen.dart';
import 'package:gaccounts/screens/VoucherEntryScreen.dart';
import 'package:gaccounts/screens/VoucherScreen.dart';
import 'package:gaccounts/screens/reports/BalanceSheetReport.dart';
import 'package:gaccounts/screens/reports/CashBookReport.dart';
import 'package:gaccounts/screens/reports/IncomeExpenseReport.dart';
import 'package:gaccounts/screens/reports/ReceivePaymentReport.dart';
import 'package:gaccounts/screens/reports/TrialBalanceReport.dart';
import 'package:toast/toast.dart';

class Sidebar extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _SidebarState();

}

class _SidebarState extends State<Sidebar> {

  GlobalKey _scaffoldKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Drawer(
        key: _scaffoldKey,
        child: Column(
          children: <Widget>[
            Container(
              color: Color(0xff006777),
              height: 180,
              width: MediaQuery.of(context).size.width,
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top:15.0),
                    child: SizedBox(
                      width:100,
                      height:100,
                      child:  Material(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50)
                          ),
                          color:Color(0xff008e8e),
                          child: Icon(
                              Icons.account_balance_wallet,size: 75,
                              color:Colors.white
                          )),
                    ),
                  ),
                  SizedBox(height: 20,),
                  Text("Welcome Username",style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold
                  ),)
                ],
              ),
            ),
            SizedBox(
              height: 0,
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.only(left:40,top:10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(top:10.0),
                        child: SizedBox(

                          width: 230,
                          child: Row(
                            children: <Widget>[
                              Text("Transaction",style: TextStyle(
                                  color: Colors.blueGrey
                              ),),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 30,
                        width: 230,
                        child: FlatButton(
                          child: Row(
                            children: <Widget>[
                              Icon(Icons.wrap_text),
                              SizedBox(width: 10,),
                              Text("Vouchers"),
                            ],
                          ),
                          onPressed: (){
                            Navigator.of(context).pop();
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context)=> VoucherScreen()
                            ));
                          },
                        ),
                      ),
                      SizedBox(
                        height: 30,
                        width: 230,
                        child: FlatButton(
                          child: Row(
                            children: <Widget>[
                              Icon(Icons.wrap_text),
                              SizedBox(width: 10,),
                              Text("Voucher Entry"),
                            ],
                          ),
                          onPressed: (){
                            Navigator.of(context).pop();
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context)=> VoucherEntryScreen()
                            ));
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top:30.0),
                        child: SizedBox(

                          width: 230,
                          child: Row(
                            children: <Widget>[
                              Text("Reports",style: TextStyle(
                                  color: Colors.blueGrey
                              ),),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top:8.0),
                        child: SizedBox(
                          height: 30,
                          width: 230,
                          child: FlatButton(
                            child: Row(
                              children: <Widget>[
                                Icon(Icons.grid_on),
                                SizedBox(width: 10,),
                                Text("Cash Book"),
                              ],
                            ),
                            onPressed: (){
                              Navigator.of(context).pop();
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context)=> CashBookReport()
                              ));
                            },
                          ),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.only(top:8.0),
                        child: SizedBox(
                          height: 30,
                          width: 230,
                          child: FlatButton(
                            child: Row(
                              children: <Widget>[
                                Icon(Icons.grid_on),
                                SizedBox(width: 10,),
                                Text("Income & Expense"),
                              ],
                            ),
                            onPressed: (){
                              Navigator.of(context).pop();
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context)=> IncomeExpenseReport()
                              ));
                            },
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top:8.0),
                        child: SizedBox(
                          height: 30,
                          width: 230,
                          child: FlatButton(
                            child: Row(
                              children: <Widget>[
                                Icon(Icons.grid_on),
                                SizedBox(width: 10,),
                                Text("Receipts & Payment"),
                              ],
                            ),
                            onPressed: (){
                              Navigator.of(context).pop();
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context)=> ReceivePaymentReport()
                              ));
                            },
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top:8.0),
                        child: SizedBox(
                          height: 30,
                          width: 230,
                          child: FlatButton(
                            child: Row(
                              children: <Widget>[
                                Icon(Icons.grid_on),
                                SizedBox(width: 10,),
                                Text("Trial Balance"),
                              ],
                            ),
                            onPressed: (){
                              Navigator.of(context).pop();
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context)=> TrialBalanceReport()
                              ));
                            },
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top:8.0),
                        child: SizedBox(
                          height: 30,
                          width: 230,
                          child: FlatButton(
                            child: Row(
                              children: <Widget>[
                                Icon(Icons.grid_on),
                                SizedBox(width: 10,),
                                Text("Balance Sheet"),
                              ],
                            ),
                            onPressed: (){
                              Navigator.of(context).pop();
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context)=> BalanceSheetReport()
                              ));
                            },
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top:30.0),
                        child: SizedBox(

                          width: 230,
                          child: Row(
                            children: <Widget>[
                              Text("Settings",style: TextStyle(
                                  color: Colors.blueGrey
                              ),),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top:8.0),
                        child: SizedBox(
                          height: 30,
                          width: 230,
                          child: FlatButton(
                            child: Row(
                              children: <Widget>[
                                Icon(Icons.grid_on),
                                SizedBox(width: 10,),
                                Text("Chart of Accounts"),
                              ],
                            ),
                            onPressed: (){
                              Navigator.of(context).pop();
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context)=> ChartAccountScreen()
                              ));
                            },
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top:8.0),
                        child: SizedBox(
                          height: 30,
                          width: 230,
                          child: FlatButton(
                            child: Row(
                              children: <Widget>[
                                Icon(Icons.cloud_upload),
                                SizedBox(width: 10,),
                                Text("Sync / Upload Data"),
                              ],
                            ),
                            onPressed: () async {
                              Navigator.of(context).pop();
                              Navigator.of(context).pushNamed('/sync');
                            },
                          ),
                        ),
                      ),
                      SizedBox(height: 20,)
                    ],
                  ),
                ),
              ),
            )
          ],
        )
    );
  }

}