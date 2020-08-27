import 'package:flutter/material.dart';
import 'package:gaccounts/config/AppConfig.dart';

class TextFieldExt extends StatefulWidget{

  IconData icon;
  String hintText;
  double topPad;
  TextEditingController controller;
  TextInputType keyboardType;
  final double borderRadius;
  double textPadLeft;
  double textPadRight;
  double textPadTop;
  double textPadBottom;
  double leftPad;
  double rightPad;
  FocusNode focusNode;
  Function onChange;
  bool onTapSelection;
  bool readonly;
  Function onTap;

  TextFieldExt({Key key, this.icon,this.hintText,this.topPad,
    this.controller,
    this.keyboardType,
    this.borderRadius,
    this.textPadBottom,
    this.textPadTop,
    this.textPadRight,
    this.textPadLeft,
    this.leftPad,
    this.rightPad,
    this.focusNode,
    this.onChange,
    this.onTapSelection,
    this.readonly,
    this.onTap
  }){
    if(this.onTapSelection == null){
      this.onTapSelection = false;
    }
    if(this.textPadBottom == null)
    {
      this.textPadBottom = 5;
    }
    if(this.textPadLeft == null){
      this.textPadLeft = 15;
    }
    if(this.textPadRight == null){
      this.textPadRight = 10;
    }
    if(this.textPadTop == null){
      this.textPadTop = 10;
    }
    if(this.leftPad == null){
      this.leftPad = 20;
    }
    if(this.rightPad == null){
      this.rightPad = 20;
    }


  }

  @override
  State<StatefulWidget> createState() => _TextFieldExtState();

}

class _TextFieldExtState extends State<TextFieldExt>{
  @override
  Widget build(BuildContext context) {

    return Stack(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(left:widget.leftPad,right: widget.rightPad,
            top:((widget.topPad !=null)? widget.topPad : 0)),
          child: Material(
            elevation: 2.0,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            shadowColor: Colors.black,
            child: TextField(
              readOnly: (widget.readonly !=null)?widget.readonly:false,
              onTap:(){
                  if(widget.onTap!=null){
                    widget.onTap();
                  }
                  if(widget.onTapSelection){
                    widget.controller.selection = TextSelection.fromPosition(
                        TextPosition(offset: widget.controller.text.length));
                  }
              },
              onChanged: (value){

                if(widget.keyboardType == TextInputType.number){
                  widget.controller.text = widget.controller.text.replaceAll(".","");
                  widget.controller.text = widget.controller.text.replaceAll("_","");
                }
                widget.onChange(value);
              },
              focusNode: widget.focusNode,
              controller: widget.controller,
              keyboardType: (widget.keyboardType == null)?
                TextInputType.text : widget.keyboardType,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.only(left: widget.textPadLeft,
                    right: widget.textPadRight,
                    top: widget.textPadTop,
                    bottom: widget.textPadBottom),
                hintText: widget.hintText,
                prefix:null,// SizedBox(width: 90,),
                prefixIcon:(widget.icon != null)? Icon(widget.icon): null,
                filled: true,
                focusColor: Colors.white,
                fillColor: Colors.white,
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.teal, width: 0.0),
                    borderRadius: BorderRadius.all(Radius.circular(widget.borderRadius))
                ),
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey, width: 0.0),
                    borderRadius: BorderRadius.all(Radius.circular(widget.borderRadius))
                ),

              ),
            ),
          ),
        ),
      ],
    );
  }

}