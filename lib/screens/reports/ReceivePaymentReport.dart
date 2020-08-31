import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gaccounts/config/AppConfig.dart';
import 'package:gaccounts/persistance/entity/User.dart';
import 'package:gaccounts/persistance/repository/AccTrxMasterRepository.dart';
import 'package:gaccounts/persistance/repository/UserRepository.dart';
import 'package:gaccounts/persistance/services/AccTrxMasterService.dart';
import 'package:gaccounts/persistance/services/UserService.dart';
import 'package:gaccounts/persistance/services/ChartAccountService.dart';
import 'package:gaccounts/persistance/repository/ChartAccountRepository.dart';
import 'package:gaccounts/screens/reports/PdfViewer.dart';
import 'package:gaccounts/widgets/ActionButton.dart';
import 'package:gaccounts/widgets/TextFieldExt.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class ReceivePaymentReport extends StatefulWidget{
  @override
  State<StatefulWidget> createState()=> _ReceivePaymentReportState();

}

class _ReceivePaymentReportState extends State<ReceivePaymentReport>{

  MethodChannel platform = MethodChannel("scanner");

  int fromStartYear;
  int fromEndYear;
  DateTime fromDay;
  DateTime fromInitial;

  int toStartYear;
  int toEndYear;
  DateTime toDay;
  DateTime toInitial;

  TextEditingController fromDate = TextEditingController();
  TextEditingController toDate = TextEditingController();

  User user;

  final pdf = pw.Document();
  List<pw.TableRow> rows = [];

  @override
  void initState() {
    fromDay = DateTime.now();
    fromStartYear = (fromDay.year);
    fromEndYear = (fromDay.year+10);
    fromInitial = DateTime.now();

    toDay = DateTime.now();
    toStartYear = (toDay.year);
    toEndYear = (toDay.year+10);
    toInitial = DateTime.now();

    loadInfo();
  }

  Future<void> loadInfo() async{
    UserService userService = UserService(userRepo: UserRepository());
    User _user = await userService.checkCurrentUser();
    if(mounted) {
      setState(() {
        user = _user;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text("Receipts & Payment Report"),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            child: Column(
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

                        setState(() {
                          fromInitial = DateTime.parse(fromDate.text);
                        });
  //                             getAgeInWords();
                      }else{
                        fromDate.text="";
                      }
                    });
                  }
                ),
                TextFieldExt(
                  hintText: "To Date",
                  icon: Icons.date_range,
                  controller: toDate,
                  readonly: true,
                  borderRadius: 20,
                  topPad: 15,
                  onTap:(){
                    showDatePicker(context: context, initialDate:toInitial , firstDate: DateTime(toStartYear), lastDate: DateTime(toEndYear))
                        .then((date){
                      if(date != null){
                        toDate.text = (date.toString().substring(0,11).trim());

                        setState(() {
                          toInitial = DateTime.parse(toDate.text);
                        });
//                             getAgeInWords();
                      }else{
                        toDate.text="";
                      }
                    });
                  }
                ),
                SizedBox(height: 20,),
                ActionButton(
                  width: MediaQuery.of(context).size.width-40,
                  onTap: () async{
                    await GenerateReport();
                  },
                  caption: "Show Report",
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  TitleBar(){
    return pw.TableRow(
        children: <pw.Widget>[
          pw.Container(
              width:50,
              child: pw.Text("Code")
          ),
          pw.Container(
              width: 100,
              child: pw.Text("Description")
          ),
          pw.Container(
              width:40,
              alignment: pw.Alignment.centerRight,
              child: pw.Text("Prev. Month")
          ),
          pw.Container(
              width: 40,
              alignment: pw.Alignment.centerRight,
              child: pw.Text("Current Month")
          ),
          pw.Container(
              width: 40,
              alignment: pw.Alignment.centerRight,
              child: pw.Text("To Date")
          ),
        ]
    );
  }

  SectionHeader(String caption){
    return pw.TableRow(
        children: <pw.Widget>[
          pw.Container(
              width: 50,
              margin: pw.EdgeInsets.only(top: 10),
              decoration: pw.BoxDecoration(
                  border: pw.BoxBorder(
                      top: true
                  )
              ),
              child: pw.Text("${caption}",style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold
              ))
          ),
          pw.Container(
              width: 100,
              margin: pw.EdgeInsets.only(top: 10),
              decoration: pw.BoxDecoration(
                  border: pw.BoxBorder(
                      top: true
                  )
              ),
              child: pw.Text("")
          ),
          pw.Container(
              width:40,
              margin: pw.EdgeInsets.only(top: 10),
              decoration: pw.BoxDecoration(
                  border: pw.BoxBorder(
                      top: true
                  )
              ),
              child: pw.Text("")
          ),
          pw.Container(
              width: 40,
              margin: pw.EdgeInsets.only(top: 10),
              decoration: pw.BoxDecoration(
                  border: pw.BoxBorder(
                      top: true
                  )
              ),
              child: pw.Text("")
          ),
          pw.Container(
              width: 40,
              margin: pw.EdgeInsets.only(top: 10),
              decoration: pw.BoxDecoration(
                  border: pw.BoxBorder(
                      top: true
                  )
              ),
              child: pw.Text("")
          ),
        ]
    );
  }

