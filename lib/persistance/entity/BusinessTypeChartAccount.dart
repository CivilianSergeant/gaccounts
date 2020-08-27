class BusinessTypeChartAccount{
  int id;
  int chartAccountId;
  int businessTypeId;

  BusinessTypeChartAccount({this.id,this.chartAccountId,this.businessTypeId});

  Map<String,dynamic> toMap(){
    return {
      'id':id,
      'chart_account_id':chartAccountId,
      'business_type_id':businessTypeId
    };
  }
}