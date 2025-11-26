import 'package:heaven_book_app/model/user.dart';

class AppSession {
  static final AppSession _instance = AppSession._internal();

  factory AppSession() {
    return _instance;
  }

  AppSession._internal();

  User? currentUser;

  // Base URL cho hình ảnh sản phẩm
  static const String baseUrlImg = 'http://10.0.2.2:8080/storage/product/';
  //static const String baseUrlImg = 'http://thebookheaven.io.vn/storage/product/';

  void clear() {
    currentUser = null;
  }
}
