import 'dart:convert';

import 'package:connectivity/connectivity.dart';
import 'package:gaccounts/config/AppConfig.dart';
import 'package:http/http.dart' as http;

abstract class NetworkService{

  String url;

  setUrl(String url){
    this.url = url;
  }

  Future<Map<String,dynamic>> fetch() async {
    AppConfig.log(url);
    try{
      final response = await http.get(url);
      final parsedJson = jsonDecode(response.body);
      return parsedJson;
    }on Exception catch(ex){
      return null;
    }
  }

  Future<dynamic> post(Map<String,dynamic> data, {Map<String,String> header}) async{

    var _data = (header['Content-Type'].contains("json"))? jsonEncode(data) : data;

    AppConfig.log(_data);
    AppConfig.log(url);
    final response = await http.post(url,body: _data,headers: header);

    final parsedJson = (response.body != null )? jsonDecode(response.body) : null;

//    AppConfig.debug("RESPONSE: "+parsedJson.toString());

    return parsedJson;
  }

  static Future<bool> check() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if(connectivityResult == ConnectivityResult.mobile){
      return true;
    }else if(connectivityResult == ConnectivityResult.wifi){
      return true;
    }else{
      return false;
    }
  }

  Future<bool> checkNetwork() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if(connectivityResult == ConnectivityResult.mobile){
      return true;
    }else if(connectivityResult == ConnectivityResult.wifi){
      return true;
    }else{
      return false;
    }
  }

}