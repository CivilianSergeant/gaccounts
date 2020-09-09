import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gaccounts/config/AppConfig.dart';
import 'package:gaccounts/persistance/entity/AccTrxDetails.dart';
import 'package:gaccounts/persistance/entity/AccTrxMaster.dart';
import 'package:gaccounts/persistance/entity/User.dart';
import 'package:gaccounts/persistance/repository/AccTrxMasterRepository.dart';
import 'package:gaccounts/persistance/repository/ChartAccountRepository.dart';
import 'package:gaccounts/persistance/repository/UserRepository.dart';
import 'package:gaccounts/persistance/services/AccTrxMasterService.dart';
import 'package:gaccounts/persistance/services/ChartAccountService.dart';
import 'package:gaccounts/persistance/services/UserService.dart';
import 'package:intl/intl.dart';
import 'package:toast/toast.dart';

class VoucherEntryScreen extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _VoucherEntryScreenState();
  
}

class _VoucherEntryScreenState extends State<VoucherEntryScreen>{

  List<Map<String,dynamic>> chartAccounts = [];
  List<DropdownMenuItem<String>> voucherTypes = [];
  String _selectedVoucherType;
  Map<String,dynamic> lastAccountType = {};
  double total=0;
  double finalReceived = 0;
  double finalPayment = 0;
  double totalReceived = 0;
  double totalPayment = 0;
  double openingBalance = 0;
  double closingBalance = 0;

  int dobStartYear;
  int dobEndYear;
  DateTime today;
  DateTime dobInitial;
  String screenState = "";

  Map<String,dynamic> ca;
  Map<String,dynamic> editVoucher;
  TextEditingController dateController = TextEditingController();

  @override
  Widget build(BuildContext context) {
   return Scaffold(
     appBar: AppBar(
         title: Padding(
           padding: EdgeInsets.only(left:MediaQuery.of(context).size.width/2-140),
           child: Align(
             alignment: Alignment.centerLeft,
               child:Text("${screenState} Voucher Entry",style: TextStyle(

               ),
             ),
           ),
         )
     ),
     body: WillPopScope(
       onWillPop: () async{
         Navigator.of(context).pop();
         Navigator.of(context).pushNamed('/vouchers');
         return false;
       },
       child: SafeArea(
         child: SingleChildScrollView(
           child: Container(
             child: Column(
               children: <Widget>[
                 Row(
                   children: <Widget>[
                      Container(
                        child: DropdownButton(
                          hint: Text("Select Voucher Type"),
                          items: voucherTypes,
                          isExpanded: true,
                          value: _selectedVoucherType,
                          onChanged: (value){
                              setState(() {
                                _selectedVoucherType = value;
                                loadChartAccounts(value);
                              });
                          },
                        ),
                        width: MediaQuery.of(context).size.width/2,
                      ),
                      Container(
                        height: 30,
                        margin: EdgeInsets.only(left: 10),
                        alignment: Alignment.centerRight,
                       child:TextField(
                         textAlign: TextAlign.center,
                         controller: dateController,
                         onTap: (){
                           showDatePicker(context: context, initialDate:dobInitial , firstDate: DateTime(dobStartYear), lastDate: DateTime(dobEndYear))
                               .then((date){
                             if(date != null){
                               dateController.text = (date.toString().substring(0,11).trim());
                               loadChartAccounts(_selectedVoucherType);
                               setState(() {
                                 dobInitial = DateTime.parse(dateController.text);
                               });
//                             getAgeInWords();
                             }else{
                               dateController.text="";
                             }
                           });
                         },

                         readOnly: true,
                         decoration: InputDecoration(
                             hintText: 'Select Voucher Date',
                             hintStyle: TextStyle(
                                 fontSize: 12
                             )
                         ),
                       ),
                       width: (MediaQuery.of(context).size.width/2)-10,
                     )
                   ],
                 ),
                 OpeningBalanceRow(),
                 Title(),
                 Container(
                   height: (chartAccounts.length>0)? ((chartAccounts.length>=7)? 224 : (chartAccounts.length * 32.0)) : 0,

                   child:  ListView.builder(
                       itemCount: chartAccounts.length,
                       itemBuilder: (context,i){
                         Map<String,dynamic> chartAccount = chartAccounts[i];
                         return AccountLine(chartAccount);
                       }),
                 ),
                 LastAccountTypeLine(),
                 TotalAccountAmountLine(),
                 ClosingBalanceRow(),
                 Container(
                   child: TextField(
                     maxLines:2,

                     keyboardType: TextInputType.text,
                     controller: (ca!=null)? ca['description']: null,
                     decoration: InputDecoration(
                       hintText: 'Description',
                       enabled: (ca!=null)? true : false
                     ),
                   ),
                 ),
                 Row(
                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                   children: <Widget>[
                     FlatButton(
                       color: Colors.green,
                       textColor: Colors.white,
                       child: Text("Save Voucher"),
                       onPressed: (){
                            handleSaveVoucher();
                       },
                     ),
                     FlatButton(
                       color: Colors.orange,
                       textColor: Colors.white,
                       child: Text("Cancel"),
                       onPressed: (){
                         setState(() {
                           if(ca!=null){
                             ca['description'].text = '';
                           }
                           _selectedVoucherType = null;
                           chartAccounts = [];
                           finalReceived=0;
                           finalPayment=0;
                           totalPayment=0;
                           totalReceived=0;
                           editVoucher=null;

                         });

                       },
                     )
                   ],
                 )
               ],
             ),

           ),
         ),
       ),
     ),
   );
  }

