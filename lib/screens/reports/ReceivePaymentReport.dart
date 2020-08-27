import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gaccounts/persistance/entity/User.dart';
import 'package:gaccounts/persistance/repository/UserRepository.dart';
import 'package:gaccounts/persistance/services/UserService.dart';
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

  TotalRow(String caption){
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
              child: pw.Text("0.00")
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
              child: pw.Text("0.00")
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
              child: pw.Text("0.00")
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

  GenerateRow(){
    rows.add(TitleBar());
    rows.add(SectionHeader("Receipts"));
    rows.add(TotalRow("Total Receipts"));

    rows.add(SectionHeader("Payments"));
    rows.add(TotalRow("Total Payments"));
    rows.add(NetTotalRow());
  }

  Future<void> GenerateReport() async{
    pdf.addPage(pw.MultiPage(
        margin: pw.EdgeInsets.all(10),
        pageFormat: PdfPageFormat.a4,
        build:(pw.Context context){
          GenerateRow();
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