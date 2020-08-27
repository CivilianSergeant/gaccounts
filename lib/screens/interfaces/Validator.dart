
abstract class FormValidator{
  String error;
  setData<T>(T data);
  validate();
  submit(Function stateChange);
  getError();
}