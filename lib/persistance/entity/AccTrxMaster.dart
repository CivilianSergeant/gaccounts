class AccTrxMaster{

  int trxMasterId;
  int officeId;
  String trxDate;
  String voucherNo;
  int autoVoucherNo;
  String voucherType;
  bool isPosted;
  int userId;

  AccTrxMaster({
    this.trxMasterId,
    this.officeId,
    this.trxDate,
    this.voucherNo,
    this.autoVoucherNo,
    this.voucherType,
    this.isPosted,
    this.userId
  });

  Map<String,dynamic> toMap(){

    return {
      'trx_master_id': trxMasterId,
      'office_id': officeId,
      'trx_date': trxDate,
      'voucher_no': voucherNo,
      'auto_voucher_no': autoVoucherNo,
      'voucher_type': voucherType,
      'is_posted': (isPosted)? 1 : 0,
      'user_id': userId
    };

  }

}