  String getNarrationSuffix(){
     if(_selectedVoucherType=='bank'){
       return '-bc';
     } else if(_selectedVoucherType=='cash-purchase'||
     _selectedVoucherType == 'cash-sale' ||
     _selectedVoucherType == 'received' ||
     _selectedVoucherType == 'payment'){
       return '-ca';
     }else{
       return '-cr';
     }

  }

  Future<void> handleSaveVoucher() async{
    UserService userService = UserService(userRepo: UserRepository());
    User user = await userService.checkCurrentUser();

    List<AccTrxDetail> voucherRecords = [];

//    AppConfig.debug(lastAccountType);
    chartAccounts.forEach((element){
//
//      if(element['trx_detail_id'] != null){
//        AppConfig.debug(element);
//
//      }});

      String receivedValue = element['received'].text.toString();
      String paymentValue = element['payment'].text.toString();

      double receivedAmount = (receivedValue.length>0)? double.parse(receivedValue):0;
      double paymentAmount = (paymentValue.length>0)?double.parse(paymentValue) : 0;

      if(receivedAmount>0){
        voucherRecords.add(AccTrxDetail(
            trxDetailId: (element['trx_detail_id']!=null)? element['trx_detail_id']: null,
            trxMasterId: (editVoucher!=null)? editVoucher['trx_master_id'] : null,
            accId: element['acc_id'],
            credit: receivedAmount,
            userId: user.syncId,
            isActive: true,
            narration: (_selectedVoucherType=="bank" && !element['description'].toString().contains('Withdraw'))?'Withdraw-'+element['description'].text:element['description'].text,
            createDate: dateController.text
        ));
      }

      if(paymentAmount>0){
        voucherRecords.add(AccTrxDetail(
          trxDetailId: (element['trx_detail_id'] != null)? element['trx_detail_id'] : null,
          trxMasterId: (editVoucher != null)? editVoucher['trx_master_id']: null,
          accId: element['acc_id'],
          debit: paymentAmount,
          userId: user.syncId,
          isActive: true,
          narration: (_selectedVoucherType=="bank" && !element['description'].toString().contains('Deposit'))?'Deposit-'+element['description'].text : element['description'].text,
          createDate: dateController.text
        ));
      }

    });

    if(dateController.text.length==0){
      Toast.show("Please select Voucher Date before save", context,
      duration: Toast.LENGTH_LONG,gravity: Toast.CENTER);
      return;
    }

    if(voucherRecords.length==0){
      Toast.show("Please add transactions amount before save", context,
      duration: Toast.LENGTH_LONG, gravity: Toast.CENTER);
      return;
    }

    if(closingBalance<0){
      Toast.show("Sorry! Closing Balance should not be negative", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.CENTER);
      return;
    }

    var narration = lastAccountType['acc_name'].toString().toLowerCase().replaceAll(' ', '-');
    narration += getNarrationSuffix();

    voucherRecords.add(AccTrxDetail(
        trxDetailId: (editVoucher != null)? lastAccountType['trx_detail_id']:null,
        trxMasterId: (editVoucher!=null)? editVoucher['trx_master_id']: null,
        accId: lastAccountType['acc_id'],
        credit: finalReceived,
        debit: finalPayment,
        userId: user.syncId,
        isActive: true,
        narration: narration,
        createDate: dateController.text
    ));

    AccTrxMasterService masterService = AccTrxMasterService(
        masterRepo: AccTrxMasterRepository());

    if(editVoucher != null){


//      AppConfig.debug(d.toIso8601String());return;
      AppConfig.log("Y");
      updateVoucher(masterService,voucherRecords);
    }else{
      AppConfig.log('N');
      saveVoucher(user,masterService,voucherRecords);
    }




  }

