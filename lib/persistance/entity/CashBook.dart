import 'package:gaccounts/persistance/entity/Cash.dart';
import 'package:gaccounts/persistance/entity/Bank.dart';

class CashBook{

  String voucherNo;
  String accountName;
  String accountCode;
  String description;
  Cash cash;
  Bank bank;

  CashBook({this.voucherNo,
  this.accountName,
  this.accountCode,
  this.description,
  this.cash,
  this.bank});
}