import 'package:flutter/material.dart';
import 'package:gaccounts/config/AppConfig.dart';

class ActionButton extends StatefulWidget{
  String caption;
  Function onTap;
  FocusNode buttonFocus;
  Icon icon;
  Stream stream;
  double width;
  Color color;
  ActionButton({Key key,
    this.color,this.icon,this.width,
    this.caption,this.onTap,this.buttonFocus,this.stream});



  @override
  State<StatefulWidget> createState() => _ActionButtonState();

}

class _ActionButtonState extends State<ActionButton>{

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 2.0,
      borderRadius: BorderRadius.circular(50),
      shadowColor: Colors.black,
      color: Color.fromARGB(1, 14, 75, 97),

      child: SizedBox(
        width: (widget.width!=null)? widget.width : MediaQuery.of(context).size.width,
        height: 50,
        child: Padding(
          padding: EdgeInsets.only(left:0,right: 0),
          child: FlatButton(
            focusNode: widget.buttonFocus,
            color: (widget.color !=null)? widget.color: Color(0xff0e4b61),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50)
            ),
            padding:EdgeInsets.all(0),
            onPressed: (widget.onTap==null)? null : widget.onTap,
            child: StreamBuilder(
              stream: widget.stream,
              builder: (BuildContext context, AsyncSnapshot snapshot){
                AppConfig.log(snapshot.data,line: "49", className:"ActionButton");
                if(snapshot.data == null){
                  return (widget.icon != null)? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children:[
                      widget.icon,
                      Text(" "+widget.caption,style:
                      TextStyle(
                          fontSize: 16,
                          color: Colors.white
                      ),)
                    ]

                  ): Text(widget.caption,style:
                  TextStyle(
                      fontSize: 16,
                      color: Colors.white
                  ),);
                }else if(snapshot.data == 1){
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                      SizedBox(width: 10,),
                      Text(widget.caption,style:
                      TextStyle(
                          fontSize: 16,
                          color: Colors.white
                      ),),
                    ],
                  );
                }else if(snapshot.data == 2){
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: Icon(Icons.done,color: Colors.white,)),
                      SizedBox(width: 10,),
                      Text(widget.caption,style:
                      TextStyle(
                          fontSize: 16,
                          color: Colors.white
                      ),),
                    ],
                  );
                }else{
                  return Text(widget.caption,style:
                  TextStyle(
                      fontSize: 16,
                      color: Colors.white
                  ),);
                }


              },

            ),
          ),
        ),
      ),
    );
  }
}