  Future<void> updateVoucher(AccTrxMasterService masterService, List<AccTrxDetail> voucherRecords) async {
    AppConfig.log("WITHIN Controller: "+voucherRecords.toString());
    DateTime d = DateTime.parse(dateController.text);
    Map<String,dynamic> data = {'trx_date':d.toIso8601String()};
    AppConfig.log(data);
    await masterService.updateVoucher(editVoucher['trx_master_id'],data: data);

    AppConfig.log(voucherRecords.map((e) => e.toMap().toString()));
//    return;
    int updated = await masterService.updateTransactions(voucherRecords);
    AppConfig.log("Total Updated Transactions: ${updated}");
    Navigator.of(context).pop();
    Navigator.of(context).pushNamed('/vouchers');
  }
  Future<void> saveVoucher(User user, AccTrxMasterService masterService,List<AccTrxDetail> voucherRecords) async {
    AppConfig.log(voucherRecords.map((e) => e.toMap().toString()));
//    return;

    dynamic master = await masterService.hasMaster();

    String voucherNo;
    int index;
    if(master==null){
      index = 1;
      voucherNo = index.toString();
      voucherNo = voucherNo.padLeft(5,'0')+'-'+(DateTime.now()).year.toString();

    }else{

      master = await masterService.getLastVoucherNo();
      List<String> segment = master['voucher_no'].toString().split('-');
      index = int.parse(segment[0]);
      index++;

      voucherNo = index.toString();
      voucherNo = voucherNo.padLeft(5,'0')+'-'+(DateTime.now()).year.toString();
    }

    DateTime d = DateTime.parse(dateController.text);
    int saved = await masterService.saveTransactions(AccTrxMaster(
        userId: user.syncId,
        officeId: user.syncId,
        voucherType: _selectedVoucherType,
        isPosted: false,
        trxDate: d.toIso8601String(),
        autoVoucherNo: index,
        voucherNo: voucherNo,
    ), voucherRecords);

    if(saved<0){
      // update voucher & details
      AppConfig.log('Update Voucher & Details');
      return;
    }

    if(saved == 0){
      Toast.show("Sorry! Unable to save voucher",context,
          duration:Toast.LENGTH_LONG,gravity: Toast.CENTER);
      return;
    }

    if(saved == 1){
      Toast.show("Sorry! Unable to save voucher details",context,
          duration:Toast.LENGTH_LONG,gravity: Toast.CENTER);
      return;
    }

    if(saved == 2){
      Toast.show("Voucher saved successfully",context,
          duration:Toast.LENGTH_LONG,gravity: Toast.CENTER);
      Navigator.of(context).pop();
      Navigator.of(context).pushNamed('/vouchers');
      return;
    }
  }


