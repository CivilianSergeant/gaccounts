import 'package:gaccounts/persistance/repository/BusinessTypeRepository.dart';

class BusinessTypeService{
  BusinessTypeRepository repository;

  BusinessTypeService({this.repository});

  Future<List<Map<String,dynamic>>> getParentTypes() async{
    return await repository.findParentType();
  }

  Future<List<Map<String,dynamic>>> getChildTypes(int parentId) async{
    return await repository.findChildType(parentId);
  }

  Future<int> addBusinessTypesFromServer(List<dynamic> businessTypes) async{
    await repository.truncate();
    return await repository.addBusinessTypes(businessTypes);
  }
}