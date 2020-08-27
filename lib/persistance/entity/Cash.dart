import 'package:gaccounts/persistance/entity/Amount.dart';

class Cash extends Amount{
  String received;
  String payment;

  Cash({this.received,this.payment}):super(received:received,payment:payment);
}