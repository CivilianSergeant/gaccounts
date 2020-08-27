import 'package:flutter/material.dart';
import 'package:gaccounts/persistance/services/SyncService.dart';
import 'package:toast/toast.dart';

class SyncScreen extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _SyncScreenState();


}

class _SyncScreenState extends State<SyncScreen>{

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
                  Center(child: Text("Uploading",style: TextStyle(
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
    syncData();
  }

  Future<void> syncData() async{
    //Navigator.of(context).pop();


    if(isProcessing){
      return;
    }
    setState(() {
      isProcessing=true;
    });
    SyncService syncService = SyncService();

    dynamic result = await syncService.syncData();
    if(result['status']>0){


      Toast.show(result['message'],context,duration:Toast.LENGTH_LONG,gravity: Toast.CENTER);
    }else{
      Toast.show(result['message'],context,duration:Toast.LENGTH_LONG,gravity: Toast.CENTER);
//                              Navigator.of(context).pop();
    }

    Navigator.of(context).pop();
    setState(() {
      isProcessing=false;
    });
  }
}