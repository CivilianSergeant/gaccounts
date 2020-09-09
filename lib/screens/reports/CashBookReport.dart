import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gaccounts/config/AppConfig.dart';
import 'package:gaccounts/persistance/entity/Bank.dart';
import 'package:gaccounts/persistance/entity/Cash.dart';
import 'package:gaccounts/persistance/entity/CashBook.dart';
import 'package:gaccounts/persistance/entity/User.dart';
import 'package:gaccounts/persistance/repository/AccTrxMasterRepository.dart';
import 'package:gaccounts/persistance/repository/UserRepository.dart';
import 'package:gaccounts/persistance/services/AccTrxMasterService.dart';
import 'package:gaccounts/persistance/services/UserService.dart';
import 'package:gaccounts/screens/reports/PdfViewer.dart';
import 'package:gaccounts/widgets/TextFieldExt.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class CashBookReport extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _CashBookReportState();

}


class _CashBookReportState extends State<CashBookReport>{
  MethodChannel platform = MethodChannel("scanner");

  DateTime today = DateTime.now();
  DateFormat formatter = DateFormat('yyyy-MM-dd');
  List<Map<String,dynamic>> cashResults = [];
  List<Map<String,dynamic>> bankResults = [];
  double cashOpeningBalance = 0;
  double cashClosingBalance = 0;
  double bankOpeningBalance = 0;
  double bankClosingBalance = 0;
  double totalCashReceived = 0;
  double totalCashPayment = 0;
  double totalBankReceived = 0;
  double totalBankPayment = 0;
  List<pw.TableRow> cashBooks = [];
  User user;
  Map<String,dynamic> profile;

  final pdf = pw.Document();

  int fromStartYear;
  int fromEndYear;
  DateTime fromDay;
  DateTime fromInitial;

  TextEditingController fromDate = TextEditingController();

