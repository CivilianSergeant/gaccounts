import 'package:flutter/material.dart';

class OverviewButton extends StatefulWidget{
  Color color;
  String text;
  OverviewButton({Key key,this.color,this.text});

  @override
  State<StatefulWidget> createState() => _OverviewButtonState();
}

class _OverviewButtonState extends State<OverviewButton>{
  @override
  Widget build(BuildContext context) {
    return FlatButton(
      color: widget.color,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10)
      ),
      child: Container(
        padding: EdgeInsets.only(top: 10),
        height: 65,
        width: ((MediaQuery.of(context).size.width/2)-60),
        child: Column(
          children: <Widget>[
            Text(widget.text,style: TextStyle(color: Colors.white,
            fontSize: 20),),
            SizedBox(height: 10,),
            Text("Total: 0",style: TextStyle(
                fontSize: 16,
                color: Colors.white),)
          ],
        ),
      ),
      onPressed: (){
      },
    );
  }

}