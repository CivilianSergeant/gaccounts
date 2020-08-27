class CustomException implements Exception {
  int _status;
  String _message;

  set message(m) { _message = m; }
  get message { return _message; }

  set status(s) { _status = s; }
  get status {return _status; }
}