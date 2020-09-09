import 'package:flutter/material.dart';
import 'package:gaccounts/config/AppConfig.dart';
import 'package:gaccounts/persistance/entity/User.dart';
import 'package:gaccounts/persistance/repository/UserRepository.dart';
import 'package:gaccounts/persistance/services/SyncService.dart';
import 'package:gaccounts/persistance/services/UserService.dart';
import 'package:toast/toast.dart';

class SyncDownloadScreen extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _SyncDownloadScreenState();

}

class _SyncDownloadScreenState extends State<SyncDownloadScreen>{

  bool isProcessing=false;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async{
        if(isProcessing){
          return false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.white30,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Container(
              color: Colors.white12,
              height: MediaQuery.of(context).size.height,
              child: Stack(
                children: <Widget>[
                  Center(
                    child: SizedBox(
                        width:150,
                        height: 150,
                        child: CircularProgressIndicator()
                    ),
                  ),
                  Center(child: Text("Downloading",style: TextStyle(
                      color: Colors.white,fontWeight: FontWeight.w600,
                      fontSize: 16
                  ),))
                ],

              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void initState() {

  }


  @override
  void didChangeDependencies() {
    dynamic fetchStatus =  ModalRoute.of(context).settings.arguments;
    syncDownload(fetchStatus);
  }

  Future<void> syncDownload(dynamic fetchStatus) async{

    if(isProcessing){
      return;
    }
    setState(() {
      isProcessing=true;
    });
    SyncService syncService = SyncService();
    UserService userService = UserService(userRepo: UserRepository());
    User user = await userService.checkCurrentUser();
    dynamic result = await syncService.syncDataDownload(user);
    AppConfig.log(result);
    if(result['status'] != null){
      if (result['status'] > 0) {
        if(result['status'] == 404 || result['status'] == 500){
          Navigator.of(context).pop();
          Toast.show("Sorry! Invalid Request", context,duration: Toast.LENGTH_LONG,gravity: Toast.CENTER);
        }else {
          Toast.show(result['message'], context, duration: Toast.LENGTH_LONG,
              gravity: Toast.CENTER);
        }
      } else {
        Navigator.of(context).pop();
        Toast.show(result['message'], context, duration: Toast.LENGTH_LONG,
            gravity: Toast.CENTER);
      }

    }
    if(fetchStatus!=null){
      Navigator.of(context).pop();
    }
    Navigator.of(context).pop();

    setState(() {
      isProcessing=false;
    });
  }

}