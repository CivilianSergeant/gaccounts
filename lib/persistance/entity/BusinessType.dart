class BusinessType{
  int id;
  String title;
  String code;
  int parentId;

  BusinessType({
    this.id,this.title,this.code,this.parentId
  });

  Map<String,dynamic> toMap(){
    return {
      'id': id,
      'title': title,
      'code': code,
      'parent_id':parentId
    };
  }

}