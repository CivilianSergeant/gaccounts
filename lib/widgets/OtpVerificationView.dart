import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gaccounts/config/AppConfig.dart';

import 'ActionButton.dart';
import 'TextFieldExt.dart';

class OtpVerificationView extends StatefulWidget{

  String value1;
  String value2;
  String value3;
  String value4;
  String value5;
  String value6;
  Function onActionClick;
  Stream buttonStream;


  OtpVerificationView({
    this.value1,
    this.value2,
    this.value3,
    this.value4,
    this.value5,
    this.value6,
    this.buttonStream,
    this.onActionClick
  });

  @override
  State<StatefulWidget> createState() => _OtpViewState();
  
}

class _OtpViewState extends State<OtpVerificationView>{

  TextEditingController key1 = TextEditingController();
  TextEditingController key2 = TextEditingController();
  TextEditingController key3 = TextEditingController();
  TextEditingController key4 = TextEditingController();
  TextEditingController key5 = TextEditingController();
  TextEditingController key6 = TextEditingController();

  FocusNode focusNode1 = FocusNode();
  FocusNode focusNode2 = FocusNode();
  FocusNode focusNode3 = FocusNode();
  FocusNode focusNode4 = FocusNode();
  FocusNode focusNode5 = FocusNode();
  FocusNode focusNode6 = FocusNode();
  FocusNode buttonFocus = FocusNode();
  String temp;

  onTextChange1(value){

    if(key1.text.length>0) {
      nexKey(key1, key2);
      FocusScope.of(context).requestFocus(focusNode2);

    }

  }
  onTextChange2(value){


    if(key2.text.length == 0) {
      FocusScope.of(context).requestFocus(focusNode1);
    }else{

      nexKey(key2, key3);
      FocusScope.of(context).requestFocus(focusNode3);
    }
  }
  onTextChange3(value){

    if(key3.text.length==0) {
      FocusScope.of(context).requestFocus(focusNode2);
    }else{
      nexKey(key3, key4);
      FocusScope.of(context).requestFocus(focusNode4);
    }

  }
  onTextChange4(value){

    if(key4.text.length==0){
      FocusScope.of(context).requestFocus(focusNode3);
    }else {

      nexKey(key4, key5);
      FocusScope.of(context).requestFocus(focusNode5);
    }

  }
  onTextChange5(value){

    if(key5.text.length==0){
      FocusScope.of(context).requestFocus(focusNode4);
    }else {
      if(key5.text.length>1){

        nexKey(key5, key6,isLast: true);
      }else{
        FocusScope.of(context).requestFocus(focusNode6);
      }

    }

  }

  onTextChange6(value){
    if(key6.text.length==0) {
      FocusScope.of(context).requestFocus(focusNode5);
    }else{
      AppConfig.log("LSLSLS");
      FocusScope.of(context)
          .requestFocus(FocusNode());
    }
  }

  void nexKey(dynamic currentkey, dynamic nexkey,{bool isLast}){
    if(currentkey.text.length>1){
      temp = currentkey.text.substring(1);
      currentkey.text = currentkey.text.substring(0,1);
      nexkey.text = temp;
      temp = '';
      if(isLast != null && isLast == true){
        AppConfig.log("LSLSLSDDDD");
        FocusScope.of(context)
            .requestFocus(FocusNode());
      }
    }
  }


