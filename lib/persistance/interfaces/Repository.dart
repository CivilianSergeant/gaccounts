abstract class Repository{
  findById(int id);
  find({String where, List<dynamic> whereArgs, bool firstOnly});
  Future<int> save(dynamic obj);
}
