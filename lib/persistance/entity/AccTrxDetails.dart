class AccTrxDetail{
  int trxDetailId;
  int trxMasterId;
  int accId;
  double credit; //received
  double debit; // payment
  String narration;
  bool isActive;
  String inActiveDate;
  int userId;
  String createDate;

  AccTrxDetail({
    this.trxDetailId,
    this.trxMasterId,
    this.accId,
    this.credit,
    this.debit,
    this.narration,
    this.isActive,
    this.inActiveDate,
    this.userId,
    this.createDate
  });

  Map<String,dynamic> toMap(){
    return{
      'trx_detail_id': trxDetailId,
      'trx_master_id': trxMasterId,
      'acc_id': accId,
      'credit': credit,
      'debit': debit,
      'narration': narration,
      'is_active': isActive,
      'in_active_date': inActiveDate,
      'user_id': userId,
      'create_date': createDate
    };
  }

}