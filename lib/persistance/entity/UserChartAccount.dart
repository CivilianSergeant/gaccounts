class UserChartAccount{
  int id;
  int chartAccountId;
  int userId;

  UserChartAccount({this.id,this.chartAccountId,this.userId});

  Map<String,dynamic> toMap(){
    return {
      'id':id,
      'chart_account_id':chartAccountId,
      'user_id':userId
    };
  }
}