import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:heaven_book_app/bloc/user/user_bloc.dart';
import 'package:heaven_book_app/bloc/user/user_event.dart';
import 'package:heaven_book_app/bloc/user/user_state.dart';
import 'package:heaven_book_app/services/auth_service.dart';
import 'package:heaven_book_app/themes/app_colors.dart';
import 'package:heaven_book_app/screens/Auth/init_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();

  Future<void> _showLogoutDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Row(
            children: [
              Icon(Icons.logout, color: Colors.red, size: 28),
              SizedBox(width: 12),
              Text(
                //'Logout',
                'Đăng xuất',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ],
          ),
          content: Text(
            //'Are you sure you want to logout?',
            'Bạn có chắc chắn muốn đăng xuất không?',
            style: TextStyle(fontSize: 16),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Đóng dialog
              },
              child: Text(
                //'Cancel',
                'Hủy',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Đóng dialog
                _performLogout(); // Thực hiện đăng xuất
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                //'Logout',
                'Đăng xuất',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _performLogout() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text(
                  'Đang đăng xuất...',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
    );

    try {
      final result = await _authService.logout();
      await Future.delayed(Duration(milliseconds: 500));

      if (mounted) {
        Navigator.of(context).pop();
      }

      if (result['success'] == true) {
        debugPrint(
          '🏠 [ProfileScreen] Đăng xuất thành công → Chuyển về InitScreen',
        );
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const InitScreen()),
            (route) => false,
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Đăng xuất không thành công: ${result['message']}'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
              action: SnackBarAction(
                label: 'Thử lại',
                textColor: Colors.white,
                onPressed: _performLogout,
              ),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('🚨 [ProfileScreen] Lỗi khi đăng xuất: $e');

      // Đóng loading dialog nếu có lỗi
      if (mounted) {
        Navigator.of(context).pop();

        // Hiển thị error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Có lỗi xảy ra khi đăng xuất: $e'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
            action: SnackBarAction(
              label: 'Thử lại',
              textColor: Colors.white,
              onPressed: _performLogout,
            ),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    context.read<UserBloc>().add(LoadUserInfo());
  }

  @override
  Widget build(BuildContext context) {
    final ValueNotifier<bool> notificationSwitch = ValueNotifier<bool>(true);
    final ValueNotifier<String> selectedLanguage = ValueNotifier<String>('VN');

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.primary, AppColors.background],
            stops: [0.26, 0.26],
          ),
        ),
        padding: EdgeInsets.only(left: 24.0, right: 24.0, bottom: 8.0),
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                BlocBuilder<UserBloc, UserState>(
                  builder: (context, state) {
                    if (state is UserLoaded) {
                      final user = state.userData;
                      return Stack(
                        alignment: Alignment.topCenter,
                        children: [
                          Container(
                            margin: EdgeInsets.only(top: 100.0, bottom: 12.0),
                            child: Card(
                              color: Colors.white,
                              elevation: 4.0,
                              shadowColor: Colors.black38,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              child: Padding(
                                padding: EdgeInsets.only(
                                  top: 70.0,
                                  left: 16.0,
                                  right: 16.0,
                                  bottom: 16.0,
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(height: 8.0),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          user.name.isNotEmpty
                                              ? user.name
                                              : //'No Name',
                                              'Chưa cập nhật tên',
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(width: 8.0),
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 8.0,
                                            vertical: 4.0,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.green,
                                            borderRadius: BorderRadius.circular(
                                              12.0,
                                            ),
                                          ),
                                          child: Text(
                                            'Premium',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 8.0),
                                    Text(
                                      user.email,
                                      style: TextStyle(
                                        color: Colors.black54,
                                        fontSize: 16,
                                      ),
                                    ),
                                    SizedBox(height: 6.0),
                                    Divider(
                                      thickness: 1.5,
                                      color: Colors.black54,
                                      indent: 20,
                                      endIndent: 20,
                                    ),
                                    SizedBox(height: 16.0),
                                    ListTile(
                                      leading: Icon(
                                        Icons.person,
                                        color: Colors.black54,
                                        size: 28,
                                      ),
                                      title: Text(
                                        //'Edit Profile',
                                        'Cập nhật thông tin',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black54,
                                          fontSize: 17,
                                        ),
                                      ),
                                      onTap: () {
                                        Navigator.pushNamed(
                                          context,
                                          '/edit-profile',
                                        );
                                      },
                                    ),
                                    ListTile(
                                      leading: Icon(
                                        Icons.location_on,
                                        color: Colors.black54,
                                        size: 28,
                                      ),
                                      title: Text(
                                        //'Shipping Address',
                                        'Địa chỉ giao hàng',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black54,
                                          fontSize: 17,
                                        ),
                                      ),
                                      onTap: () {
                                        Navigator.pushNamed(
                                          context,
                                          '/shipping-address',
                                        );
                                      },
                                    ),
                                    ListTile(
                                      leading: Icon(
                                        Icons.card_giftcard,
                                        color: Colors.black54,
                                        size: 28,
                                      ),
                                      title: Text(
                                        //'Rewards',
                                        'Phần thưởng',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black54,
                                          fontSize: 17,
                                        ),
                                      ),
                                      onTap: () {
                                        Navigator.pushNamed(context, '/reward');
                                      },
                                    ),
                                    ListTile(
                                      leading: Icon(
                                        Icons.lock,
                                        color: Colors.black54,
                                        size: 28,
                                      ),
                                      title: Text(
                                        //'Change Password',
                                        'Đổi mật khẩu',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black54,
                                          fontSize: 17,
                                        ),
                                      ),
                                      onTap: () {
                                        Navigator.pushNamed(
                                          context,
                                          '/change-password',
                                        );
                                      },
                                    ),
                                    SizedBox(height: 24.0),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Transform.translate(
                            offset: Offset(0, 0),
                            child: Container(
                              width: 160,
                              height: 160,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                border: Border.all(
                                  color: AppColors.primary,
                                  width: 8.0,
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: CircleAvatar(
                                radius: 80,
                                backgroundImage:
                                    user.avatarUrl != null &&
                                            user.avatarUrl!.contains(
                                              'storage/Avatar',
                                            )
                                        ? Image.network(
                                          'http://10.0.2.2:8000${user.avatarUrl}',
                                          errorBuilder: (
                                            context,
                                            error,
                                            stackTrace,
                                          ) {
                                            return Icon(
                                              Icons.account_circle,
                                              size: 80,
                                              color: Colors.white,
                                            );
                                          },
                                        ).image
                                        : NetworkImage('${user.avatarUrl}'),
                              ),
                            ),
                          ),
                        ],
                      );
                    } else if (state is UserError) {
                      return Center(
                        child: Text(
                          'Error: ${state.message}',
                          style: TextStyle(color: Colors.red),
                        ),
                      );
                    } else if (state is UserLoading) {
                      return Center(child: CircularProgressIndicator());
                    } else {
                      return SizedBox.shrink();
                    }
                  },
                ),
                SizedBox(height: 24),
                Card(
                  color: Colors.white,
                  elevation: 6.0,
                  shadowColor: Colors.black38,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ValueListenableBuilder<bool>(
                          valueListenable: notificationSwitch,
                          builder: (context, value, child) {
                            return ListTile(
                              leading: Icon(
                                Icons.notifications,
                                color: Colors.black54,
                                size: 28,
                              ),
                              title: Text(
                                //'Notifications',
                                'Thông báo',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black54,
                                  fontSize: 17,
                                ),
                              ),
                              trailing: Switch(
                                value: value,
                                onChanged: (bool newValue) {
                                  notificationSwitch.value = newValue;
                                },
                                inactiveThumbColor: Colors.black45,
                                activeColor: AppColors.primaryDark,
                              ),
                              onTap: () {
                                notificationSwitch.value =
                                    !notificationSwitch.value;
                              },
                            );
                          },
                        ),
                        ValueListenableBuilder<String>(
                          valueListenable: selectedLanguage,
                          builder: (context, value, child) {
                            return ListTile(
                              leading: Icon(
                                Icons.language,
                                color: Colors.black54,
                                size: 28,
                              ),
                              title: Text(
                                //'Language',
                                'Ngôn ngữ',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black54,
                                  fontSize: 17,
                                ),
                              ),
                              trailing: Container(
                                height: 40,
                                padding: EdgeInsets.symmetric(horizontal: 14.0),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.black54,
                                    width: 1.5,
                                  ),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: DropdownButton<String>(
                                  value: value,
                                  items:
                                      <String>['VN', 'EN'].map((
                                        String language,
                                      ) {
                                        return DropdownMenuItem<String>(
                                          value: language,
                                          child: Text(
                                            language,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black54,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                  onChanged: (String? newValue) {
                                    if (newValue != null) {
                                      selectedLanguage.value = newValue;
                                    }
                                  },
                                  underline:
                                      SizedBox(), // Xóa gạch chân mặc định
                                  icon: Icon(
                                    Icons.arrow_drop_down,
                                    color: Colors.black54,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        Divider(),
                        ListTile(
                          leading: Icon(
                            Icons.policy,
                            color: Colors.black54,
                            size: 28,
                          ),
                          title: Text(
                            //'Terms of Service',
                            'Điều khoản dịch vụ',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black54,
                              fontSize: 17,
                            ),
                          ),
                          onTap: () {},
                        ),
                        ListTile(
                          leading: Icon(
                            Icons.repeat_on_rounded,
                            color: Colors.black54,
                            size: 28,
                          ),
                          title: Text(
                            //'Return Policy',
                            'Chính sách đổi trả',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black54,
                              fontSize: 17,
                            ),
                          ),
                          onTap: () {},
                        ),
                        ListTile(
                          leading: Icon(
                            Icons.help,
                            color: Colors.black54,
                            size: 28,
                          ),
                          title: Text(
                            //'Help & Feedback',
                            'Trợ giúp & Phản hồi',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black54,
                              fontSize: 17,
                            ),
                          ),
                          onTap: () {},
                        ),
                        Container(
                          width: double.infinity,
                          margin: EdgeInsets.only(top: 8.0),
                          child: ElevatedButton(
                            onPressed: _showLogoutDialog,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: 32.0,
                                vertical: 12.0,
                              ),
                              textStyle: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            child: Text(
                              //'Logout',
                              'Đăng xuất',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
