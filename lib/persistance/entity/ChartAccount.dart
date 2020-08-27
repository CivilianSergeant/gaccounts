class ChartAccount{
  int id;
  int accId;
  String accName;
  String accCode;
  int accLevel;
  String firstLevel;
  String secondLevel;
  String thirdLevel;
  String fourthLevel;
  String fifthLevel;
  int categoryId;
  String nature;
  int groupId;
  String voucherType;
  bool isTransaction;
  bool isSelected;
  bool isSync;


  ChartAccount({
    this.id,
    this.accId,
    this.accCode,
    this.accName,
    this.accLevel,
    this.firstLevel,
    this.secondLevel,
    this.thirdLevel,
    this.fourthLevel,
    this.fifthLevel,
    this.categoryId,
    this.nature,
    this.groupId,
    this.voucherType,
    this.isTransaction,
    this.isSelected,
    this.isSync
  });

  Map<String,dynamic> toMap(){
    return {
      'id':id,
      'acc_id':accId,
      'acc_name':accName,
      'acc_code':accCode,
      'acc_level':accLevel,
      'first_level':firstLevel,
      'second_level':secondLevel,
      'third_level':thirdLevel,
      'fourth_level':fourthLevel,
      'fifth_level':fifthLevel,
      'category_id':categoryId,
      'nature':nature,
      'group_id':groupId,
      'voucher_type': voucherType,
      'is_transaction': (isTransaction)? 1 :0,
      'is_selected': (isSelected!=null && isSelected)? 1:0,
      'is_sync': (isSync !=null && isSync)? 1:0
    };
  }
}