  @override
  void didChangeDependencies() {

    if(widget.value1 != null) {
      key1.text = widget.value1;
    }

    if(widget.value2 != null){
      key2.text = widget.value2;
    }

    if(widget.value3 != null){
      key3.text = widget.value3;
    }

    if(widget.value4 != null){
      key4.text = widget.value4;
    }

    if(widget.value5 != null){
      key5.text = widget.value5;
    }

    if(widget.value6 != null) {
      key6.text = widget.value6;
    }

    if(key1.text == null){
      FocusScope.of(context).requestFocus(focusNode1);
    }
//    if(key2.text == null){
//      FocusScope.of(context).requestFocus(focusNode2);
//    }
//    if(key3.text == null){
//      FocusScope.of(context).requestFocus(focusNode3);
//    }
//    if(key4.text == null){
//      FocusScope.of(context).requestFocus(focusNode4);
//    }
//    if(key5.text == null){
//      FocusScope.of(context).requestFocus(focusNode5);
//    }
//    if(key6.text == null){
//      FocusScope.of(context).requestFocus(focusNode6);
//    }

//    FocusScope.of(context).requestFocus(focusNode1);
  }


  @override
  Widget build(BuildContext context) {

    return Container(
        color: Colors.white,
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Column(

            children: <Widget>[
              SizedBox(
                height: 120,
              ),
              Text("OTP VERIFICATION",style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.none,
                  color: Colors.teal
              ),),
              SizedBox(height: 40,),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  SizedBox(
                    width: 50,
                    child: TextFieldExt(hintText: "",topPad: 15,
                      keyboardType: TextInputType.number,
                      focusNode: focusNode1,
                      textPadLeft: 18,
                      leftPad: 7,
                      rightPad: 0,
                      onChange: onTextChange1,
                      onTapSelection: true,
                      controller: key1,borderRadius: 10,),
                  ),
                  SizedBox(
                    width: 50,
                    child: TextFieldExt(hintText: "",topPad: 15,
                      keyboardType: TextInputType.number,
                      focusNode: focusNode2,
                      textPadLeft: 18,
                      leftPad: 7,
                      rightPad: 0,
                      onChange: onTextChange2,
                      onTapSelection: true,
                      controller: key2,borderRadius: 10,),
                  ),
                  SizedBox(
                    width: 50,
                    child: TextFieldExt(hintText: "",topPad: 15,
                      focusNode: focusNode3,
                      textPadLeft: 18,
                      leftPad: 7,
                      rightPad: 0,
                      keyboardType: TextInputType.number,
                      onChange: onTextChange3,
                      onTapSelection: true,
                      controller: key3,borderRadius: 10,),
                  ),
                  SizedBox(
                    width: 50,
                    child: TextFieldExt(hintText: "",topPad: 15,
                      focusNode: focusNode4,
                      textPadLeft: 18,
                      leftPad: 7,
                      rightPad: 0,
                      keyboardType: TextInputType.number,
                      onChange: onTextChange4,
                      onTapSelection: true,
                      controller: key4,borderRadius: 10,),
                  ),
                  SizedBox(
                    width: 50,
                    child: TextFieldExt(hintText: "",topPad: 15,
                      focusNode: focusNode5,
                      textPadLeft: 18,
                      leftPad: 7,
                      rightPad: 0,
                      keyboardType: TextInputType.number,
                      onChange: onTextChange5,
                      onTapSelection: true,
                      controller: key5,borderRadius: 10,),
                  ),
                  SizedBox(
                    width: 50,
                    child: TextFieldExt(hintText: "",topPad: 15,
                      focusNode: focusNode6,
                      textPadLeft: 18,
                      leftPad: 7,
                      rightPad: 0,
                      keyboardType: TextInputType.number,
                      onChange: onTextChange6,
                      onTapSelection: true,
                      controller: key6,borderRadius: 10,),
                  )
                ],
              ),
              Padding(
                  padding: EdgeInsets.only(left: 20,right: 20,top: 40),
                  child:ActionButton(
                    buttonFocus: buttonFocus,
                    stream: widget.buttonStream,
                    caption: "Submit OTP",
                    onTap: ()async{
                      var value = {
                        'key1':key1.text,
                        'key2':key2.text,
                        'key3':key3.text,
                        'key4':key4.text,
                        'key5':key5.text,
                        'key6':key6.text
                      };
                       await widget.onActionClick(value);
                    },
                  )
              )
            ])
    );
  }

  @override
  void initState() {

  }
}