import 'Amount.dart';

class TrialBalanceSectionItem{
  String caption;
  bool isBold;
  Amount prev;
  Amount current;
  Amount balance;

  TrialBalanceSectionItem({
    this.caption,
    this.isBold,
    this.prev,
    this.current,
    this.balance
  });
}