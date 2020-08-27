import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gaccounts/config/AppConfig.dart';
import 'package:gaccounts/persistance/entity/ChartAccount.dart';
import 'package:gaccounts/persistance/entity/User.dart';
import 'package:gaccounts/persistance/repository/ChartAccountRepository.dart';
import 'package:gaccounts/persistance/repository/UserRepository.dart';
import 'package:gaccounts/persistance/services/ChartAccountService.dart';
import 'package:gaccounts/persistance/services/UserService.dart';
import 'package:gaccounts/widgets/ActionButton.dart';
import 'package:gaccounts/widgets/TextFieldExt.dart';
import 'package:toast/toast.dart';

class ChartAccountScreen extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _ChartAccountScreenState();

}

class _ChartAccountScreenState extends State<ChartAccountScreen> {

  List<Map<String,dynamic>> chartAccounts = [];
  List<DropdownMenuItem<Map<String,dynamic>>> chartAccountDropDownList = [];
  bool isNew = false;
  bool isProcessing = false;
  String title;

  Map<String,dynamic> selectedCA;
  List<DropdownMenuItem<String>> voucherTypes = [];
  StreamController<int> buttonStream = StreamController<int>.broadcast();

  TextEditingController accName = TextEditingController();
  TextEditingController accNameUpdate = TextEditingController();
  TextEditingController accCode = TextEditingController();

  Map<String, dynamic> selectedAcount;

  Future<void> loadChartAccounts() async {
    List<Map<String,dynamic>> _ca = [];
    ChartAccountService chartAccountService = ChartAccountService(repo:ChartAccountRepository());
    List<Map<String,dynamic>> results = await chartAccountService.getChartAccounts();
    List<DropdownMenuItem<Map<String,dynamic>>> _charAccountDropDownList = [];

    results.forEach((element) {
      if(element['group_id']!=3) {
        _charAccountDropDownList.add(DropdownMenuItem(
          child: Text("${element['acc_code']} - ${element['acc_name']}"),
          value: element,
        ));
      }

      if(element['acc_level']!=1 && element['acc_level']!=2) {
        _ca.add({
          "id": element['id'],
          "acc_id": element['acc_id'],
          "acc_code": element['acc_code'],
          "acc_name": element['acc_name'],
          "is_sync": element['is_sync'],
          "acc_level": element['acc_level'],
          "is_selected": (element['is_selected'] != 0) ? true : false
        });
      }
    });

    if(mounted) {
      setState(() {
        chartAccounts = _ca;
        chartAccountDropDownList = _charAccountDropDownList;
        title = "Chart of Accounts";
      });
    }
  }

  Future<void> activeAccount(bool value, int accId) async{
    ChartAccountService chartAccountService = ChartAccountService(repo: ChartAccountRepository());
    var val = (value)? 1:0;
    int updated = await chartAccountService.activeAccount(val, accId);
    AppConfig.log(updated);
  }


  @override
  void initState() {
    loadChartAccounts();

  }


