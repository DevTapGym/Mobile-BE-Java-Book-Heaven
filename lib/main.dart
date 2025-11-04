import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:heaven_book_app/bloc/address/address_bloc.dart';
import 'package:heaven_book_app/bloc/address/address_event.dart';
import 'package:heaven_book_app/bloc/auth/auth_bloc.dart';
import 'package:heaven_book_app/bloc/auth/auth_state.dart';
import 'package:heaven_book_app/bloc/book/book_bloc.dart';
import 'package:heaven_book_app/bloc/book/book_event.dart';
import 'package:heaven_book_app/bloc/cart/cart_bloc.dart';
import 'package:heaven_book_app/bloc/cart/cart_event.dart';
import 'package:heaven_book_app/bloc/cart/cart_state.dart';
import 'package:heaven_book_app/bloc/order/order_bloc.dart';
import 'package:heaven_book_app/bloc/payment/payment_bloc.dart';
import 'package:heaven_book_app/bloc/promotion/promotion_bloc.dart';
import 'package:heaven_book_app/bloc/user/user_bloc.dart';
import 'package:heaven_book_app/screens/Orders/buy_now_screen.dart';
import 'package:heaven_book_app/services/book_service.dart';
import 'package:heaven_book_app/services/cart_service.dart';
import 'package:heaven_book_app/screens/Auth/active_screen.dart';
import 'package:heaven_book_app/screens/Auth/forgot_screen.dart';
import 'package:heaven_book_app/screens/Auth/init_screen.dart';
import 'package:heaven_book_app/screens/Auth/login_screen.dart';
import 'package:heaven_book_app/screens/Auth/register_screen.dart';
import 'package:heaven_book_app/screens/Auth/reset_screen.dart';
import 'package:heaven_book_app/screens/Cart/check_out_screen.dart';
import 'package:heaven_book_app/screens/Home/detail_review_screen.dart';
import 'package:heaven_book_app/screens/Home/detail_screen.dart';
import 'package:heaven_book_app/screens/Home/home_screen.dart';
import 'package:heaven_book_app/screens/Home/result_screen.dart';
import 'package:heaven_book_app/screens/Orders/detail_order_screen.dart';
import 'package:heaven_book_app/screens/Orders/orders_screen.dart';
import 'package:heaven_book_app/screens/Cart/cart_screen.dart';
import 'package:heaven_book_app/screens/Profile/add_address_screen.dart';
import 'package:heaven_book_app/screens/Profile/change_password_screen.dart';
import 'package:heaven_book_app/screens/Profile/detail_voucher_screen.dart';
import 'package:heaven_book_app/screens/Profile/edit_profile_screen.dart';
import 'package:heaven_book_app/screens/Profile/profile_screen.dart';
import 'package:heaven_book_app/screens/Profile/reward_screen.dart';
import 'package:heaven_book_app/screens/Profile/shipping_address_screen.dart';
import 'package:heaven_book_app/services/address_service.dart';
import 'package:heaven_book_app/services/api_client.dart';
import 'package:heaven_book_app/services/auth_service.dart';
import 'package:heaven_book_app/services/order_service.dart';
import 'package:heaven_book_app/services/payment_service.dart';
import 'package:heaven_book_app/services/promotion_service.dart';
import 'package:heaven_book_app/themes/app_colors.dart';
import 'screens/Auth/onboarding_wrapper.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final storage = FlutterSecureStorage();
  final authService = AuthService();
  final apiClient = ApiClient(storage, authService);

  final cartRepository = CartService(apiClient);
  final bookRepository = BookService(apiClient);
  final addressService = AddressService(apiClient);
  final orderService = OrderService(apiClient);
  final paymentService = PaymentService(apiClient);
  final promotionService = PromotionService(apiClient);

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<BookBloc>(
          create: (_) => BookBloc(bookRepository)..add(LoadBooks()),
        ),
        BlocProvider<AuthBloc>(create: (_) => AuthBloc(authService)),
        BlocProvider<UserBloc>(create: (_) => UserBloc(authService)),
        BlocProvider<CartBloc>(
          create: (_) => CartBloc(cartRepository, bookRepository),
        ),
        BlocProvider<AddressBloc>(
          create: (_) => AddressBloc(addressService)..add(LoadAddresses()),
        ),
        BlocProvider<OrderBloc>(create: (_) => OrderBloc(orderService)),
        BlocProvider<PaymentBloc>(create: (_) => PaymentBloc(paymentService)),
        BlocProvider<PromotionBloc>(
          create: (_) => PromotionBloc(promotionService),
        ),
      ],
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthLoggedOut) {
            Navigator.of(
              context,
            ).pushNamedAndRemoveUntil('/init', (route) => false);
          }
        },
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Book Heaven App',
      home: const OnboardingWrapper(),
      debugShowCheckedModeBanner: false,
      routes: {
        '/main': (context) => const MainScreen(),
        '/onboarding': (context) => const OnboardingWrapper(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/forgot': (context) => const ForgotScreen(),
        '/active': (context) => const ActiveScreen(),
        '/init': (context) => const InitScreen(),

        //'/reset': (context) => const ResetScreen(),
        '/home': (context) => const HomeScreen(),
        '/result': (context) => const ResultScreen(),
        '/detail': (context) => const DetailScreen(),
        '/detail-review': (context) => DetailReviewScreen(),

        '/order': (context) => const OrdersScreen(),
        '/detail-order': (context) => DetailOrderScreen(),

        '/cart': (context) => const CartScreen(),
        '/check-out': (context) => const CheckOutScreen(),
        '/buy-now': (context) => const BuyNowScreen(),

        '/profile': (context) => const ProfileScreen(),
        '/edit-profile': (context) => const EditProfileScreen(),
        '/shipping-address': (context) => const ShippingAddressScreen(),
        '/add-address': (context) => const AddAddressScreen(),
        '/change-password': (context) => const ChangePasswordScreen(),
        '/reward': (context) => RewardScreen(),
        '/detail-voucher': (context) => const DetailVoucherScreen(),
      },
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/reset':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (context) => ResetScreen(email: args['email']),
            );
          default:
            return MaterialPageRoute(builder: (_) => LoginScreen());
        }
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const OrdersScreen(),
    const CartScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    context.read<CartBloc>().add(LoadCart());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartBloc, CartState>(
      builder: (context, state) {
        int badgeCount = 0;

        if (state is CartLoaded) {
          badgeCount = state.cart.totalItems;
        }
        return Scaffold(
          body: _screens[_selectedIndex],
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  spreadRadius: 2,
                  offset: const Offset(0, -2),
                ),
              ],
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              child: BottomNavigationBar(
                type: BottomNavigationBarType.fixed,
                currentIndex: _selectedIndex,
                onTap: _onItemTapped,
                selectedItemColor: AppColors.primaryDark,
                unselectedItemColor: Colors.grey,
                backgroundColor: Colors.transparent,
                elevation: 0,
                selectedFontSize: 14,
                unselectedFontSize: 0,
                selectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.3,
                  fontSize: 14,
                ),
                showUnselectedLabels: false,
                items: [
                  _buildNavItem(
                    Icons.home_outlined,
                    Icons.home,
                    //'Home',
                    'Trang Chủ',
                    _selectedIndex == 0,
                  ),
                  _buildNavItem(
                    Icons.receipt_long_outlined,
                    Icons.receipt_long,
                    //'Orders',
                    'Đơn Hàng',
                    _selectedIndex == 1,
                  ),
                  _buildNavItem(
                    Icons.shopping_cart_outlined,
                    Icons.shopping_cart,
                    //'Cart',
                    'Giỏ Hàng',
                    _selectedIndex == 2,
                    badgeCount: badgeCount,
                  ),
                  _buildNavItem(
                    Icons.person_outline,
                    Icons.person,
                    'Profile',
                    _selectedIndex == 3,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  BottomNavigationBarItem _buildNavItem(
    IconData icon,
    IconData activeIcon,
    String label,
    bool isSelected, {
    int badgeCount = 0,
  }) {
    return BottomNavigationBarItem(
      icon: Stack(
        children: [
          Container(
            margin: const EdgeInsets.only(
              bottom: 4,
            ), // Tăng khoảng cách giữa icon và text
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? AppColors.primary : Colors.transparent,
            ),
            child: Icon(
              isSelected ? activeIcon : icon,
              size: 28,
              color:
                  isSelected
                      ? AppColors.text
                      : Colors.grey.withValues(alpha: 0.6),
            ),
          ),
          // Badge for cart
          if (badgeCount > 0 && label == 'Cart')
            Positioned(
              right: 6,
              top: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$badgeCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
      activeIcon: Stack(
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 4),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(activeIcon, size: 28, color: Colors.white),
          ),
          // Badge for active cart
          if (badgeCount > 0 && label == 'Cart')
            Positioned(
              right: 6,
              top: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$badgeCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
      label: label,
    );
  }
}
