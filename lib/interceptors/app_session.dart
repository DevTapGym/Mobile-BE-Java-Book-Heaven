import 'package:heaven_book_app/model/user.dart';

class AppSession {
  static final AppSession _instance = AppSession._internal();

  factory AppSession() {
    return _instance;
  }

  AppSession._internal();
  User? currentUser;

  void clear() {
    currentUser = null;
  }
}
