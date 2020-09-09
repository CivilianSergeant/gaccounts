import 'package:flutter/material.dart';

class OverviewButton extends StatefulWidget{
  Color color;
  String text;
  double total;
  OverviewButton({Key key,this.color,this.text,this.total});

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
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(top: 10),
        height: 80,
        width: ((MediaQuery.of(context).size.width/2)-60),
        child: Column(
          children: <Widget>[

            Container(
              alignment: Alignment.centerRight,
              height: 25,
              padding: EdgeInsets.only(bottom: 0),
              child: Text("${(widget.total !=null)? widget.total:0}",style: TextStyle(color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 20),),
            ),
            SizedBox(height: 10,),
            Divider(),
            Container(
              alignment: Alignment.centerRight,
              child: Text("${widget.text}",
                  style: TextStyle(
                  fontSize: 16,
                  color: Colors.white),),
            )
          ],
        ),
      ),
      onPressed: (){
      },
    );
  }

}