  @override
  void dispose() {
    buttonStream.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Padding(
              padding: EdgeInsets.only(left:0),
              child: Align(

                alignment: Alignment.center,
                child:Text("${(title!=null)? title: ''}",style: TextStyle(

                ),
                ),
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: Icon(Icons.add,color: Colors.white,),
                onPressed: (){
                  setState(() {
                    if(isNew == true){
                      return;
                    }

                    isNew = true;
                    title = "New Chart Account";
                  });
                },
              )
            ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height-75,
            padding: EdgeInsets.all(10),
            child: (isNew)? showForm() : showList(),
            )
          )
        ),

    );
  }

  Widget showForm(){
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,

      child: Column(
        children:<Widget>[
          Container(
              margin: EdgeInsets.only(top: 20),

              child:DropdownButton(
                items: chartAccountDropDownList ,
                value: selectedCA,
                hint: Text("Select Account Reference"),
                onChanged: (value) async{
                  ChartAccountService chartAccService = ChartAccountService(repo: ChartAccountRepository());
                  dynamic result = await chartAccService.getthirdLevelAccCode(value['second_level']);
                  if(result['status']<1){
                    Toast.show(result['message'], context,duration: Toast.LENGTH_LONG,gravity: Toast.CENTER);
                    return;
                  }
                  accCode.text = result['accCode'];
                  setState(() {
                    selectedCA = value;
                  });
                },
              )
          ),
        TextFieldExt(hintText: "Account Name",icon: Icons.account_box,topPad: 15,
            controller: accName,borderRadius: 50,),
        TextFieldExt(hintText: "Account Code",icon: Icons.code,topPad: 15,
            controller: accCode,borderRadius: 50,readonly:true),


        Spacer(),
        ActionButton(
          stream: buttonStream.stream,
          caption: "Save Chart Account",
          color: Color(0xff006600),
          onTap: handleSave()
        ),
          SizedBox(height: 20,),
          ActionButton(
            caption: "Cancel",
            onTap: (){
              buttonStream.sink.add(null);
              reset();

              loadChartAccounts();
            },
          )


      ],
    ));
  }

  Function handleSave()  {

    if(accName.text.length==0 ||
      accCode.text.length==0 ||
      selectedCA == null
      ){
      return null;
    }

    return saveChartAccount;
  }

  void handleUpdate() async {


    selectedAcount['acc_name'] = accNameUpdate.text;
    ChartAccountService chartAccountService = ChartAccountService(repo: ChartAccountRepository());
    int updated = await chartAccountService.updateChartAccount(selectedAcount);
    AppConfig.log("UPDATED: "+updated.toString());
    if(updated>0) {
      loadChartAccounts();
    }
    Navigator.of(context).pop();
  }



  void saveChartAccount() async{

      setState(() {
        isProcessing = true;
      });
      buttonStream.sink.add(1);
      UserService userService = UserService(userRepo: UserRepository());
      User user = await userService.checkCurrentUser();
      ChartAccountService service = ChartAccountService(repo: ChartAccountRepository());
//      dynamic account = await service.findAccountByCodeFromServer(accCode.text);

      if(accName.text.length==0){
        Toast.show("Please Write Account Name", context,
            duration: Toast.LENGTH_LONG, gravity: Toast.CENTER);
        buttonStream.sink.add(null);
        return;
      }

      if(accCode.text.length==0){
        Toast.show("Please Write Account Code", context,
            duration: Toast.LENGTH_LONG, gravity: Toast.CENTER);
        buttonStream.sink.add(null);
        return;
      }
      if(selectedCA == null){
        Toast.show("Please Select Account Reference", context,
            duration: Toast.LENGTH_LONG, gravity: Toast.CENTER);
        buttonStream.sink.add(null);
        return;
      }

      dynamic result = await service.addChartAccount(ChartAccount(
          accName: accName.text,
          accCode: accCode.text,
          nature: selectedCA['nature'],
          accLevel: selectedCA['acc_level'],
          firstLevel: selectedCA['first_level'],
          secondLevel: selectedCA['second_level'],
          thirdLevel: accCode.text,
          fourthLevel: null,
          fifthLevel: null,
          categoryId: selectedCA['category_id'],
          isSync: false,
          isTransaction: (selectedCA['is_transaction']==1)? true: false,
          isSelected: true,
          groupId: selectedCA['group_id'],
          voucherType: selectedCA['voucher_type']

      ),user);

      if(result['status']>0) {
        Toast.show("Account " + accName.text + " Created Successfully", context,
            duration: Toast.LENGTH_LONG, gravity: Toast.CENTER);
        buttonStream.sink.add(2);
        setState(() {
          isProcessing = false;
        });
        reset();
        loadChartAccounts();
      }else if(result['status'] == -2 || result['status']==-1){
        setState(() {
          isProcessing = false;
        });
        Toast.show(result['message'], context,
            duration: Toast.LENGTH_LONG, gravity: Toast.CENTER);
        buttonStream.sink.add(null);
        return;
      }




  }

  Widget showSyncIcon(account){
//    AppConfig.debug(account);
    return (account['is_sync']==1)? Icon(

      Icons.check_circle,
      color: Color(0xff009900),
    ): Icon(Icons.sync_problem,color: Colors.indigo,);
  }

  void reset(){
    setState(() {
      isNew=false;
      selectedCA=null;
      accName.text='';
      accCode.text='';
    });
  }

  Widget showList(){
    return ListView.separated(
        itemCount: chartAccounts.length,
        separatorBuilder: (context,i){
          return Divider();
        },
        itemBuilder: (context,i){
          var chartAccount = chartAccounts[i];

          return (chartAccount != null)? SwitchListTile(

            value: chartAccount['is_selected'],
            onChanged: (value){
              setState(() {
                chartAccount['is_selected'] = value;
              });
              activeAccount(value, chartAccount['acc_id']);
            },
            title:  InkWell(
              onLongPress: (){
                AppConfig.log('Pressed');
                setState(() {
                  selectedAcount = chartAccount;
                  accNameUpdate.text = chartAccount['acc_name'];
                });
                showDialog(context: context,
                    barrierDismissible: false,
                    builder: (context){

                  return SingleChildScrollView(
                    child: Container(
                      height: MediaQuery.of(context).size.height,
                      color: Colors.white70,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.only(left: 25,top: 10),
                            child: Text("Account Name",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                              decoration: TextDecoration.none
                            ),),
                          ),
                          TextFieldExt(hintText: "Account Name",icon: Icons.account_box,topPad: 15,
                            controller: accNameUpdate,borderRadius: 50,),
                          Padding(
                            padding: EdgeInsets.only(left: 25,top: 10),
                            child:Text("Account Code : "+chartAccount['acc_code'], style: TextStyle(
                                  fontSize: 16,
                              color:Colors.black,
                              decoration: TextDecoration.none
                          ),)),
                          SizedBox(height: 10,),
                          Padding(
                            padding: const EdgeInsets.only(left:20),
                            child: ActionButton(
                              width: 320,
                              caption: "Update Chart Account",
                              onTap: handleUpdate,
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                });

              },
              child:Row(
              children: <Widget>[
                showSyncIcon(chartAccount),
                Container(
                  width: 208,
                  child: Text("${chartAccount['acc_code']} - ${chartAccount['acc_name']}"),
                )
              ],
            ),

          )): SizedBox.shrink();
        });
  }

}