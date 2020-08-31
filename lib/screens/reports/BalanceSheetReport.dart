import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gaccounts/config/AppConfig.dart';
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

class BalanceSheetReport extends StatefulWidget{
  @override
  State<StatefulWidget> createState()=> _BalanceSheetReportState();

}

class _BalanceSheetReportState extends State<BalanceSheetReport>{

  MethodChannel platform = MethodChannel("scanner");

  int fromStartYear;
  int fromEndYear;
  DateTime fromDay;
  DateTime fromInitial;

  int toStartYear;
  int toEndYear;
  DateTime toDay;
  DateTime toInitial;

//  TextEditingController fromDate = TextEditingController();
//  TextEditingController toDate = TextEditingController();

  String fromDate="";
  String toDate = "";

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
        title: Text("Balance Sheet Report"),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            alignment: Alignment.topCenter,
            child: Column(
              children: <Widget>[
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
              width: 80,
              child: pw.Text("Description")
          ),
          pw.Spacer(),
          pw.Container(
              width: 60,
              alignment: pw.Alignment.centerRight,
              child: pw.Text("Cur. Amount")
          ),
          pw.Container(
              width: 60,
              alignment: pw.Alignment.centerRight,
              child: pw.Text("Prv. Amount")
          ),
        ]
    );
  }

  PrimarySectionHeader(String code,String name){
    return pw.TableRow(
        children: <pw.Widget>[
          pw.Container(
              width: 60,
              margin: pw.EdgeInsets.only(top: 10),
              decoration: pw.BoxDecoration(
                  border: pw.BoxBorder(
                      top: true
                  )
              ),
              child: pw.Text("${code}",style: pw.TextStyle(
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
              child: pw.Text("${name}")
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

  SectionHeader(String code,String name){
    return pw.TableRow(
        children: <pw.Widget>[
          pw.Container(
              width: 60,
              margin: pw.EdgeInsets.only(top: 10),

              child: pw.Text("${code}",style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold
              ))
          ),
          pw.Container(
              width: 100,
              margin: pw.EdgeInsets.only(top: 10),
              child: pw.Text("${name}",style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold
              ))
          ),
          pw.Container(
              width:40,
              margin: pw.EdgeInsets.only(top: 10),

              child: pw.Text("")
          ),
          pw.Container(
              width: 40,
              margin: pw.EdgeInsets.only(top: 10),

              child: pw.Text("")
          ),
          pw.Container(
              width: 40,
              margin: pw.EdgeInsets.only(top: 10),

              child: pw.Text("")
          ),
        ]
    );
  }

  TotalRow(String caption,double current, double prev){
    return pw.TableRow(
        children: <pw.Widget>[
          pw.Container(
              width: 40,
              margin: pw.EdgeInsets.only(top: 10),

              child: pw.Text("",style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold
              ))
          ),
          pw.Container(
              width: 80,
              margin: pw.EdgeInsets.only(top: 10),
              alignment: pw.Alignment.centerRight,
              child: pw.Text("${caption}",style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold
              ))
          ),
          pw.Spacer(),
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
              child: pw.Text("${current}")
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
              child: pw.Text("${prev}")
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

  SectionItemRow(String code,String accName,  double current, double prev, double toDate){
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
              child: pw.Text("")
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
              child: pw.Text("${prev.toString()}")
          ),
        ]
    );
  }

  TableRowDivider(){
    return pw.TableRow(
        children: [
          pw.Container(
              height: 10,
              margin: pw.EdgeInsets.only(top:5),
              decoration: pw.BoxDecoration(
                  border: pw.BoxBorder(top: true)
              )
          ),
          pw.Container(
              height: 10,
              margin: pw.EdgeInsets.only(top:5),
              decoration: pw.BoxDecoration(
                  border: pw.BoxBorder(top: true)
              )
          ),
          pw.Container(
              height: 10,
              margin: pw.EdgeInsets.only(top:5),
              decoration: pw.BoxDecoration(
                  border: pw.BoxBorder(top: true)
              )
          ),
          pw.Container(
              height: 10,
              margin: pw.EdgeInsets.only(top:5),
              decoration: pw.BoxDecoration(
                  border: pw.BoxBorder(top: true)
              )
          ),
          pw.Container(
              height: 10,
              margin: pw.EdgeInsets.only(top:5),
              decoration: pw.BoxDecoration(
                  border: pw.BoxBorder(top: true)
              )
          )
        ]
    );
  }

  Map<String,dynamic> _processReport(Map<String,dynamic> childElement,
      List<Map<String,dynamic>> currentResults, List<Map<String,dynamic>> prevResults,{String type}){
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

    AppConfig.log(current,line:"468");
    double prevCredit = (prev['credit']!=null)? prev['credit']: 0;
    double prevDebit = (prev['debit']!=null)? prev['debit']:0;
    double currentCredit = (current['credit']!=null)? current['credit']: 0;
    double currentDebit = (current['debit']!=null)? current['debit']:0;

    double prevAmount = (type=="asset")? (prevDebit-prevCredit) : (prevCredit - prevDebit);
    double currentAmount = (type=="asset")?(currentDebit-currentCredit):(currentCredit - currentDebit);
//    double balance = (prevAmount + currentAmount);
    return {
      'prevAmount':prevAmount,
      'currentAmount': currentAmount,
//      'balance': balance
    };
  }

  Future<void> GenerateRow() async{

    FindDate();

    ChartAccountService chartAccService = ChartAccountService(repo: ChartAccountRepository());
    AccTrxMasterService masterService = AccTrxMasterService(masterRepo: AccTrxMasterRepository());

    List<Map<String,dynamic>> assetAccounts = await chartAccService.getAssetParentAccounts();
    List<Map<String,dynamic>> assetSecondLevelAccounts = await chartAccService.getAssetSecondLevelAccounts();
    List<Map<String,dynamic>> assetThirdLevelAccounts = await chartAccService.getAssetThirdLevelAccounts();

    List<Map<String,dynamic>> liabilityAccounts = await chartAccService.getLiabilityParentAccounts();
    List<Map<String,dynamic>> liabilitySecondAccounts = await chartAccService.getLiabilitySecondLevelAccounts();
    List<Map<String,dynamic>> liabilityThirdAccounts = await chartAccService.getLiabilityThirdLevelAccounts();

    Map<String,dynamic> results = await masterService.getAccountsBalance(fromDate, toDate,upToPrev: true);
    List<Map<String,dynamic>> currentResults = results['current'];
    List<Map<String,dynamic>> prevResults = results['prev'];

    rows.add(TitleBar());
    rows.add(TableRowDivider());
    assetAccounts.forEach((firstLevel) {
        double sectionCurrentTotal=0;
        double sectionPrevTotal=0;
        rows.add(SectionHeader("${firstLevel['acc_name']}", ""));

        assetSecondLevelAccounts.forEach((secondLevel) {
          double subSectionCurrentTotal = 0;
          double subSectionPrevTotal = 0;
          rows.add(SectionHeader("","${secondLevel['acc_name']}"));
          assetThirdLevelAccounts.forEach((element) {
            if(element['second_level'] == secondLevel['acc_code']) {
              Map<String,dynamic> data = _processReport(element, currentResults, prevResults,type:'asset');
              subSectionCurrentTotal += data['currentAmount'];
              subSectionPrevTotal += data['prevAmount'];
              sectionCurrentTotal += subSectionCurrentTotal;
              sectionPrevTotal += subSectionPrevTotal;
              rows.add(SectionItemRow(
                  element['acc_code'], element['acc_name'], data['currentAmount'], data['prevAmount'], 0));
            }
          });
          rows.add(TotalRow("Total of ${secondLevel['acc_name']}",subSectionCurrentTotal,subSectionPrevTotal));
        });
        rows.add(TotalRow("Total of ${firstLevel['acc_name']}",sectionCurrentTotal,sectionPrevTotal));
    });
    rows.add(TableRowDivider());
    liabilityAccounts.forEach((firstLevel) {
      double sectionCurrentTotal = 0;
      double sectionPrevTotal=0;
      rows.add(SectionHeader("${firstLevel['acc_name']}", ""));
      liabilitySecondAccounts.forEach((secondLevel) {
        double subSectionCurrentTotal = 0;
        double subSectionPrevTotal = 0;
        rows.add(SectionHeader("","${secondLevel['acc_name']}"));
        liabilityThirdAccounts.forEach((element) {
          if(element['second_level'] == secondLevel['acc_code']) {
            Map<String,dynamic> data = _processReport(element, currentResults, prevResults,type:'liabilities');
            subSectionCurrentTotal += data['currentAmount'];
            subSectionPrevTotal += data['prevAmount'];
            sectionCurrentTotal += subSectionCurrentTotal;
            sectionPrevTotal += subSectionPrevTotal;
            rows.add(SectionItemRow(
                element['acc_code'], element['acc_name'], data['currentAmount'], data['prevAmount'], 0));
          }
        });
        rows.add(TotalRow("Total of ${secondLevel['acc_name']}",subSectionCurrentTotal,subSectionPrevTotal));
      });
      rows.add(TotalRow("Total of ${firstLevel['acc_name']}", sectionCurrentTotal, sectionPrevTotal));
    });


  }

  FindDate(){
    DateTime dt = DateTime.now();
    int month = dt.month;
    if(month<7){
        fromDate = "${(dt.year-1)}-07-01";
        toDate = "${dt.year}-06-30";
    }else{
       fromDate = "${dt.year}-07-01";
       toDate = "${dt.year+1}-06-30";
    }
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
                        pw.Text("Date: From ${fromDate} to ${toDate}")
                      ]
                  )
                ]
            ),
            pw.SizedBox(height: 10),
            pw.Header(
                level: 0,
                child: pw.Text("Balance Sheet")
            ),
            pw.Table(
                children: rows
            )
          ];
        }
    ));

    String dir = (await getExternalStorageDirectory()).path;
    String filename = "${dir}/balance_sheet_report.pdf";
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