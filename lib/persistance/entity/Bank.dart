import 'package:gaccounts/persistance/entity/Amount.dart';

class Bank extends Amount{

  String received;
  String payment;

  Bank({this.received,this.payment}):super(received:received,payment:payment);
}