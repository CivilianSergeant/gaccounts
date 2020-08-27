import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gaccounts/config/AppConfig.dart';
import 'package:gaccounts/persistance/entity/Amount.dart';
import 'package:gaccounts/persistance/entity/TrialBalanceSectionItem.dart';
import 'package:gaccounts/persistance/entity/User.dart';
import 'package:gaccounts/persistance/repository/ChartAccountRepository.dart';
import 'package:gaccounts/persistance/repository/UserRepository.dart';
import 'package:gaccounts/persistance/services/ChartAccountService.dart';
import 'package:gaccounts/persistance/services/UserService.dart';
import 'package:gaccounts/screens/reports/PdfViewer.dart';
import 'package:gaccounts/widgets/ActionButton.dart';
import 'package:gaccounts/widgets/TextFieldExt.dart';
import 'package:path_provider/path_provider.dart';

import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';

class TrialBalanceReport extends StatefulWidget{
  @override
  State<StatefulWidget> createState()=> _TrialBalanceReportState();

}

class _TrialBalanceReportState extends State<TrialBalanceReport>{

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

  StreamController<int> buttonPressed = StreamController<int>.broadcast();

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

    loadAccInfo();
  }

  Future<void> loadAccInfo() async{
    UserService userService = UserService(userRepo: UserRepository());
    User _user = await userService.checkCurrentUser();
    GenerateRow();
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
        title: Text("Trial Balance Report"),
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
                  stream: buttonPressed.stream,
                  onTap: () async{
                      buttonPressed.sink.add(1);
                      GenerateReport();

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
            width: 100,
            height:28,
            alignment: pw.Alignment.center,
            child: pw.Text("Account & Description"),
            decoration: pw.BoxDecoration(
              border: pw.BoxBorder(
                top: true,
                bottom: true,
                left: true,
                right: true
              )
            )
          ),
          pw.Container(
              width:80,
              alignment: pw.Alignment.centerRight,
              child: pw.Column(
                children: [
                  pw.Text("Previous"),
                  pw.Row(
                    children: [
                      pw.Container(
                        width:70,
                        child: pw.Text("Received"),
                        padding:pw.EdgeInsets.only(right: 5),
                        alignment: pw.Alignment.centerRight,
                        decoration: pw.BoxDecoration(
                          border: pw.BoxBorder(right: true,top:true)
                        )
                      ),
                      pw.Container(
                          width: 70,
                          padding:pw.EdgeInsets.only(right: 10) ,

                          child: pw.Text("Payment"),
                          alignment: pw.Alignment.centerRight,
                          decoration: pw.BoxDecoration(
                              border: pw.BoxBorder(
                                  top:true
                              )
                          )
                      )
                    ]
                  )
                ]
              ),
              decoration: pw.BoxDecoration(
                  border: pw.BoxBorder(
                      top: true,
                      bottom: true,
                      right: true
                  )
              )
          ),
          pw.Container(
              width:80,
              alignment: pw.Alignment.centerRight,
              child: pw.Column(
                  children: [
                    pw.Text("Current"),
                    pw.Row(
                        children: [
                          pw.Container(
                            width:70,
                              padding:pw.EdgeInsets.only(right: 5),
                              child: pw.Text("Received"),
                              alignment: pw.Alignment.centerRight,
                              decoration: pw.BoxDecoration(
                                  border: pw.BoxBorder(right: true,top:true)
                              )
                          ),
                          pw.Container(
                            width:70,
                              child: pw.Text("Payment"),
                              padding:pw.EdgeInsets.only(right: 10),
                              alignment: pw.Alignment.centerRight,
                              decoration: pw.BoxDecoration(
                                  border: pw.BoxBorder(
                                      top:true
                                  )
                              )
                          )
                        ]
                    )
                ]
              ),
              decoration: pw.BoxDecoration(
                  border: pw.BoxBorder(
                      top: true,
                      bottom: true,
                      right: true
                  )
              )

          ),
          pw.Container(
              width:80,
              alignment: pw.Alignment.centerRight,
              child: pw.Column(
                  children: [
                    pw.Text("Balance"),
                    pw.Row(
                        children: [
                          pw.Container(
                            width:70,
                              child: pw.Text("Received"),
                              padding:pw.EdgeInsets.only(right: 5),
                              alignment: pw.Alignment.centerRight,
                              decoration: pw.BoxDecoration(
                                  border: pw.BoxBorder(right: true,top:true)
                              )
                          ),
                          pw.Container(
                            width: 70,
                            child: pw.Text("Payment"),
                            padding:pw.EdgeInsets.only(right: 10),
                            alignment: pw.Alignment.centerRight,
                            decoration: pw.BoxDecoration(
                              border: pw.BoxBorder(
                                top:true
                              )
                            )
                          )
                        ]
                    )
                  ]
              ),
              decoration: pw.BoxDecoration(
                  border: pw.BoxBorder(
                      top: true,
                      bottom: true,
                      right: true
                  )
              )
          )
      ]
    );
  }

  SectionHeader(String caption){
    return pw.TableRow(
        children: <pw.Widget>[
          pw.Container(
              width: 100,
              height:15,
              alignment: pw.Alignment.centerLeft,
              child: pw.Text("${caption}"),
              decoration: pw.BoxDecoration(
                  border: pw.BoxBorder(
                      top: true,
                      bottom: true,
                      left: true
                  )
              )
          ),
          pw.Container(
            width:80,
              height: 15,
              child: pw.Text(""),
              decoration: pw.BoxDecoration(
                  border: pw.BoxBorder(
                      top: true,
                      bottom: true,
                  )
              )
          ),
          pw.Container(
              width:80,
              height: 15,
              child: pw.Text(""),
              decoration: pw.BoxDecoration(
                  border: pw.BoxBorder(
                      top: true,
                      bottom: true,
                  )
              )
          ),
          pw.Container(
              width:80,
              height: 15,
              child: pw.Text(""),
              decoration: pw.BoxDecoration(
                  border: pw.BoxBorder(
                      top: true,
                      bottom: true,
                      right: true
                  )
              )
          )
        ]
    );
  }

  SectionItem(TrialBalanceSectionItem item){
    return pw.TableRow(
        children: <pw.Widget>[
          pw.Container(
              width: 100,
              height:14,
              padding: pw.EdgeInsets.only(right: 10),
              alignment: pw.Alignment.centerRight,
              child: pw.Text("${item.caption}",style: pw.TextStyle(
                fontWeight: (item.isBold!=null && item.isBold)? pw.FontWeight.bold :pw.FontWeight.normal
              )),
              decoration: pw.BoxDecoration(
                  border: pw.BoxBorder(
                      top: true,
                      bottom: true,
                      left: true
                  )
              )
          ),
          pw.Container(
              width:80,
              alignment: pw.Alignment.centerRight,
              child: pw.Column(
                  children: [
                    pw.Row(
                        children: [
                          pw.Container(
                              width:70,
                              child: pw.Text("${item.prev.received}",style: pw.TextStyle(
                                  fontWeight: (item.isBold!=null && item.isBold)? pw.FontWeight.bold :pw.FontWeight.normal
                              )),
                              padding:pw.EdgeInsets.only(right: 5),
                              alignment: pw.Alignment.centerRight,
                              decoration: pw.BoxDecoration(
                                  border: pw.BoxBorder(left: true,top:true,right: true)
                              )
                          ),
                          pw.Container(
                              width: 70,
                              padding:pw.EdgeInsets.only(right: 10) ,

                              child: pw.Text("${item.prev.payment}",style: pw.TextStyle(
                                  fontWeight: (item.isBold!=null && item.isBold)? pw.FontWeight.bold :pw.FontWeight.normal
                              )),
                              alignment: pw.Alignment.centerRight,
                              decoration: pw.BoxDecoration(
                                  border: pw.BoxBorder(
                                      top:true
                                  )
                              )
                          )
                        ]
                    )
                  ]
              ),
              decoration: pw.BoxDecoration(
                  border: pw.BoxBorder(
                      top: true,
                      bottom: true,
                      right: true
                  )
              )
          ),
          pw.Container(
              width:80,
              alignment: pw.Alignment.centerRight,
              child: pw.Column(
                  children: [
                    pw.Row(
                        children: [
                          pw.Container(
                              width:70,
                              child: pw.Text("${item.current.received}",style: pw.TextStyle(
                                  fontWeight: (item.isBold!=null && item.isBold)? pw.FontWeight.bold :pw.FontWeight.normal
                              )),
                              padding:pw.EdgeInsets.only(right: 5),
                              alignment: pw.Alignment.centerRight,
                              decoration: pw.BoxDecoration(
                                  border: pw.BoxBorder(left: true,top:true,right: true)
                              )
                          ),
                          pw.Container(
                              width: 70,
                              padding:pw.EdgeInsets.only(right: 10) ,

                              child: pw.Text("${item.current.payment}",style: pw.TextStyle(
                                  fontWeight: (item.isBold!=null && item.isBold)? pw.FontWeight.bold :pw.FontWeight.normal
                              )),
                              alignment: pw.Alignment.centerRight,
                              decoration: pw.BoxDecoration(
                                  border: pw.BoxBorder(
                                      top:true
                                  )
                              )
                          )
                        ]
                    )
                  ]
              ),
              decoration: pw.BoxDecoration(
                  border: pw.BoxBorder(
                      top: true,
                      bottom: true,
                      right: true
                  )
              )
          ),
          pw.Container(
              width:80,
              alignment: pw.Alignment.centerRight,
              child: pw.Column(
                  children: [
                    pw.Row(
                        children: [
                          pw.Container(
                              width:70,
                              child: pw.Text("${item.balance.received}",style: pw.TextStyle(
                                  fontWeight: (item.isBold!=null && item.isBold)? pw.FontWeight.bold :pw.FontWeight.normal
                              )),
                              padding:pw.EdgeInsets.only(right: 5),
                              alignment: pw.Alignment.centerRight,
                              decoration: pw.BoxDecoration(
                                  border: pw.BoxBorder(left: true,top:true,right: true)
                              )
                          ),
                          pw.Container(
                              width: 70,
                              padding:pw.EdgeInsets.only(right: 10) ,

                              child: pw.Text("${item.balance.payment}",style: pw.TextStyle(
                                  fontWeight: (item.isBold!=null && item.isBold)? pw.FontWeight.bold :pw.FontWeight.normal
                              )),
                              alignment: pw.Alignment.centerRight,
                              decoration: pw.BoxDecoration(
                                  border: pw.BoxBorder(
                                      top:true
                                  )
                              )
                          )
                        ]
                    )
                  ]
              ),
              decoration: pw.BoxDecoration(
                  border: pw.BoxBorder(
                      top: true,
                      bottom: true,
                      right: true
                  )
              )
          )
        ]
    );
  }

  GenerateRow() async{
    ChartAccountService chartAccService = ChartAccountService(repo: ChartAccountRepository());
    List<Map<String,dynamic>> parentAccounts = await chartAccService.getParentAccounts();
    List<Map<String,dynamic>> childAccounts = await chartAccService.getChildAccounts();
    List<pw.TableRow> _rows=[];
    _rows.add(TitleBar());

    parentAccounts.forEach((element) {
      AppConfig.log(element,line: "530",className:  "TrialBalanceReport");
      if(element['acc_level']==2) {
        _rows.add(
            SectionHeader("${element['acc_code']} - ${element['acc_name']}"));

        childAccounts.forEach((childElement) {
          if(childElement['second_level']==element['acc_code']){
            _rows.add(SectionItem(new TrialBalanceSectionItem(
                caption: "${childElement['acc_code']}-${childElement['acc_name']}",
                isBold: false,
                prev:Amount(received: "200",payment: "0"),
                current: Amount(received: "300",payment: "50"),
                balance: Amount(received: "240",payment: "40")
            )));
          }
        });
        _rows.add(SectionItem(new TrialBalanceSectionItem(
            caption: "Sub Total",
            isBold: true,
            prev:Amount(received: "200",payment: "0"),
            current: Amount(received: "300",payment: "50"),
            balance: Amount(received: "240",payment: "40")
        )));
      }
    });




//    _rows.add(SectionItem(new TrialBalanceSectionItem(
//        caption: "Sub Total",
//        isBold: true,
//        prev:Amount(received: "200",payment: "0"),
//        current: Amount(received: "300",payment: "50"),
//        balance: Amount(received: "240",payment: "40")
//    )));

    setState(() {
      rows =_rows;
    });
  }



  Future<void> GenerateReport() async{

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
                child: pw.Text("Trial Balance")
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
    buttonPressed.sink.add(null);
    Navigator.of(context).push(
      MaterialPageRoute(
      builder: (context)=> PdfViewer(path: filename,)
      )
    );
  }

  @override
  void dispose() {
    buttonPressed.close();
    super.dispose();
  }
}