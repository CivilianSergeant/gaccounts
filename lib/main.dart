import 'package:flutter/material.dart';
import 'package:gaccounts/helpers/portrait_mode_mixin.dart';
import 'package:gaccounts/persistance/repository/UserRepository.dart';
import 'package:gaccounts/persistance/services/UserService.dart';
import 'package:gaccounts/screens/DashboardScreen.dart';
import 'package:gaccounts/screens/LoginScreen.dart';
import 'package:gaccounts/screens/RegistrationScreen.dart';
import 'package:gaccounts/screens/SplashScreen.dart';
import 'package:gaccounts/screens/SyncDownloadScreen.dart';
import 'package:gaccounts/screens/SyncScreen.dart';
import 'package:gaccounts/screens/VoucherEntryScreen.dart';
import 'package:gaccounts/screens/VoucherScreen.dart';
import 'package:gaccounts/screens/reports/PdfViewer.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget with PortraitModeMixin {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primaryColor:  Color(0xff0e4b61),
        primaryColorDark: Color(0xff0e4b61),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: SplashScreen(),
      routes:{
        '/login': (context)=> LoginScreen(),
        '/register': (context) => RegistrationScreen(),
        '/dashboard': (context) => DashboardScreen(),
        '/vouchers':(context)=> VoucherScreen(),
        '/voucher-entry':(context)=>VoucherEntryScreen(),
        '/sync':(context)=>SyncScreen(),
        '/sync-download':(context)=>SyncDownloadScreen(),
        '/pdf-viewer':(context)=>PdfViewer()
      },
      debugShowCheckedModeBanner: false,
    );
  }


}