  TotalRow(String caption,double prev,double cur, double balance){
    return pw.TableRow(
        children: <pw.Widget>[
          pw.Container(
              width: 50,
              margin: pw.EdgeInsets.only(top: 10),

              child: pw.Text("${caption}",style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold
              ))
          ),
          pw.Container(
              width: 100,
              margin: pw.EdgeInsets.only(top: 10),

              child: pw.Text("")
          ),
          pw.Container(
              width:40,
              alignment: pw.Alignment.centerRight,
              margin: pw.EdgeInsets.only(top: 10),
              decoration: pw.BoxDecoration(
                  border: pw.BoxBorder(
                      top: true,
                      bottom: true
                  )
              ),
              child: pw.Text("${prev}")
          ),
          pw.Container(
              width: 40,
              alignment: pw.Alignment.centerRight,
              margin: pw.EdgeInsets.only(top: 10,left:10),
              decoration: pw.BoxDecoration(
                  border: pw.BoxBorder(
                      top: true,
                      bottom: true
                  )
              ),
              child: pw.Text("${cur}")
          ),
          pw.Container(
              width: 40,

              alignment: pw.Alignment.centerRight,
              margin: pw.EdgeInsets.only(top: 10,left: 10),
              decoration: pw.BoxDecoration(
                  border: pw.BoxBorder(
                      top: true,
                      bottom: true
                  )
              ),
              child: pw.Text("${balance}")
          ),
        ]
    );
  }

  NetTotalRow(){
    return pw.TableRow(
        children: <pw.Widget>[
          pw.Container(
              width: 40,
              margin: pw.EdgeInsets.only(top: 10),
              decoration: pw.BoxDecoration(
                  border: pw.BoxBorder(
                      left: true,
                      top: true,
                      bottom: true
                  )
              ),
              child: pw.Text(".",style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColor.fromHex("fff")
              ))
          ),
          pw.Container(
              width: 100,
              margin: pw.EdgeInsets.only(top: 10),
              alignment: pw.Alignment.centerRight,
              decoration: pw.BoxDecoration(
                  border: pw.BoxBorder(
                      top: true,
                      bottom: true
                  )
              ),
              child: pw.Text("Net Profit (Loss):")
          ),
          pw.Container(
              width:40,
              alignment: pw.Alignment.centerRight,
              margin: pw.EdgeInsets.only(top: 10),
              decoration: pw.BoxDecoration(
                  border: pw.BoxBorder(
                      top: true,
                      bottom: true
                  )
              ),
              child: pw.Text("0.00")
          ),
          pw.Container(
              width: 40,
              alignment: pw.Alignment.centerRight,
              margin: pw.EdgeInsets.only(top: 10),
              decoration: pw.BoxDecoration(
                  border: pw.BoxBorder(
                      top: true,
                      bottom: true
                  )
              ),
              child: pw.Text("0.00")
          ),
          pw.Container(
              width: 40,

              alignment: pw.Alignment.centerRight,
              margin: pw.EdgeInsets.only(top: 10),
              decoration: pw.BoxDecoration(
                  border: pw.BoxBorder(
                      top: true,
                      bottom: true,
                      right: true
                  )
              ),
              child: pw.Text("0.00")
          ),
        ]
    );
  }

  SectionItemRow(String code,String accName, double prev, double current, double toDate){
    return pw.TableRow(
        children: <pw.Widget>[
          pw.Container(
              width: 50,
              margin: pw.EdgeInsets.only(top: 10),
              decoration: pw.BoxDecoration(
                  border: pw.BoxBorder(
//                      top: true
                  )
              ),
              child: pw.Text("${code}")
          ),
          pw.Container(
              width: 100,
              margin: pw.EdgeInsets.only(top: 10),
              decoration: pw.BoxDecoration(
                  border: pw.BoxBorder(
//                      top: true
                  )
              ),
              child: pw.Text("${accName}")
          ),
          pw.Container(
              width:40,
              margin: pw.EdgeInsets.only(top: 10),
              alignment: pw.Alignment.centerRight,
              decoration: pw.BoxDecoration(
                  border: pw.BoxBorder(
//                      top: true
                  )
              ),
              child: pw.Text("${prev.toString()}")
          ),
          pw.Container(
              width: 40,
              margin: pw.EdgeInsets.only(top: 10),
              alignment: pw.Alignment.centerRight,
              decoration: pw.BoxDecoration(
                  border: pw.BoxBorder(
//                      top: true
                  )
              ),
              child: pw.Text("${current.toString()}")
          ),
          pw.Container(
              width: 40,
              margin: pw.EdgeInsets.only(top: 10),
              alignment: pw.Alignment.centerRight,
              decoration: pw.BoxDecoration(
                  border: pw.BoxBorder(
//                      top: true
                  )
              ),
              child: pw.Text("${toDate.toString()}")
          ),
        ]
    );
  }

  Map<String,dynamic> _processReport(Map<String,dynamic> childElement,
      List<Map<String,dynamic>> currentResults, List<Map<String,dynamic>> prevResults,
  {String type}){
    Map<String,dynamic> current = {};
    Map<String,dynamic> prev = {};
    currentResults.forEach((ce) {

      if(childElement['acc_code'] == ce['acc_code']){
        current = ce;
      }
    });
    prevResults.forEach((_prev) {
      if(childElement['acc_code'] == _prev['acc_code']){
        prev = _prev;
      }
    });

    double prevCredit = (prev['credit']!=null)? prev['credit']: 0;
    double prevDebit = (prev['debit']!=null)? prev['debit']:0;
    double currentCredit = (current['credit']!=null)? current['credit']: 0;
    double currentDebit = (current['debit']!=null)? current['debit']:0;

    double prevAmount = (type=="receipt")? (prevCredit - prevDebit) : (prevDebit-prevCredit);
    double currentAmount =(type=="receipt")? (currentCredit - currentDebit) : (currentDebit - currentCredit);
    double balance =  (prevAmount + currentAmount);
    return {
      'prevAmount':prevAmount,
      'currentAmount': currentAmount,
      'balance': balance
    };
  }

  Future<void> GenerateRow() async{
    ChartAccountService chartAccService = ChartAccountService(repo: ChartAccountRepository());
    AccTrxMasterService masterService = AccTrxMasterService(masterRepo: AccTrxMasterRepository());

    List<Map<String,dynamic>> receivedAccounts = await chartAccService.getReceivedChartAccounts();
    List<Map<String,dynamic>> paymentAccounts = await chartAccService.getPaymentChartAccounts();
    Map<String,dynamic> cashInHand = await chartAccService.getCashAccount();
    Map<String,dynamic> cashAtBank = await chartAccService.getBankAccount();

    String startDate = fromDate.text;
    String endDate = toDate.text;

    Map<String,dynamic> results = await masterService.getAccountsBalance(startDate, endDate,upToPrev: true);
    double bankOpeningBalance = await masterService.getBankOpeningBalance(endDate);
    double bankPrevOpeningBalance = await masterService.getBankOpeningBalance(startDate);

    double currentOpeningBalance = await masterService.getOpeningBalance(null, endDate);
    double prevOpeningBalance = await masterService.getOpeningBalance(null, startDate);

    List<Map<String,dynamic>> currentResults = results['current'];
    List<Map<String,dynamic>> prevResults = results['prev'];

    double totalPrevReceipt = 0;
    double totalPrevPayment = 0;
    double totalCurReceipt = 0;
    double totalCurPayment = 0;
    double totalBalanceReceipt=0;
    double totalBalancePayment=0;



    rows.add(TitleBar());
    rows.add(SectionHeader("Opening Balance"));
    double balanceCashOpening = (prevOpeningBalance+currentOpeningBalance);
    double balanceBankOpening = (bankPrevOpeningBalance+bankOpeningBalance);
    rows.add(SectionItemRow(cashInHand['acc_code'],cashInHand['acc_name'],prevOpeningBalance,currentOpeningBalance,balanceCashOpening));
    rows.add(SectionItemRow(cashAtBank['acc_code'],cashAtBank['acc_name'],bankPrevOpeningBalance,bankOpeningBalance,balanceBankOpening));
    rows.add(SectionHeader("Receipts"));
    receivedAccounts.forEach((element){
      Map<String,dynamic> data = _processReport(element, currentResults, prevResults,type:"receipt");
      double prevAmount = data['prevAmount'];
      double currentAmount = data['currentAmount'];
      double balance = data['balance'];

      totalPrevReceipt += prevAmount;
      totalCurReceipt += currentAmount;
      totalBalanceReceipt+= balance;
      rows.add(SectionItemRow(element['acc_code'], element['acc_name'],prevAmount,currentAmount,balance));
    });
    rows.add(TotalRow("Total Receipts",totalPrevReceipt,totalCurReceipt,totalBalanceReceipt));

    rows.add(SectionHeader("Payments"));
    paymentAccounts.forEach((element){
      Map<String,dynamic> data = _processReport(element, currentResults, prevResults,type:"payment");
      double prevAmount = data['prevAmount'];
      double currentAmount = data['currentAmount'];
      double balance = data['balance'];

      totalPrevPayment += prevAmount;
      totalCurPayment += currentAmount;
      totalBalancePayment += balance;
      rows.add(SectionItemRow(element['acc_code'], element['acc_name'], prevAmount.abs(), currentAmount.abs(), balance.abs()));
    });

//    AppConfig.log("R: ${totalPrevReceipt}  P: ${totalPrevPayment} T: ${totalPrevReceipt+totalPrevPayment}");
    double closingPrevCashBalance = prevOpeningBalance+ (totalPrevReceipt.abs() - totalPrevPayment.abs());
    double closingCurCashBalance = currentOpeningBalance+ (totalCurReceipt.abs() - totalCurPayment.abs());
    double closingBalanceCashBalance = balanceCashOpening + (totalBalanceReceipt.abs() - totalBalancePayment.abs());

    rows.add(TotalRow("Total Payments",totalPrevPayment,totalCurPayment,totalBalancePayment));
    rows.add(SectionHeader("Closing Balance"));
    rows.add(SectionItemRow(cashInHand['acc_code'],cashInHand['acc_name'],closingPrevCashBalance,closingCurCashBalance,closingBalanceCashBalance));
    rows.add(SectionItemRow(cashAtBank['acc_code'],cashAtBank['acc_name'],bankPrevOpeningBalance,bankOpeningBalance,balanceBankOpening));
  }

  Future<void> GenerateReport() async{
    await GenerateRow();
    pdf.addPage(pw.MultiPage(
        margin: pw.EdgeInsets.all(10),
        pageFormat: PdfPageFormat.a4,
        build:(pw.Context context){

          return <pw.Widget>[
            pw.SizedBox(height: 40),
            pw.Row(
                children: [
                  pw.Column(
                      mainAxisAlignment: pw.MainAxisAlignment.start,
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text("${user.username}"),
                        pw.Text("Date: "+fromDate.text+" - "+toDate.text)
                      ]
                  )
                ]
            ),
            pw.SizedBox(height: 10),
            pw.Header(
                level: 0,
                child: pw.Text("Receipts & Payments")
            ),
            pw.Table(

                children: rows
            )
          ];
        }
    ));

    String dir = (await getExternalStorageDirectory()).path;
    String filename = "${dir}/received_payment_report.pdf";
    File f = File(filename);
    f.writeAsBytesSync(pdf.save());
    platform.invokeMethod("scanFile", {'path':filename});

    Navigator.of(context).push(
        MaterialPageRoute(
            builder: (context)=> PdfViewer(path: filename,)
        )
    );
  }

}