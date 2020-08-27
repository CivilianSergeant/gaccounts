import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gaccounts/config/AppConfig.dart';
import 'package:gaccounts/persistance/entity/User.dart';
import 'package:gaccounts/persistance/repository/BusinessTypeRepository.dart';
import 'package:gaccounts/persistance/repository/ChartAccountRepository.dart';
import 'package:gaccounts/persistance/repository/UserRepository.dart';
import 'package:gaccounts/persistance/services/BusinessTypeService.dart';
import 'package:gaccounts/persistance/services/ChartAccountService.dart';
import 'package:gaccounts/persistance/services/UserService.dart';
import 'package:gaccounts/screens/LoginScreen.dart';
import 'package:gaccounts/screens/SplashScreen.dart';
import 'package:gaccounts/widgets/ActionButton.dart';
import 'package:toast/toast.dart';

class SettingsScreen extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _SettingsScreenState();

}

class _SettingsScreenState extends State<SettingsScreen>{

  int _selectedType;
  int _selectSubType;
  bool loading = false;

  List<Map<String,dynamic>> businessTypes;
  List<DropdownMenuItem<int>> subTypeItems = [];
  List<dynamic> chartAccounts = [];

  loadBusinessTypes() async{

    BusinessTypeService businessTypeService = BusinessTypeService(
      repository: BusinessTypeRepository()
    );

    List<Map<String,dynamic>> _businessTypes = await businessTypeService.getParentTypes();

    if(mounted) {
      setState(() {
        businessTypes = _businessTypes;
      });
    }
    AppConfig.log(businessTypes);
  }


  @override
  void initState() {
    loadBusinessTypes();
  }

  List<DropdownMenuItem<int>> getBusinessTypeItems(){

    List<DropdownMenuItem<int>> _types = [];
    if(businessTypes != null) {
      businessTypes.forEach((Map<String, dynamic> map) {
        _types.add(DropdownMenuItem(
            value: map['id'],
            child: Text(map['title'])
        ));
      });
    }


    return _types;
  }

  Future<void> loadBusinessSubType(int parentId) async{
    BusinessTypeService businessTypeService = BusinessTypeService(
        repository: BusinessTypeRepository()
    );
    List<Map<String,dynamic>> _subTypes = await businessTypeService.getChildTypes(parentId);
    List<DropdownMenuItem<int>> _subTypeItems = [];
    _subTypes.forEach((subType) {
      _subTypeItems.add(DropdownMenuItem(
        child: Text(subType['title']),
        value: subType['id'],
      ));
    });

    if(mounted){
      setState(() {
        subTypeItems = _subTypeItems;
      });
    }
  }

  Future<List<dynamic>> loadChartAccountsFromServer() async {
    setState(() {
      chartAccounts = [];
      loading= true;
    });
    ChartAccountService chartAccountService = new ChartAccountService(repo: ChartAccountRepository());
    if(!await chartAccountService.checkNetwork()){
      setState(() {
        loading=false;
        _selectSubType=null;
      });
      Toast.show("Please Make sure Internet available",context,
      duration: Toast.LENGTH_LONG,gravity: Toast.CENTER);
      return null;
    }
    List<dynamic> results = await chartAccountService.getChartAccountByBusinessTypeFromServer(_selectSubType);

    List<dynamic> _chartAccounts = [];
    results.forEach((r) {
      dynamic cA = r;
      cA['selected'] = true;
      _chartAccounts.add(cA);
    });
    AppConfig.log("LINE:88 "+_chartAccounts.toString());
    setState(() {
      loading=false;
      chartAccounts = _chartAccounts;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Padding(
            padding: EdgeInsets.only(left: 0),
            child: Align(

              alignment: Alignment.center,
              child:Text("Application Settings",style: TextStyle(

              ),
              ),
            ),
          )
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(20),
            height: MediaQuery.of(context).size.height-80,
            alignment: Alignment.topCenter,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  width: 280,

                    child: Text("Business Type")),
                SizedBox(
                  width: 280,
                  child: DropdownButton(
                    value: _selectedType,
                    items: getBusinessTypeItems(),
                    hint:Text("Select Business Type") ,
                    onChanged: (value){
                      setState(() {
                        _selectedType  = value;
                        loadBusinessSubType(value);
                      });
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top:10),
                  child: SizedBox(
                      width: 280,

                      child: Text("Sub Type")),
                ),
                SizedBox(
                  width: 280,
                  child: DropdownButton(
                    value: _selectSubType,
                    items: subTypeItems,
                    hint:Text("Select Sub Type"),
                    onChanged: (value){
                      setState(() {
                        _selectSubType  = value;

                        loadChartAccountsFromServer();
                      });
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top:20),
                  child: SizedBox(
                      width: 280,

                      child: Text("List of Chart Accounts"),
                  ),
                ),

                Container(
                  height: MediaQuery.of(context).size.height-370,
                  width: 280,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color:Color(0xffacacac)
                    )
                  ),
                  child: (chartAccounts.length==0 && loading)? Container(
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ) : showList(),
                ),
                SizedBox(
                  height: 20,
                ),
                ActionButton(
                  onTap: ()async{
                    if(chartAccounts.length<=0){
                      Toast.show("Please Select Business Type and sub type to load Chart Accounts", context,
                      duration: Toast.LENGTH_LONG,gravity: Toast.CENTER);
                      return;
                    }

                    UserService userService = UserService(userRepo: UserRepository());
                    bool netState = await userService.checkNetwork();
                    if(!netState){
                      Toast.show("Please Make sure Internet available.", context,
                          duration: Toast.LENGTH_LONG,gravity: Toast.CENTER);
                      return;
                    }
                    User user = await userService.checkCurrentUser();

                    AppConfig.log(user.toMap());

                   int updated = await userService.updateBusinessType(user,_selectSubType);
                   AppConfig.log("UPDATED : "+updated.toString());
                    ChartAccountService charAccountService = ChartAccountService(repo: ChartAccountRepository());
//                    await charAccountService.remove();
                    int inserted = await charAccountService.addChartAccounts(chartAccounts);
                    AppConfig.log("Total Inserted CA: "+inserted.toString());
                    if(inserted>0){
                      Navigator.of(context).pushReplacementNamed('/dashboard');
                    }
                  },
                  caption: "Save Settings",
                )
              ],
            )
          ),
        ),
      ),
    );
  }

  Widget showList(){
    return ListView.builder(
      itemCount: chartAccounts.length,
      itemBuilder: (context,i){
        var account = chartAccounts[i];
//                        AppConfig.debug("HERE LINE 188: "+account.toString());
        if(account == null){
          return Container(
              child: Center(
                child: Text("Loading...."),
              )
          );
        }
        return SizedBox(
          height: 35,
          child: CheckboxListTile(
            dense: true,
            value: account['selected'],
            title: Text("${account['accCode']} - ${account['accName']}"),
            controlAffinity: ListTileControlAffinity.leading,
            onChanged: (value){
              setState(() {
                account['selected'] = value;
              });
              AppConfig.log(value);
            },
          ),
        );
      },

    );
  }

}