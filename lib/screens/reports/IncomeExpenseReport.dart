import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gaccounts/persistance/entity/Amount.dart';
import 'package:gaccounts/persistance/entity/User.dart';
import 'package:gaccounts/persistance/repository/AccTrxMasterRepository.dart';
import 'package:gaccounts/persistance/repository/ChartAccountRepository.dart';
import 'package:gaccounts/persistance/repository/UserRepository.dart';
import 'package:gaccounts/persistance/services/AccTrxMasterService.dart';
import 'package:gaccounts/persistance/services/ChartAccountService.dart';
import 'package:gaccounts/persistance/services/UserService.dart';
import 'package:gaccounts/screens/reports/PdfViewer.dart';
import 'package:gaccounts/widgets/ActionButton.dart';
import 'package:gaccounts/widgets/TextFieldExt.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class IncomeExpenseReport extends StatefulWidget{
  @override
  State<StatefulWidget> createState()=> _IncomeExpenseReportState();

}

class _IncomeExpenseReportState extends State<IncomeExpenseReport>{

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

  Map<String,dynamic> profile;

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
    Map<String,dynamic> _profile = await userService.getProfile(_user.profileId);
    if(mounted) {
      setState(() {
        user = _user;
        profile = _profile;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text("Income & Expense Report"),
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
          width:40,
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

  SectionItemRow(String code,String accName, double prev, double current, double toDate){
    return pw.TableRow(
        children: <pw.Widget>[
          pw.Container(
              width: 40,
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

  SectionHeader(String caption){
    return pw.TableRow(
      children: <pw.Widget>[
        pw.Container(
          width: 40,
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

  TotalRow(String caption,double totalPrev, double totalCur, double totalToDate){
    return pw.TableRow(
        children: <pw.Widget>[
          pw.Container(
              width: 40,
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
              child: pw.Text("${totalPrev}")
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
              child: pw.Text("${totalCur}")
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
              child: pw.Text("${totalToDate}")
          ),
        ]
    );
  }

  NetTotalRow(String prev, String current, String balance){
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
              child: pw.Text("${prev}")
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
              child: pw.Text("${current}")
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
              child: pw.Text("${balance}")
          ),
        ]
    );
  }

  Map<String,dynamic> _processReport(Map<String,dynamic> childElement,List<Map<String,dynamic>> currentResults,
      List<Map<String,dynamic>> prevResults, {String type}){
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

    double prevAmount = (type=="income")? (prevCredit - prevDebit) : (prevDebit - prevCredit);
    double currentAmount = (type=="income")? (currentCredit - currentDebit) : (prevDebit - prevCredit);

    double balance = (prevAmount + currentAmount);
    return {
      'prevAmount':prevAmount,
      'currentAmount': currentAmount,
      'balance': balance
    };
  }

  Future<void> GenerateRow() async{
    ChartAccountService chartAccService = ChartAccountService(repo: ChartAccountRepository());
    AccTrxMasterService masterService = AccTrxMasterService(masterRepo: AccTrxMasterRepository());

    List<Map<String,dynamic>> incomeAccounts = await chartAccService.getIncomeAccounts();
    List<Map<String,dynamic>> expenseAccounts = await chartAccService.getExpenseAccounts();

    String startDate = fromDate.text;
    String endDate   = toDate.text;
    Map<String,dynamic> results = await masterService.getAccountsBalance(startDate, endDate);
    List<Map<String,dynamic>> currentResults = results['current'];
    List<Map<String,dynamic>> prevResults = results['prev'];

    double totalPrevIncome = 0;
    double totalPrevExpense = 0;
    double totalCurIncome = 0;
    double totalCurExpense = 0;
    double totalBalanceIncome=0;
    double totalBalanceExpense=0;


    rows.add(TitleBar());
    rows.add(SectionHeader("Income"));
    incomeAccounts.forEach((childElement) {

      Map<String,dynamic> data = _processReport(childElement, currentResults, prevResults,type:"income");
      double prevAmount = data['prevAmount'];
      double currentAmount = data['currentAmount'];
      double balance = data['balance'];

      totalPrevIncome += prevAmount;
      totalCurIncome += currentAmount;
      totalBalanceIncome+= balance;
      rows.add(SectionItemRow(childElement['acc_code'],childElement['acc_name'],prevAmount,currentAmount,balance));
    });

    rows.add(TotalRow("Total Income",totalPrevIncome,totalCurIncome,totalBalanceIncome));

    rows.add(SectionHeader("Expense"));
    expenseAccounts.forEach((childElement) {

      Map<String,dynamic> data = _processReport(childElement, currentResults, prevResults,type:"expense");
      double prevAmount = data['prevAmount'];
      double currentAmount = data['currentAmount'];
      double balance = data['balance'];

      totalPrevExpense+= prevAmount;
      totalCurExpense += currentAmount;
      totalBalanceExpense += balance;
      rows.add(SectionItemRow(childElement['acc_code'],childElement['acc_name'],prevAmount,currentAmount,balance));
    });

    rows.add(TotalRow("Total Expense",totalPrevExpense,totalCurExpense,totalBalanceExpense));
    double prevNetAmount = (totalPrevIncome-totalPrevExpense);
    double currentNetAmount = (totalCurIncome-totalCurExpense);
    double balanceNetAmount = (totalBalanceIncome-totalBalanceExpense);
    rows.add(NetTotalRow(
        (prevNetAmount<0)? "(${prevNetAmount.abs()})":"${prevNetAmount}",
        (currentNetAmount<0)? "(${currentNetAmount.abs()})": "${currentNetAmount}",
        (balanceNetAmount<0)? "(${currentNetAmount.abs()})" : "${balanceNetAmount}"
    ));
  }

  Future<void> GenerateReport() async{
    await GenerateRow();
    pdf.addPage(pw.MultiPage(
      margin: pw.EdgeInsets.all(10),
      pageFormat: PdfPageFormat.a4,
      build:(pw.Context context){

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
                      pw.Text("Contact No: ${user.username}"),
                      pw.Text("Date: "+fromDate.text+" - "+toDate.text)
                    ]
                )
              ]
          ),
          pw.SizedBox(height: 10),
          pw.Header(
              level: 0,
              child: pw.Text("Income & Expense")
          ),
          pw.Table(

              children: rows
          )
        ];
      }
    ));

    String dir = (await getExternalStorageDirectory()).path;
    String filename = "${dir}/income_expense_report.pdf";
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