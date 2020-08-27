import 'dart:async';

class PhoneFieldService{
  var _dialingCode = StreamController<String>.broadcast();
  String _code;

  DialingCode(String code) {
     _code = code;
    _dialingCode.sink.add(_code);
   }


  Stream<String> get getDialingCode => _dialingCode.stream;

  dispose(){
    _dialingCode?.close();
  }
}

PhoneFieldService phoneFieldService = PhoneFieldService();