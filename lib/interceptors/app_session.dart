import 'package:heaven_book_app/model/user.dart';

class AppSession {
  static final AppSession _instance = AppSession._internal();

  factory AppSession() {
    return _instance;
  }

  AppSession._internal();

  User? currentUser;
  //10.0.2.2
  // Base URL cho hình ảnh sản phẩm
  //static const String baseUrlImg = 'http://192.168.1.123/storage/product/';
  static const String baseUrlImg =
      'https://api.thebookheaven.io.vn/storage/product/';

  //static const String baseUrlImgAvatar ='http://192.168.1.123:8080/storage/avatar/';
  static const String baseUrlImgAvatar =
      'https://api.thebookheaven.io.vn/storage/avatar/';

  void clear() {
    currentUser = null;
  }
}
