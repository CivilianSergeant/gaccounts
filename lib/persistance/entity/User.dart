class User{

   int id;
   int profileId;
   int businessTypeId;
   String userId;
   String username;
   bool isVerified;
   String verifiedId;
   String imei;
   int syncId;
   bool downloadVoucher;

   User({
    this.id,
    this.profileId,
    this.businessTypeId,
    this.userId,
    this.username,
    this.isVerified,
    this.verifiedId,
    this.imei,
    this.syncId,
    this.downloadVoucher
  });

   factory User.fromJSON(Map<String,dynamic> map){
     return User(
        id: map['id'],
        profileId: map['profile_id'],
        businessTypeId: map['business_type_id'],
        userId: map['user_id'],
        username: map['username'],
        isVerified: (map['is_verified'] ==1)? true: false,
        verifiedId: map['verified_id'],
        imei: map['imei'],
        syncId: map['sync_id'],
        downloadVoucher: (map['download_voucher']==1)? true : false
     );
   }

  Map<String,dynamic> toMap(){
    return {
      "id": id,
      "profile_id": profileId,
      "business_type_id": businessTypeId,
      "user_id": userId,
      "username": username,
      "is_verified": (isVerified)? 1 : 0,
      "verified_id": verifiedId,
      "imei": imei,
      "sync_id": syncId,
      "download_voucher": (downloadVoucher)? 1 : 0
    };
  }
}