  Future<void> generatePDf() async{

    await GenerateRow();

    pdf.addPage(
      
      pw.MultiPage(
        margin: pw.EdgeInsets.all(10),
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context){

          return <pw.Widget>[
            pw.SizedBox(height: 40),
            pw.Container(
                alignment: pw.Alignment.center,
                child: pw.Text("gAccounts",style: pw.TextStyle(
                    fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColor.fromHex(("0e4b61"))
                ))
            ),
            pw.Row(
              children: [

                pw.Column(
                  mainAxisAlignment: pw.MainAxisAlignment.start,
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text("${profile['name']}"),
                    pw.Text("Contact No:${user.username}"),
                    pw.Text("Date: ${fromDate.text}")
                  ]
                )
              ]
            ),
            pw.SizedBox(height: 10),
            pw.Header(
                level: 0,
                child: pw.Text("Cash Book")
            ),
            pw.Table(

               children: cashBooks
            )
          ];
        }
      ));

    String dirPath = (await getExternalStorageDirectory()).path;
    DateTime dt = DateTime.now();
    String filename = '${dirPath}/cashbook-${formatter.format(dt)}-${dt.hour}-${dt.minute}-${dt.second}.pdf';
    AppConfig.log(filename);
    File f = File(filename);
    f.writeAsBytesSync(pdf.save());
    platform.invokeMethod("scanFile", {'path':filename});

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context)=> PdfViewer(path: filename,)
      )
    );
  }

  Future<void> GenerateRow() async{
    cashBooks.add(PdfRow());
    cashBooks.add(PdfRowData(CashBook(
      voucherNo: "",
      accountCode: '',
      accountName: '',
      cash: Cash(received: "Received", payment: "Payment"),
      bank: Bank(received: "Received",payment: "Payment")
    )));
    cashBooks.add(PdfRowData(CashBook(
        voucherNo: "",
        accountCode: '',
        accountName: ' Opening Balance',
        cash: Cash(received: "${cashOpeningBalance}", payment: ""),
        bank: Bank(received: "${bankOpeningBalance}",payment: "")
    )));
    cashResults.forEach((element) {

      cashBooks.add(PdfRowData(CashBook(
        voucherNo: element['voucher_no'],
        accountCode: element['acc_code'],
        accountName: element['acc_name'],
        description: element['narration'],
        cash: Cash(received: (element['credit'] !=null)? element['credit'].toString(): "0",
            payment: (element['debit']!=null)? element['debit'].toString(): "0"),
        bank: Bank(received: "0",payment: "0")

      )));

    });
    bankResults.forEach((element) {
      cashBooks.add(PdfRowData(CashBook(
        voucherNo: element['voucher_no'],
        accountCode:element['acc_code'],
        accountName: element['acc_name'],
        description: element['narration'],
        cash:Cash(received: "0",payment: "0"),
        bank:Bank(received: (element['credit']!=null)? element['credit'].toString() : "0",
        payment: (element['debit']!=null)?element['debit'].toString():"0")
      )));
    });
    cashBooks.add(PdfRowData(CashBook(
        voucherNo: "",
        accountCode: '',
        accountName: ' Closing Balance',
        cash: Cash(received: "${cashClosingBalance}", payment: ""),
        bank: Bank(received: "${bankClosingBalance}",payment: "")
    )));
    setState(() {

    });
  }

  pw.TableRow PdfRow(){
    return pw.TableRow(

        children: <pw.Widget>[
          pw.Container(
             width: 38,
              alignment: pw.Alignment.center,
              child: pw.Text("Voucher No"),
              decoration: pw.BoxDecoration(
                  border: pw.BoxBorder(
                      top: true,
                      left: true,
                      bottom: true,
                      right: true
                  )
              )
          ),
          pw.Container(
              width: 145,
              alignment: pw.Alignment.center,
              child: pw.Text("Account Description"),
              decoration: pw.BoxDecoration(
                  border: pw.BoxBorder(
                      top: true,
                      left: true,
                      bottom: true,
                      right: true
                  )
              )
          ),
          pw.Container(
              width:80,
              alignment: pw.Alignment.center,
              child: pw.Text("Cash"),
              decoration: pw.BoxDecoration(
                  border: pw.BoxBorder(
                      top: true,
                      left: true,
                      bottom: true,
                      right: true
                  )
              )
          ),
          pw.Container(
              width: 80,
              alignment: pw.Alignment.center,
              child: pw.Text("Bank"),
              decoration: pw.BoxDecoration(
                  border: pw.BoxBorder(
                      top: true,
                      left: true,
                      bottom: true,
                      right: true
                  )
              )
          ),

        ]
    );
  }
  pw.TableRow PdfRowData(CashBook cashBook){
    double widthReceived=70;
    double widthPayment=65;
    double rowHeight=30;
    var desc = cashBook.description; //"DescriptioDescriptioDescriptioDescriptioDescriptioDescriptioDescriptioDescriptio";
    if(desc !=null && desc.length>45){
      desc = desc.substring(0,45)+"\r\n"+desc.substring(45,desc.length);
      rowHeight=60;
    }else{
      rowHeight=20;
    }
    return pw.TableRow(

        children: <pw.Widget>[
          pw.Container(
              width: 38,
              height: rowHeight,
              alignment: pw.Alignment.center,
              child: pw.Text("${cashBook.voucherNo}"),
              decoration: pw.BoxDecoration(
                  border: pw.BoxBorder(
                      top: true,
                      left: true,
                      bottom: true,
                      right: true
                  )
              )
          ),
          pw.Container(
              width: 145,
              height: rowHeight,
              alignment: pw.Alignment.topLeft,
              child: pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.start,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(" ${cashBook.accountCode} - ${cashBook.accountName}"),
                  pw.Container(
                    width:145,
                    child: pw.Text(" ${(desc!=null)?desc:""}")
                  )  ]
              ),
              decoration: pw.BoxDecoration(
                  border: pw.BoxBorder(
                      top: true,
                      left: true,
                      bottom: true,
                      right: true
                  )
              )
          ),

          pw.Container(
              width:80,
              height: rowHeight,
              alignment: pw.Alignment.center,
              child: pw.Row(
                children: <pw.Widget>[
                  pw.Container(
                    width:widthReceived,
                    height: rowHeight,
                    padding: pw.EdgeInsets.only(left: 5,right: 5),
                    alignment: pw.Alignment.centerRight,
                    child:pw.Text(" ${cashBook.cash.received}",textAlign: pw.TextAlign.right),
                    decoration: pw.BoxDecoration(
                      border:pw.BoxBorder(
                        right: true
                      )
                    )
                  ),
                  pw.Container(
                      width:widthPayment,
                      height: rowHeight,
                      padding: pw.EdgeInsets.only(left: 5,right: 5),
                      alignment: pw.Alignment.centerRight,
                      child: pw.Text(" ${cashBook.cash.payment}",textAlign: pw.TextAlign.right),
                      decoration: pw.BoxDecoration(
                          border:pw.BoxBorder(
                              right: true
                          )
                      )
                  )

              ]),
              decoration: pw.BoxDecoration(
                  border: pw.BoxBorder(
                      top: true,
                      left: true,
                      bottom: true,
                      right: true
                  )
              )
          ),
          pw.Container(
              width:80,
              height: rowHeight,
              alignment: pw.Alignment.center,
              child: pw.Row(
                  children: <pw.Widget>[
                    pw.Container(
                        padding: pw.EdgeInsets.only(left: 5,right: 5),
                        alignment: pw.Alignment.centerRight,
                        height: rowHeight,
                        width:widthReceived,
                        child:pw.Text(" ${cashBook.bank.received}",textAlign: pw.TextAlign.right),
                        decoration: pw.BoxDecoration(
                            border:pw.BoxBorder(
                                right: true
                            )
                        )
                    ),
                    pw.Container(
                        padding: pw.EdgeInsets.only(left: 5,right: 5),
                        alignment: pw.Alignment.centerRight,
                        height: rowHeight,
                        width:widthPayment,
                        child: pw.Text(" ${cashBook.bank.payment}",textAlign: pw.TextAlign.right),
                        decoration: pw.BoxDecoration(
                            border:pw.BoxBorder(
                                right: true
                            )
                        )
                    )

                  ]),
              decoration: pw.BoxDecoration(
                  border: pw.BoxBorder(
                      top: true,
                      left: true,
                      bottom: true,
                      right: true
                  )
              )
          ),


        ]
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Cash Book"),
        actions: <Widget>[
          FlatButton(
            child: Icon(Icons.picture_as_pdf,color: Colors.white,),
            onPressed: (){

              generatePDf();
            },
          )
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child:Column(
            children: <Widget>[
              TextFieldExt(
                  hintText: "From Date",
                  icon: Icons.date_range,
                  controller: fromDate,
                  readonly: true,
                  borderRadius: 20,
                  topPad: 15,
                  onTap:(){
                    showDatePicker(context: context, initialDate:fromInitial , firstDate: DateTime(fromStartYear), lastDate: DateTime(fromEndYear))
                        .then((date){
                      if(date != null){
                        fromDate.text = (date.toString().substring(0,11).trim());
                        loadCashBook();
                        setState(() {
                          fromInitial = DateTime.parse(fromDate.text);
                        });
                        //                             getAgeInWords();
                      }else{
                        DateTime dt = DateTime.now();
                        String _date = formatter.format(dt);
                        setState(() {
                          fromInitial = dt;
                        });
                        fromDate.text= _date;
                        loadCashBook();
                      }
                    });
                  }
              ),
               SizedBox(height:10,),
               SectionCaption("Cash"),
               Title(),
               OpeningBalance(cashOpeningBalance),
              Container(
                height: MediaQuery.of(context).size.height-290,//(chartAccounts.length>0)? ((chartAccounts.length>=7)? 224 : (chartAccounts.length * 32.0)) : 0,
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
                    itemCount: cashResults.length,//chartAccounts.length+1,
                    itemBuilder: (context,i){
                      dynamic result = cashResults[i];
                      return ItemRow(result);
                    }),
              ),
              ClosingBalance(cashClosingBalance),
              SectionCaption("Bank"),
              Title(),
              OpeningBalance(bankOpeningBalance),
              Container(
                height: MediaQuery.of(context).size.height-290,//(chartAccounts.length>0)? ((chartAccounts.length>=7)? 224 : (chartAccounts.length * 32.0)) : 0,
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
                    itemCount: bankResults.length,//chartAccounts.length+1,
                    itemBuilder: (context,i){
                      dynamic result = bankResults[i];
                      return ItemRow(result);
                    }),
              ),
              ClosingBalance(bankClosingBalance),
            ],
          )
        ),
      ),
    );
  }

  Widget SectionCaption(String caption){
    Color bg = Color(0x5f5fa5fc);
    double rowHeight=35;
    return Row(
      children: <Widget>[
        Container(
          width: 360,
          height: rowHeight,
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: EdgeInsets.only(left: 10),
            child: Text("${caption}",style: TextStyle(
                fontWeight: FontWeight.w600,
              fontSize: 20
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
      ],
    );
  }

  Widget OpeningBalance(double balance){
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
            child: Text("Openging Balance",style: TextStyle(
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
          child: Text("${balance !=null ? balance.toString() : 0}",style: TextStyle(
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
          child: Text("0",style: TextStyle(
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


  Widget ClosingBalance(double balance){
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
            child: Text("Closing Balance",style: TextStyle(
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
          child: Text("${(balance!=null)? balance : 0}",style: TextStyle(
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
          child: Text("0",style: TextStyle(
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

  Widget ItemRow(dynamic item){
    AppConfig.log(item);
    Color bg = Color(0xffffffff);
    double rowHeight=66;
    var desc = (item['narration'] != null)? item['narration'] : '';
    AppConfig.log("${item['acc_code']} ${desc.length}");
    rowHeight = (desc.length<=28)? 50 : (desc.length<=58)? 66 : 82;
    return Row(
      children: <Widget>[
        Container(
          width: 190,

          alignment: Alignment.centerLeft,
          child: Padding(
            padding: EdgeInsets.only(left: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[

              Text("${item['acc_code']} ${item['acc_name']}",style: TextStyle(
                fontWeight: FontWeight.w600
              ),),
              Text("Voucher No: ${item['voucher_no']}"),
              Text("${desc}")
              ],
            ),
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
          child: Text("${(item['credit']!=null)?item['credit']:0}",style: TextStyle(
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
          child: Text("${(item['debit']!=null)?item['debit']:0}",style: TextStyle(
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

  @override
  void initState() {

    fromDay = DateTime.now();
    fromStartYear = (fromDay.year);
    fromEndYear = (fromDay.year+10);
    fromInitial = DateTime.now();
    fromDate.text = formatter.format(fromInitial);

    loadCashBook();
  }

  void setClosingBalance(){

    AppConfig.log("CASH CLOSING: ${cashOpeningBalance} - ${totalCashReceived}");
      cashClosingBalance = (cashOpeningBalance+(totalCashReceived-totalCashPayment));

      bankClosingBalance = (bankOpeningBalance+(totalBankReceived-totalBankPayment));
//      AppConfig.debug("CASH CLOSING: ${cashClosingBalance}");
//      if(totalBankReceived>totalBankPayment){
//        bankClosingBalance = bankOpeningBalance - totalBankReceived;
//      }else{
//        bankClosingBalance = bankOpeningBalance + totalBankPayment;
//      }

  }

  Future<void> loadCashBook() async {



    String toDate = fromDate.text; //formatter.format(today);
    UserService userService = UserService(userRepo: UserRepository());
    user = await userService.checkCurrentUser();
    profile = await userService.getProfile(user.profileId);
    AccTrxMasterService accTrxMasterService = AccTrxMasterService(masterRepo: AccTrxMasterRepository());
    double _openingBalance = await accTrxMasterService.getOpeningBalance('ca', toDate);
    double _bankOpeningBalance = await accTrxMasterService.getOpeningBalance('bc', toDate);
    List<Map<String,dynamic>> _results = await accTrxMasterService.getCashBook(toDate);
    List<Map<String,dynamic>> _cash = [];
    List<Map<String,dynamic>> _bank = [];

    AppConfig.log("CASH OPENING BLANACE: ${_openingBalance}");
    AppConfig.log("BANK OPENING BLANACE: ${_bankOpeningBalance}");

    _results.forEach((element) {
        if(element['voucher_type']=='bank'){
          if(!element['narration'].toString().contains('cash-in-hand')) {
            totalBankReceived += (element['credit']!=null)?element['credit']:0;
            totalBankPayment += (element['debit']!=null)? element['debit']:0;
            _bank.add(element);
          }
        }else{
          if(!element['narration'].toString().contains('cash-in-hand')) {
            totalCashReceived += (element['credit']!=null)?element['credit']:0;
            totalCashPayment += (element['debit']!=null)? element['debit']:0;
            _cash.add(element);
          }
        }
    });

    if(mounted){

      setState(() {
        cashOpeningBalance = _openingBalance;
        bankOpeningBalance = _bankOpeningBalance;
        setClosingBalance();
        cashResults = _cash;
        bankResults = _bank;
      });
    }

  }

}