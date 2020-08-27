class Profile{

  int profileId;
  String name;
  String email;
  String address;
  String phoneNo;
  int businessScaleId;
  int businessTypeId;

  Profile({
    this.profileId,
    this.name,
    this.email,
    this.address,
    this.phoneNo,
    this.businessScaleId,
    this.businessTypeId
  });

  Map<String,dynamic> toMap(){
    return {
      'profile_id':profileId,
      'name':name,
      'email': email,
      'address': address,
      'phone_no': phoneNo,
      'business_scale_id': businessScaleId,
      'business_type_id': businessTypeId
    };
  }
}