  Widget OpeningBalanceRow(){
    double rowHeight=35;
    return (_selectedVoucherType == 'credit-purchase' ||
        _selectedVoucherType == 'credit-sale')? SizedBox.shrink() :
    Row(
      children: <Widget>[
        Container(
          width: 190,
          height: rowHeight,
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: EdgeInsets.only(left: 10),
            child: Text("Opening Balance",style: TextStyle(
                fontWeight: FontWeight.w600
            ),),
          ),
          decoration: BoxDecoration(
              border: Border(
                  top: BorderSide(width: 1,color: Colors.grey,style: BorderStyle.solid),
                  bottom: BorderSide(width: 1,color: Colors.grey,style: BorderStyle.solid)
              )
          ),
        ),
        Container(
          width: 170,
          height: rowHeight,
          child: Text("${openingBalance}",style: TextStyle(
            fontWeight: FontWeight.w600
          ),),
          alignment: Alignment.centerRight,
          decoration: BoxDecoration(
              border: Border(
                  top: BorderSide(width: 1,color: Colors.grey,style: BorderStyle.solid),
                  left: BorderSide(width: 1,color: Colors.grey,style: BorderStyle.solid),
                  bottom: BorderSide(width: 1,color: Colors.grey,style: BorderStyle.solid)
              )
          ),
        ),

      ],
    );
  }

  Widget ClosingBalanceRow(){
    double rowHeight=35;
    return (_selectedVoucherType == 'credit-purchase' ||
        _selectedVoucherType == 'credit-sale')? SizedBox.shrink() :
    Row(
      children: <Widget>[
        Container(
          width: 190,
          height: rowHeight,
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: EdgeInsets.only(left: 10),
            child: Text("Closing Balance",style: TextStyle(
                fontWeight: FontWeight.w600
            ),),
          ),
          decoration: BoxDecoration(
              border: Border(
                  top: BorderSide(width: 1,color: Colors.grey,style: BorderStyle.solid),
                  bottom: BorderSide(width: 1,color: Colors.grey,style: BorderStyle.solid)
              )
          ),
        ),
        Container(
          width: 170,
          height: rowHeight,
          child: Text("${closingBalance}",style: TextStyle(
              fontWeight: FontWeight.w600
          ),),
          alignment: Alignment.centerRight,
          decoration: BoxDecoration(
              border: Border(
                  top: BorderSide(width: 1,color: Colors.grey,style: BorderStyle.solid),
                  left: BorderSide(width: 1,color: Colors.grey,style: BorderStyle.solid),
                  bottom: BorderSide(width: 1,color: Colors.grey,style: BorderStyle.solid)
              )
          ),
        ),

      ],
    );
  }

  Widget Title(){
    double rowHeight=35;
    Color bg = Color(0x5f5fa5fc);
    return Row(
      children: <Widget>[
        Container(
          width: 190,
          height: rowHeight,
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: EdgeInsets.only(left: 10),
            child: Text("Account Name",style: TextStyle(
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

  String lastAccountTypeName(){
    if(_selectedVoucherType != null && lastAccountType !=null){
      return  (lastAccountType['acc_code'] != null)? "${lastAccountType['acc_code']} - ${lastAccountType['acc_name']}": "";
    }
    return "";
  }

  Widget LastAccountTypeLine(){
    double rowHeight = 35;
    Color bg = Color(0x5f5fa5fc);
    return Row(
      children: <Widget>[
        Container(
          width: 190,
          height: rowHeight,
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: EdgeInsets.only(left: 10),
            child: Text(lastAccountTypeName(),style: TextStyle(
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

          child: Text("${finalReceived}",style: TextStyle(
              fontWeight: FontWeight.w600
          ),),
          alignment: Alignment.centerRight,
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
          child: Text("${finalPayment}",style: TextStyle(
              fontWeight: FontWeight.w600
          ),),
          alignment: Alignment.centerRight,
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
    double rowHeight = 35;
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

          child: Text("${(_selectedVoucherType != null)? totalReceived: ''}",style: TextStyle(
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
          child: Text("${(_selectedVoucherType != null)? totalPayment : ''}",style: TextStyle(
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

  bool isActiveReceivedColumn(Map<String,dynamic> chartAccount){
    bool isEnabled = false;
    switch(_selectedVoucherType){
      case 'cash-purchase':
      case 'credit-purchase':
        isEnabled = false;
        break;
      case 'cash-sale':
      case 'credit-sale':
        isEnabled = true;
        break;
      case 'received':
        isEnabled = true;
        break;
      case 'payment':
        isEnabled = false;
        break;
      case 'bank':
        if(chartAccount['voucher_type'] == 'bank' && chartAccount['isReceivable']==true){
          isEnabled = true;
        }
        break;

    }
    return isEnabled;
  }

  bool isActivePaymentColumn(Map<String,dynamic> chartAccount){
    bool isEnabled = false;
    switch(_selectedVoucherType){
      case 'cash-purchase':
      case 'credit-purchase':
        isEnabled = true;
        break;
      case 'cash-sale':
      case 'credit-sale':
        isEnabled = false;
        break;
      case 'received':
        isEnabled = false;
        break;
      case 'payment':
        isEnabled = true;
        break;
      case 'bank':
//        AppConfig.debug(chartAccount['isPayable']);
        if(chartAccount['voucher_type'] == 'bank' && chartAccount['isPayable']==true){
          isEnabled = true;
        }
        break;
    }
    return isEnabled;
  }

  double calculateTotal(){
    total=0;
    finalReceived=0;
    finalPayment=0;
    totalPayment=0;
    totalReceived=0;


    chartAccounts.forEach((element) {
      String receivedValue = (element['received'].text.toString());
      String paymentValue = (element['payment'].text.toString());
//      AppConfig.debug(" HELLO" + paymentValue);

      if(receivedValue.length>0) {
        totalReceived += double.parse(receivedValue);
      }
      if(paymentValue.length>0) {
        totalPayment += double.parse(paymentValue);
      }
    });



    switch(_selectedVoucherType){
      case 'cash-purchase':
      case 'credit-purchase':
      case 'payment':
        finalReceived = totalPayment;
        totalReceived = totalReceived + finalReceived;

        break;

      case 'cash-sale':
      case 'credit-sale':
      case 'received':
        finalPayment = totalReceived;
        totalPayment = totalPayment + finalPayment;
        break;
      case 'bank':
        var total = totalReceived - totalPayment;
//        AppConfig.debug(total);
        if(total<0){
          finalReceived = total.abs();
          totalReceived = (finalReceived+totalReceived);
        }else{
          finalPayment = total;
          totalPayment = (finalPayment+totalPayment);
        }

        break;

    }


    setClosingBalance();
//    AppConfig.debug("CLOSEING ${closingBalance} OPEN: ${openingBalance} TR: ${totalReceived} TP: ${totalPayment} ");
  }

  void setClosingBalance(){
    if(_selectedVoucherType=='received' || _selectedVoucherType=='cash-sale'){
      closingBalance = openingBalance+finalPayment;
    }
    if(_selectedVoucherType == 'cash-purchase' || _selectedVoucherType=='payment'){
      closingBalance = openingBalance-finalReceived;
    }
    if(_selectedVoucherType == 'bank'){
      if(finalReceived>finalPayment){
        closingBalance = openingBalance - finalReceived;
      }else{
        closingBalance = openingBalance + finalPayment;
      }
    }
  }

  void setAciveRow(Map<String,dynamic> chartAccount){
    chartAccounts.forEach((element) {
//      AppConfig.debug("HERE"+element.toString());
      if(element['voucher_type']=='bank'){
        element['isActive'] = false;
        if (element['isPayable'] == true && chartAccount['isPayable'] == true) {
          element['isActive'] = true;
        }
        if(element['isReceivable'] == true && chartAccount['isReceivable'] == true) {
          element['isActive'] = true;
        }
      }else {
        if (element['acc_id'] != chartAccount['acc_id']) {
          element['isActive'] = false;
        }
        chartAccount['isActive'] = true;
      }
    });
    setState(() {
      ca = chartAccount;
    });
//    AppConfig.debug(ca);
  }


  Widget AccountLine(Map<String,dynamic> chartAccount){
    double rowHeight = 32;
    bool received = isActiveReceivedColumn(chartAccount);
    bool payment = isActivePaymentColumn(chartAccount);
    return Row(
      children: <Widget>[
        InkWell(
          onTap: (){

            setAciveRow(chartAccount);

          },
          child: Container(
            width: 190,
            height: rowHeight,

            alignment: Alignment.centerLeft,
            child: Text("${chartAccount['acc_code']} - ${chartAccount['acc_name']}"),
            decoration: BoxDecoration(
                color: (chartAccount['isActive'])? Color(0x5508af7f) : Colors.transparent,
                border: Border(bottom: BorderSide(width: 1,color: Colors.grey,style: BorderStyle.solid))
            ),
          ),
        ),
        Container(
          width: 85,
          height: rowHeight,
          child: TextField(
              onTap: (){
                setAciveRow(chartAccount);
              },
              onChanged: (value){
//                AppConfig.debug(value.length);
                if(value.length>0){
                  calculateTotal();
                }
              },
            controller: chartAccount['received'],
              keyboardType: TextInputType.number,
              textAlign: TextAlign.right,
              decoration: new InputDecoration(

                enabled: received,
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                errorBorder: InputBorder.none
              )
          ),
          alignment: Alignment.centerRight,
          decoration: BoxDecoration(
              color: (chartAccount['isActive'])? Color(0x5508af7f) : Colors.transparent,
              border: Border(
                  left: BorderSide(width: 1,color: Colors.grey,style: BorderStyle.solid),
                  bottom: BorderSide(width: 1,color: Colors.grey,style: BorderStyle.solid)
              )
          ),
        ),
        Container(
          width: 85,
          height: rowHeight,
          child: TextField(
              onTap: (){
                setAciveRow(chartAccount);
              },
              onChanged: (value){
//                AppConfig.debug(value.length);
                if(value.length>0){
                  calculateTotal();
                }
              },
            controller: chartAccount['payment'],
              keyboardType: TextInputType.number,
              textAlign: TextAlign.right,
              decoration: new InputDecoration(
                  enabled: payment,
                  contentPadding: EdgeInsets.only(bottom: 15),
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none
              )
          ),
          alignment: Alignment.centerRight,
          decoration: BoxDecoration(
              color: (chartAccount['isActive'])? Color(0x5508af7f) : Colors.transparent,
              border: Border(
                  left: BorderSide(width: 1,color: Colors.grey,style: BorderStyle.solid),
                  bottom: BorderSide(width: 1,color: Colors.grey,style: BorderStyle.solid)
              )
          ),
        )
      ],
    );
  }

  @override
  void initState() {
    init();
  }

  Future<List<Map<String,dynamic>>> getDetailsByVoucher() async {
    if(editVoucher != null) {
      AccTrxMasterService masterService = AccTrxMasterService(
          masterRepo: AccTrxMasterRepository());
      List<Map<String,dynamic>> details = await masterService.getDetails(editVoucher['trx_master_id']);

      return details;
    }
    return null;
  }


  @override
  void didChangeDependencies() async {
    dynamic _editVoucher = ModalRoute.of(context).settings.arguments;
    if(mounted && _editVoucher !=null && editVoucher == null) {

      var voucherDate = _editVoucher['voucher']['trx_date'].toString().substring(0,10);
//      AppConfig.debug("HREE"+_editVoucher['voucher']['trx_date'].toString());
      setState(() {
        editVoucher = _editVoucher['voucher'];
        _selectedVoucherType = editVoucher['voucher_type'];
        dateController.text = voucherDate;
        screenState="Edit";
      });


      loadChartAccounts(_selectedVoucherType);
    }else{

      setState(() {
        screenState="Create";
      });


    }
  }

  Future<void> init()async{


    today = DateTime.now();
    dobStartYear = (today.year);
    dobEndYear = (today.year+18);
    dobInitial = DateTime.now();

    dateController.text = dobInitial.toString().substring(0,10);

    voucherTypes.add(DropdownMenuItem(
      child: Text("Cash Purchase"),
      value: 'cash-purchase',
    ));
    voucherTypes.add(DropdownMenuItem(
      child: Text("Credit Purchase"),
      value: 'credit-purchase',
    ));
    voucherTypes.add(DropdownMenuItem(
      child: Text("Cash Sale"),
      value: 'cash-sale',
    ));
    voucherTypes.add(DropdownMenuItem(
      child: Text("Credit Sale"),
      value: 'credit-sale'
    ));
    voucherTypes.add(DropdownMenuItem(
      child:Text("Received"),
      value: 'received'
    ));
    voucherTypes.add(DropdownMenuItem(
      child:Text("Payment"),
      value: 'payment'
    ));
    voucherTypes.add(DropdownMenuItem(
      child: Text('Bank'),
      value: 'bank',
    ));

    UserService userService = UserService(userRepo: UserRepository());
    User user = await userService.checkCurrentUser();
    if(user.downloadVoucher==false){
      AppConfig.log('here');
      Navigator.of(context).pop();
      Navigator.of(context).pushNamed('/sync-download');
    }

  }



  void setDetails(dynamic detailResults, Map<String,dynamic> element,
      TextEditingController rController,
      TextEditingController pController,
      TextEditingController dController,
      Map<String,dynamic> map,
      {String type}){



      if(detailResults != null){
        int i=0;
        detailResults.forEach((detail) {

          if(lastAccountType['acc_id'] == detail['acc_id']){
            lastAccountType['trx_detail_id'] = detail['trx_detail_id'];

          }

          if(element['acc_id'] == detail['acc_id']){
            if(mounted) {

              setState(() {
                map['trx_detail_id'] = detail['trx_detail_id'];

                if (detail['credit'] != null) {
                  rController.text = detail['credit'].toString();
                }
                if (detail['debit'] != null) {
                  pController.text = detail['debit'].toString();
                }
                if(detail['narration'] != null){
                  dController.text = detail['narration'];
                }
              });

            }
          }
        });

      }
  }

  void setBankDetails(dynamic detailResults, Map<String,dynamic> element,
      TextEditingController rController,
      TextEditingController pController,
      TextEditingController dController,
      Map<String,dynamic> map,
      {String type}){

    if(detailResults != null){
      detailResults.forEach((detail) {
        if(lastAccountType['acc_id'] == detail['acc_id']){
          lastAccountType['trx_detail_id'] = detail['trx_detail_id'];

        }

        bool isDepositElement = element['acc_name'].toString().contains('Deposit');
        bool isWithdrawElement = element['acc_name'].toString().contains('Withdraw');
        bool isDepositDetail = detail['narration'].toString().contains('Deposit');
        bool isWithdrawDetail = detail['narration'].toString().contains('Withdraw');

        if(isDepositElement==true && isDepositDetail==true){
          map['trx_detail_id'] = (detail['trx_detail_id']!=null)?detail['trx_detail_id']:null;
          if(detail['narration'] != null){
            dController.text = detail['narration'];
          }
        }
        if(isWithdrawElement== true && isWithdrawDetail==true){
          map['trx_detail_id'] = (detail['trx_detail_id']!=null)?detail['trx_detail_id']:null;
          if(detail['narration'] != null){
            dController.text = detail['narration'];
          }
        }
        AppConfig.log(element);
        AppConfig.log("HEHHHHH "+detail.toString());

        if(element['acc_id'] == detail['acc_id']){
          if(mounted) {
            setState(() {

              if(element['acc_name'].toString().contains('Deposit')){

                if (detail['debit'] != null) {
                  pController.text = detail['debit'].toString();
                }
              }else {
                if (detail['credit'] != null) {
                  rController.text = detail['credit'].toString();
                }
              }


            });

          }
        }
      });

    }
  }

  Future<void> loadChartAccounts(String type) async {
    if(ca!=null){
      ca['description'].text="";
    }
    dynamic detailResults = await getDetailsByVoucher();

    AppConfig.log("________________________________");
//    AppConfig.debug(detailResults);

    AccTrxMasterService accMasterService = AccTrxMasterService(masterRepo: AccTrxMasterRepository());
    double _openingBalance = await accMasterService.getOpeningBalance(null,dateController.text);
    ChartAccountService service = ChartAccountService(repo: ChartAccountRepository());
    finalPayment=0;
    finalReceived=0;
    totalReceived=0;
    totalPayment=0;
    List<Map<String,dynamic>> _chartAccounts = [];

    if(type=='cash-purchase' || type=='cash-sale'|| type== 'received' ||
        type == 'payment' || type=='bank'){
      Map<String,dynamic> result = await service.getCashAccount();
      if(mounted) {
        setState(() {
          lastAccountType['acc_name'] = result['acc_name'];
          lastAccountType['acc_code'] = result['acc_code'];
          lastAccountType['acc_id'] = result['acc_id'];
          lastAccountType['nature'] = result['nature'];
          lastAccountType['voucher_type'] = result['voucher_type'];
        });
      }
    }else if(type=='credit-purchase'){
      Map<String,dynamic> result = await service.getPayableAccount();
//      AppConfig.debug(result);
      if(mounted) {
        setState(() {
          lastAccountType['acc_name'] = result['acc_name'];
          lastAccountType['acc_code'] = result['acc_code'];
          lastAccountType['acc_id'] = result['acc_id'];
          lastAccountType['nature'] = result['nature'];
          lastAccountType['voucher_type'] = result['voucher_type'];
        });
      }
    }else if(type == 'credit-sale'){
      Map<String,dynamic> result = await service.getReceivableAccount();
      AppConfig.log(result);
      if(mounted) {
        setState(() {
          lastAccountType['acc_name'] = result['acc_name'];
          lastAccountType['acc_code'] = result['acc_code'];
          lastAccountType['acc_id'] = result['acc_id'];
          lastAccountType['nature'] = result['nature'];
          lastAccountType['voucher_type'] = result['voucher_type'];
        });
      }
    }

    switch(type){
      case 'cash-purchase':
      case 'credit-purchase':
      case 'cash-sale':
      case 'credit-sale':

        List<Map<String,dynamic>> results = await service.getCommonChartAccounts();
        results.forEach((element) {
          TextEditingController receivedController = TextEditingController();
          TextEditingController paymentController = TextEditingController();
          TextEditingController descController = TextEditingController();
          Map<String,dynamic> chartAccount = {
            'acc_id':element['acc_id'],
            'acc_name':element['acc_name'],
            'acc_code':element['acc_code'],
            'voucher_type':element['voucher_type'],
            'isActive':false,
            'description': descController,
            'received':receivedController,
            'payment': paymentController
          };
          setDetails(detailResults, element, receivedController,
              paymentController,descController,chartAccount);
          //AppConfig.debug("DDDD "+chartAccount.toString());
          _chartAccounts.add(chartAccount);
        });

        break;
      case 'received':
        List<Map<String,dynamic>> results = await service.getReceivedChartAccounts();
        AppConfig.log(results);
        if(detailResults !=null)
          AppConfig.log(detailResults.length);

        results.forEach((element) {

          TextEditingController receivedController = TextEditingController();
          TextEditingController paymentController = TextEditingController();
          TextEditingController descController = TextEditingController();
          Map<String,dynamic> chartAccount= {
            'acc_id':element['acc_id'],
            'acc_name':element['acc_name'],
            'acc_code':element['acc_code'],
            'voucher_type':element['voucher_type'],
            'isActive':false,
            'description': descController,
            'received':receivedController,
            'payment': paymentController
          };
          setDetails(detailResults, element, receivedController,
              paymentController,descController, chartAccount);

          _chartAccounts.add(chartAccount);
        });
        break;
      case 'payment':
        List<Map<String,dynamic>> results = await service.getPaymentChartAccounts();
        results.forEach((element) {
          TextEditingController receivedController = TextEditingController();
          TextEditingController paymentController = TextEditingController();
          TextEditingController descController = TextEditingController();
          Map<String,dynamic> chartAccount= {
            'acc_id':element['acc_id'],
            'acc_name':element['acc_name'],
            'acc_code':element['acc_code'],
            'voucher_type':element['voucher_type'],
            'isActive':false,
            'description': descController,
            'received':receivedController,
            'payment': paymentController
          };
          setDetails(detailResults, element, receivedController,
              paymentController,descController,
              chartAccount);

          _chartAccounts.add(chartAccount);
        });
        break;
      case 'bank':
        List<Map<String,dynamic>> results = await service.getBankChartAccounts();
        results.forEach((element){

          TextEditingController receivedController = TextEditingController();
          TextEditingController paymentController = TextEditingController();
          TextEditingController descController = TextEditingController();
          Map<String,dynamic> _chartAccount = {

            'acc_id': element['acc_id'],
            'acc_name': element['acc_name'],
            'acc_code': element['acc_code'],
            'isActive':false,
            'voucher_type':element['voucher_type'],
            'isReceivable':element['isReceivable'],
            'isPayable': element['isPayable'],
            'description': descController,
            'received': receivedController,
            'payment': paymentController
          };
          setBankDetails(detailResults, element, receivedController, paymentController, descController, _chartAccount);
          _chartAccounts.add(_chartAccount);
        });
    }


    if(mounted) {
      setState(() {
        ca = null;
        openingBalance = _openingBalance;
        closingBalance = _openingBalance + (totalReceived - totalPayment);
        chartAccounts = _chartAccounts;
        if( editVoucher!=null ) {
          calculateTotal();
        }
      });
    }
  }
}