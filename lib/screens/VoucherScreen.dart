import 'package:flutter/material.dart';
import 'package:gaccounts/persistance/entity/User.dart';
import 'package:gaccounts/persistance/repository/AccTrxMasterRepository.dart';
import 'package:gaccounts/persistance/repository/UserRepository.dart';
import 'package:gaccounts/persistance/services/AccTrxMasterService.dart';
import 'package:gaccounts/persistance/services/UserService.dart';
import 'package:intl/intl.dart';

class VoucherScreen extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _VoucherScreenState();
}

class _VoucherScreenState extends State<VoucherScreen>{
  List<Map<String,dynamic>> vouchers = [];

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
          actions: <Widget>[
            FlatButton(
              child: Icon(Icons.add,color: Colors.white,),
              onPressed: () async{
                UserService userService = UserService(userRepo: UserRepository());
                User user = await userService.checkCurrentUser();

                if(!user.downloadVoucher){

                  Navigator.of(context).pushNamed('/sync-download');
                }else{
                  Navigator.of(context).pop();
                  Navigator.of(context).pushNamed('/voucher-entry');
                }
              },
            ),
//            FlatButton(
//              child: Icon(Icons.delete,color: Colors.white,),
//              onPressed: (){
//                AccTrxMasterService service = AccTrxMasterService(
//                  masterRepo: AccTrxMasterRepository()
//                );
//                service.removeAll();
//                loadVouchers();
//              },
//            ),

          ],
          title: Padding(
            padding: EdgeInsets.only(left:0),
            child: Align(
              alignment: Alignment.centerLeft,
                child:Text("Vouchers",style: TextStyle(

                ),
              ),
            ),
          )
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
              height: MediaQuery.of(context).size.height-80,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Title(),
                  Container(
                    height: MediaQuery.of(context).size.height-150,//(chartAccounts.length>0)? ((chartAccounts.length>=7)? 224 : (chartAccounts.length * 32.0)) : 0,
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.grey,
                          width: 1,
                          style: BorderStyle.solid
                        )
                      )
                    ),
                    child:  ListView.builder(
                        itemCount: vouchers.length,//chartAccounts.length+1,
                        itemBuilder: (context,i){

                          return VoucherLine(i);
                        }),
                  ),
                  Spacer(),
                  Container(
                    margin: EdgeInsets.only(bottom: 5),
                    child: TotalAccountAmountLine(),
                  )

                ],
              ),
            )

        ),
      ),
    );
  }

  Widget VoucherLine(int i){
    double rowHeight = 45;
    var voucher = vouchers[i];

    var dateTime = DateTime.parse(voucher['trx_date']);
    DateFormat formatter = DateFormat('yyyy-MM-dd');
    String voucherDate = formatter.format(dateTime);
    return Row(
      children: <Widget>[
        InkWell(
          onTap: (){
            // open details
            Navigator.of(context).pop();
            Navigator.of(context).pushNamed('/voucher-entry',arguments: {'voucher':voucher});
          },
          child: Container(
            width: 190,
            height: rowHeight,

            alignment: Alignment.centerLeft,
            child: Row(
              children: <Widget>[
                SizedBox(
                    width: 30,height: 25,
                    child:(voucher['is_posted']==1)? Icon(Icons.cloud_done,color: Colors.green):
                Icon(Icons.cloud_upload, color: Colors.redAccent,)),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text("Voucher No: ${voucher['voucher_no']}",
                    style: TextStyle(
                      fontWeight: FontWeight.w600
                    ),),
                    Text("Type: ${voucher['voucher_type'].toString().toUpperCase().replaceAll('-', ' ')}",style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey
                    ),),
                    Text("Date: ${voucherDate}",style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey
                    ),),

                  ],
                ),
              ],
            ),
            decoration: BoxDecoration(
//                color: (chartAccount['isActive'])? Color(0x5508af7f) : Colors.transparent,
                border: Border(bottom: BorderSide(width: 1,color: Colors.grey,style: BorderStyle.solid))
            ),
          ),
        ),
        Container(
          width: 85,
          height: rowHeight,
          child: Text("${voucher['credit']}"),
          alignment: Alignment.centerRight,
          decoration: BoxDecoration(

              border: Border(
                  left: BorderSide(width: 1,color: Colors.grey,style: BorderStyle.solid),
                  bottom: BorderSide(width: 1,color: Colors.grey,style: BorderStyle.solid)
              )
          ),
        ),
        Container(
          width: 85,
          height: rowHeight,
          child: Text("${voucher['debit']}"),
          alignment: Alignment.centerRight,
          decoration: BoxDecoration(

              border: Border(
                  left: BorderSide(width: 1,color: Colors.grey,style: BorderStyle.solid),
                  bottom: BorderSide(width: 1,color: Colors.grey,style: BorderStyle.solid)
              )
          ),
        )
      ],
    );
  }

  Widget Title(){
    Color bg = Color(0x5f5fa5fc);
    double rowHeight=35;
    return Row(
      children: <Widget>[
        Container(
          width: 190,
          height: rowHeight,
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: EdgeInsets.only(left: 10),
            child: Text("Voucher No",style: TextStyle(
                fontWeight: FontWeight.w600
            ),),
          ),
          decoration: BoxDecoration(
              color:bg,
              border: Border(
                  top: BorderSide(width: 1,color: Colors.grey,style: BorderStyle.solid),
                  bottom: BorderSide(width: 1,color: Colors.grey,style: BorderStyle.solid)
              )
          ),
        ),
        Container(
          width: 85,
          height: rowHeight,
          child: Text("Received",style: TextStyle(
              fontWeight: FontWeight.w600
          ),),
          alignment: Alignment.center,
          decoration: BoxDecoration(
              color:bg,
              border: Border(
                  top: BorderSide(width: 1,color: Colors.grey,style: BorderStyle.solid),
                  left: BorderSide(width: 1,color: Colors.grey,style: BorderStyle.solid),
                  bottom: BorderSide(width: 1,color: Colors.grey,style: BorderStyle.solid)
              )
          ),
        ),
        Container(
          width: 85,
          height: rowHeight,
          child: Text("Payment",style: TextStyle(
              fontWeight: FontWeight.w600
          ),),
          alignment: Alignment.center,
          decoration: BoxDecoration(
              color:bg,
              border: Border(
                  top: BorderSide(width: 1,color: Colors.grey,style: BorderStyle.solid),
                  left: BorderSide(width: 1,color: Colors.grey,style: BorderStyle.solid),
                  bottom: BorderSide(width: 1,color: Colors.grey,style: BorderStyle.solid)
              )
          ),
        )
      ],
    );
  }

  Widget TotalAccountAmountLine(){
    double rowHeight = 30;
    Color bg = Color(0x5f5fa5fc);
    return Row(
      children: <Widget>[
        Container(
          width: 190,
          height: rowHeight,
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: EdgeInsets.only(left: 10),
            child: Text("",style: TextStyle(
                fontWeight: FontWeight.w600
            ),),
          ),
          decoration: BoxDecoration(
              color:bg,
              border: Border(

                  bottom: BorderSide(width: 1,color: Colors.grey,style: BorderStyle.solid)
              )
          ),
        ),
        Container(
          width: 85,
          height: rowHeight,

          child: Text("0",style: TextStyle(
              fontWeight: FontWeight.w600
          ),),
          alignment: Alignment.centerRight,
          decoration: BoxDecoration(
              color:bg,
              border: Border(
                  left: BorderSide(width: 1,color: Colors.grey,style: BorderStyle.solid),
                  bottom: BorderSide(width: 1,color: Colors.grey,style: BorderStyle.solid)
              )
          ),
        ),
        Container(
          width: 85,
          height: rowHeight,
          child: Text("0",style: TextStyle(
              fontWeight: FontWeight.w600
          ),),
          alignment: Alignment.centerRight,
          decoration: BoxDecoration(
              color:bg,
              border: Border(

                  left: BorderSide(width: 1,color: Colors.grey,style: BorderStyle.solid),
                  bottom: BorderSide(width: 1,color: Colors.grey,style: BorderStyle.solid)
              )
          ),
        )
      ],
    );
  }

  Future<void> loadVouchers () async {
    AccTrxMasterService accMasterService = AccTrxMasterService(masterRepo: AccTrxMasterRepository());
    List<Map<String,dynamic>> maps = await accMasterService.getVouchers();
//    AppConfig.debug(maps);
    if(mounted) {
      setState(() {
        vouchers = maps;
      });
    }
  }

  @override
  void initState() {

    loadVouchers();
  }
}