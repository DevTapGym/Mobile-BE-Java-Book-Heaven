import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:heaven_book_app/bloc/cart/cart_bloc.dart';
import 'package:heaven_book_app/bloc/cart/cart_state.dart';
import 'package:heaven_book_app/bloc/order/order_bloc.dart';
import 'package:heaven_book_app/bloc/order/order_event.dart';
import 'package:heaven_book_app/bloc/order/order_state.dart';
import 'package:heaven_book_app/bloc/promotion/promotion_bloc.dart';
import 'package:heaven_book_app/bloc/promotion/promotion_event.dart';
import 'package:heaven_book_app/bloc/promotion/promotion_state.dart';
import 'package:heaven_book_app/bloc/user/user_bloc.dart';
import 'package:heaven_book_app/bloc/user/user_state.dart';
import 'package:heaven_book_app/model/promotion.dart';
import 'package:heaven_book_app/themes/app_colors.dart';
import 'package:heaven_book_app/themes/format_price.dart';
import 'package:heaven_book_app/widgets/appbar_custom_widget.dart';
import 'package:heaven_book_app/widgets/custom_circle_checkbox.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

// Hardcoded Payment Method Model
class PaymentMethod {
  final int id;
  final String name;
  final IconData icon;
  final bool isActive;

  PaymentMethod({
    required this.id,
    required this.name,
    required this.icon,
    this.isActive = true,
  });
}

class CheckOutScreen extends StatefulWidget {
  const CheckOutScreen({super.key});

  @override
  State<CheckOutScreen> createState() => _CheckOutScreenState();
}

class _CheckOutScreenState extends State<CheckOutScreen> {
  bool isChecked = false;
  int? selectedPaymentId;
  int? selectedPromotionId;
  bool showAllPromotions = false;
  final TextEditingController _noteController = TextEditingController();

  // Address form fields
  final TextEditingController _recipientNameController =
      TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressDisplayController =
      TextEditingController();
  final TextEditingController _subAddressController = TextEditingController();

  List<dynamic> _provinces = [];
  List<dynamic> _districts = [];
  // ignore: unused_field
  List<dynamic> _wards = [];
  String? _selectedProvince;
  String? _selectedDistrict;
  String? _selectedWard;

  // Hardcoded payment methods
  final List<PaymentMethod> _paymentMethods = [
    PaymentMethod(
      id: 1,
      name: 'Thanh toán khi nhận hàng (COD)',
      icon: Icons.money,
      isActive: true,
    ),
    PaymentMethod(
      id: 2,
      name: 'Chuyển khoản ngân hàng',
      icon: Icons.account_balance,
      isActive: false,
    ),
    PaymentMethod(
      id: 3,
      name: 'Ví điện tử (MoMo, ZaloPay)',
      icon: Icons.wallet,
      isActive: false,
    ),
    PaymentMethod(
      id: 4,
      name: 'Thẻ tín dụng/Ghi nợ',
      icon: Icons.credit_card,
      isActive: false,
    ),
  ];

  @override
  void initState() {
    super.initState();
    context.read<PromotionBloc>().add(LoadPromotions());
    _loadAddressData();
  }

  @override
  void dispose() {
    _recipientNameController.dispose();
    _phoneController.dispose();
    _addressDisplayController.dispose();
    _subAddressController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _loadAddressData() async {
    final String response = await rootBundle.loadString(
      'assets/data/vietnamAddress.json',
    );
    final data = await json.decode(response);
    setState(() {
      _provinces = data;
    });
  }

  bool _isAddressValid() {
    return _recipientNameController.text.trim().isNotEmpty &&
        _phoneController.text.trim().isNotEmpty &&
        RegExp(r'^0[0-9]{9,10}$').hasMatch(_phoneController.text.trim()) &&
        _selectedProvince != null &&
        _selectedDistrict != null &&
        _selectedWard != null;
  }

  String _getFullAddress() {
    if (_subAddressController.text.trim().isEmpty) {
      return '$_selectedWard, $_selectedDistrict, $_selectedProvince';
    } else {
      return '${_subAddressController.text.trim()} - $_selectedWard, $_selectedDistrict, $_selectedProvince';
    }
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.w700,
              color: isBold ? AppColors.primaryDark : AppColors.black70,
              fontSize: isBold ? 17 : 16,
              shadows: [
                if (isBold)
                  Shadow(
                    color: Colors.black12,
                    offset: Offset(1, 2),
                    blurRadius: 8,
                  ),
              ],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              color: isBold ? AppColors.primaryDark : AppColors.black70,
              fontSize: isBold ? 16 : 15,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressSection() {
    return Container(
      margin: EdgeInsets.only(top: 10.0, left: 18.0, right: 18.0),
      padding: EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.0),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            spreadRadius: 2,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.location_on,
                  color: AppColors.primaryDark,
                  size: 28,
                ),
              ),
              SizedBox(width: 12.0),
              Text(
                'Thông tin giao hàng',
                style: TextStyle(
                  fontSize: 19.0,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryDark,
                ),
              ),
            ],
          ),
          SizedBox(height: 20.0),

          // Recipient Name
          TextField(
            controller: _recipientNameController,
            style: TextStyle(fontSize: 15, color: AppColors.text),
            decoration: InputDecoration(
              labelText: 'Tên người nhận',
              labelStyle: TextStyle(
                color: AppColors.primaryDark,
                fontWeight: FontWeight.w500,
              ),
              hintText: 'Nhập tên người nhận',
              hintStyle: TextStyle(color: Colors.grey[400]),
              prefixIcon: Icon(Icons.person_outline, color: AppColors.primary),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide(color: AppColors.primary, width: 2),
              ),
              filled: true,
              fillColor: AppColors.card.withValues(alpha: 0.3),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),
          SizedBox(height: 16.0),

          // Phone
          TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            style: TextStyle(fontSize: 15, color: AppColors.text),
            decoration: InputDecoration(
              labelText: 'Số điện thoại',
              labelStyle: TextStyle(
                color: AppColors.primaryDark,
                fontWeight: FontWeight.w500,
              ),
              hintText: 'Nhập số điện thoại',
              hintStyle: TextStyle(color: Colors.grey[400]),
              prefixIcon: Icon(Icons.phone_outlined, color: AppColors.primary),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide(color: AppColors.primary, width: 2),
              ),
              filled: true,
              fillColor: AppColors.card.withValues(alpha: 0.3),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),
          SizedBox(height: 16.0),

          // Location Picker
          GestureDetector(
            onTap: () async {
              String? province = _selectedProvince;
              String? district = _selectedDistrict;
              String? ward = _selectedWard;
              await showDialog(
                context: context,
                builder: (context) {
                  List<dynamic> tempDistricts =
                      province != null
                          ? _provinces.firstWhere(
                            (p) => p['Name'] == province,
                          )['Districts']
                          : [];
                  List<dynamic> tempWards =
                      district != null
                          ? tempDistricts.firstWhere(
                            (d) => d['Name'] == district,
                          )['Wards']
                          : [];
                  String? tempProvince = province;
                  String? tempDistrict = district;
                  String? tempWard = ward;
                  return StatefulBuilder(
                    builder: (context, setStateDialog) {
                      return AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        backgroundColor: Colors.white,
                        title: Row(
                          children: [
                            Icon(
                              Icons.location_city,
                              color: AppColors.primaryDark,
                              size: 26,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Chọn địa chỉ',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryDark,
                              ),
                            ),
                          ],
                        ),
                        content: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              DropdownButtonFormField<String>(
                                dropdownColor: Colors.white,
                                isExpanded: true,
                                decoration: InputDecoration(
                                  labelText: 'Tỉnh/Thành phố',
                                  labelStyle: TextStyle(
                                    color: AppColors.primaryDark,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: Colors.grey[300]!,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: Colors.grey[300]!,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: AppColors.primary,
                                      width: 2,
                                    ),
                                  ),
                                  filled: true,
                                  fillColor: AppColors.card.withValues(
                                    alpha: 0.3,
                                  ),
                                ),
                                initialValue: tempProvince,
                                items:
                                    _provinces.map<DropdownMenuItem<String>>((
                                      province,
                                    ) {
                                      return DropdownMenuItem<String>(
                                        value: province['Name'],
                                        child: Text(province['Name']),
                                      );
                                    }).toList(),
                                onChanged: (value) {
                                  setStateDialog(() {
                                    tempProvince = value;
                                    tempDistrict = null;
                                    tempWard = null;
                                    tempDistricts =
                                        _provinces.firstWhere(
                                          (p) => p['Name'] == value,
                                        )['Districts'];
                                    tempWards = [];
                                  });
                                },
                              ),
                              SizedBox(height: 16.0),
                              DropdownButtonFormField<String>(
                                dropdownColor: Colors.white,
                                isExpanded: true,
                                decoration: InputDecoration(
                                  labelText: 'Quận/Huyện',
                                  labelStyle: TextStyle(
                                    color: AppColors.primaryDark,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: Colors.grey[300]!,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: Colors.grey[300]!,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: AppColors.primary,
                                      width: 2,
                                    ),
                                  ),
                                  filled: true,
                                  fillColor: AppColors.card.withValues(
                                    alpha: 0.3,
                                  ),
                                ),
                                initialValue: tempDistrict,
                                items:
                                    tempDistricts.map<DropdownMenuItem<String>>(
                                      (district) {
                                        return DropdownMenuItem<String>(
                                          value: district['Name'],
                                          child: Text(district['Name']),
                                        );
                                      },
                                    ).toList(),
                                onChanged: (value) {
                                  setStateDialog(() {
                                    tempDistrict = value;
                                    tempWard = null;
                                    tempWards =
                                        tempDistricts.firstWhere(
                                          (d) => d['Name'] == value,
                                        )['Wards'];
                                  });
                                },
                              ),
                              SizedBox(height: 16.0),
                              DropdownButtonFormField<String>(
                                dropdownColor: Colors.white,
                                isExpanded: true,
                                decoration: InputDecoration(
                                  labelText: 'Phường/Xã',
                                  labelStyle: TextStyle(
                                    color: AppColors.primaryDark,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: Colors.grey[300]!,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: Colors.grey[300]!,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: AppColors.primary,
                                      width: 2,
                                    ),
                                  ),
                                  filled: true,
                                  fillColor: AppColors.card.withValues(
                                    alpha: 0.3,
                                  ),
                                ),
                                initialValue: tempWard,
                                items:
                                    tempWards.map<DropdownMenuItem<String>>((
                                      ward,
                                    ) {
                                      return DropdownMenuItem<String>(
                                        value: ward['Name'],
                                        child: Text(ward['Name']),
                                      );
                                    }).toList(),
                                onChanged: (value) {
                                  setStateDialog(() {
                                    tempWard = value;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text(
                              'Hủy',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16,
                              ),
                            ),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryDark,
                              disabledBackgroundColor: Colors.grey[300],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                            onPressed:
                                tempProvince != null &&
                                        tempDistrict != null &&
                                        tempWard != null
                                    ? () {
                                      setState(() {
                                        _selectedProvince = tempProvince;
                                        _selectedDistrict = tempDistrict;
                                        _selectedWard = tempWard;
                                        _districts =
                                            _provinces.firstWhere(
                                              (p) => p['Name'] == tempProvince,
                                            )['Districts'];
                                        _wards =
                                            _districts.firstWhere(
                                              (d) => d['Name'] == tempDistrict,
                                            )['Wards'];
                                        _addressDisplayController.text =
                                            '$_selectedWard, $_selectedDistrict, $_selectedProvince';
                                      });
                                      Navigator.of(context).pop();
                                    }
                                    : null,
                            child: Text(
                              'Xong',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              );
            },
            child: AbsorbPointer(
              child: TextField(
                controller: _addressDisplayController,
                style: TextStyle(fontSize: 15, color: AppColors.text),
                decoration: InputDecoration(
                  labelText: 'Tỉnh/Thành phố - Quận/Huyện - Phường/Xã',
                  labelStyle: TextStyle(
                    color: AppColors.primaryDark,
                    fontWeight: FontWeight.w500,
                  ),
                  hintText: 'Chọn địa chỉ',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  prefixIcon: Icon(
                    Icons.location_city,
                    color: AppColors.primary,
                  ),
                  suffixIcon: Icon(
                    Icons.arrow_drop_down,
                    color: AppColors.primary,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(color: AppColors.primary, width: 2),
                  ),
                  filled: true,
                  fillColor: AppColors.card.withValues(alpha: 0.3),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 16.0),

          // Sub Address (Specific address)
          TextField(
            controller: _subAddressController,
            style: TextStyle(fontSize: 15, color: AppColors.text),
            maxLines: 1,
            decoration: InputDecoration(
              labelText: 'Địa chỉ cụ thể',
              labelStyle: TextStyle(
                color: AppColors.primaryDark,
                fontWeight: FontWeight.w500,
              ),
              hintText: 'Số nhà, tên đường, thôn xóm...',
              hintStyle: TextStyle(color: Colors.grey[400]),
              prefixIcon: Icon(Icons.home_outlined, color: AppColors.primary),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide(color: AppColors.primary, width: 2),
              ),
              filled: true,
              fillColor: AppColors.card.withValues(alpha: 0.3),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductItem({
    required String title,
    required String price,
    required String originalPrice,
    required int discount,
    required String quantity,
    String? thumbnailUrl,
    List<String>? gift,
  }) {
    return Column(
      children: [
        Row(
          children: [
            if (thumbnailUrl != null && thumbnailUrl.isNotEmpty)
              Container(
                width: 90,
                height: 140,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  color: AppColors.primaryDark,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: Offset(2, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.network(
                    'http://10.0.2.2:8080/storage/Product/$thumbnailUrl',
                    fit: BoxFit.cover,
                    errorBuilder:
                        (context, error, stackTrace) => Icon(
                          Icons.image,
                          size: 30,
                          color: Colors.grey[300],
                        ),
                  ),
                ),
              )
            else
              Container(
                width: 90,
                height: 140,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  color: AppColors.primaryDark,
                ),
                child: Icon(Icons.image, size: 30, color: Colors.grey[300]),
              ),
            SizedBox(width: 16.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 17.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (gift != null)
                    ...gift.map(
                      (g) => Text(
                        g,
                        style: TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w500,
                          color: AppColors.black70,
                        ),
                      ),
                    ),
                  SizedBox(height: 12.0),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        price,
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w900,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(width: 8),
                      Spacer(),
                      Text(
                        quantity,
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        Divider(color: Colors.grey, height: 32.0),
      ],
    );
  }

  // ignore: unused_element
  Widget _buildGiftItem() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(alignment: Alignment.topLeft, child: Text('Free gift:')),
        SizedBox(height: 8.0),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 50,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                color: AppColors.primaryDark,
              ),
              child: Icon(Icons.image, size: 20, color: Colors.grey[300]),
            ),
            SizedBox(width: 16.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Trốn Lên Mái Nhà Để Khóc',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Free',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      Spacer(),
                      Text(
                        'x1',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProductsSection() {
    return BlocBuilder<CartBloc, CartState>(
      builder: (context, state) {
        if (state is CartLoading) {
          return Center(child: CircularProgressIndicator());
        } else if (state is CartLoaded) {
          final cartItems =
              state.cart.items.where((item) => item.isSelected).toList();
          if (cartItems.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                //'No products selected for checkout. Please select items in your cart.',
                'Chưa có sản phẩm nào được chọn để thanh toán. Vui lòng chọn sản phẩm trong giỏ hàng của bạn.',
                style: TextStyle(fontSize: 16, color: AppColors.black70),
              ),
            );
          } else {
            return Container(
              margin: EdgeInsets.only(top: 10.0, left: 18.0, right: 18.0),
              padding: EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.0),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    spreadRadius: 1,
                    offset: Offset(0, 0),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...cartItems.map(
                    (item) => _buildProductItem(
                      title: item.bookName,
                      price: FormatPrice.formatPrice(item.unitPrice),
                      thumbnailUrl: item.bookThumbnail,
                      originalPrice: FormatPrice.formatPrice(item.unitPrice),
                      discount: item.sale.toInt(),
                      quantity: 'x${item.quantity}',
                      gift: ['Tặng kèm 1 bookmark', 'Tặng kèm 1 túi vải'],
                    ),
                  ),
                  // _buildGiftItem(),
                ],
              ),
            );
          }
        } else if (state is CartError) {
          return Center(
            child: Text(
              //'Failed to load cart items'
              'Tải mục giỏ hàng thất bại',
            ),
          );
        } else {
          return SizedBox.shrink();
        }
      },
    );
  }

  Widget _buildDiscountSection() {
    return Container(
      margin: EdgeInsets.only(bottom: 10.0, top: 10.0, left: 18.0, right: 18.0),
      padding: EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.0),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            spreadRadius: 1,
            offset: Offset(0, 0),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.discount_rounded, color: AppColors.black60, size: 30),
              SizedBox(width: 8.0),
              Text(
                //'Discount:',
                'Giảm giá:',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              Spacer(),
              IconButton(
                onPressed: () {
                  setState(() {
                    showAllPromotions = !showAllPromotions;
                  });
                },
                icon: Icon(
                  showAllPromotions
                      ? Icons.keyboard_arrow_up
                      : Icons.arrow_forward_ios,
                  color: AppColors.primaryDark,
                  size: 20,
                ),
              ),
            ],
          ),

          // Danh sách promotions
          SizedBox(height: 8.0),
          BlocBuilder<PromotionBloc, PromotionState>(
            builder: (context, promotionState) {
              if (promotionState is PromotionLoading) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              } else if (promotionState is PromotionLoaded) {
                return BlocBuilder<CartBloc, CartState>(
                  builder: (context, cartState) {
                    if (cartState is! CartLoaded) {
                      return SizedBox.shrink();
                    }

                    // Tính tổng tiền đơn hàng
                    final selectedItems =
                        cartState.cart.items
                            .where((item) => item.isSelected)
                            .toList();
                    final totalAmount = selectedItems.fold<double>(
                      0,
                      (sum, item) =>
                          sum +
                          (item.unitPrice -
                                  (item.unitPrice * item.sale / 100)) *
                              item.quantity,
                    );

                    // Lọc promotions còn hiệu lực và đang active
                    final now = DateTime.now();
                    final validPromotions =
                        promotionState.promotions.where((promo) {
                          if (!promo.status) {
                            return false;
                          }
                          if (promo.endDate != null) {
                            try {
                              final endDate = DateFormat(
                                'yyyy-MM-dd',
                              ).parse(promo.endDate!);
                              if (endDate.isBefore(now)) return false;
                            } catch (e) {
                              return false;
                            }
                          }
                          return true;
                        }).toList();

                    // Hiển thị 2 hoặc tất cả promotions
                    final displayPromotions =
                        showAllPromotions
                            ? validPromotions
                            : validPromotions.take(1).toList();

                    if (validPromotions.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(
                          child: Text(
                            'Không có mã giảm giá khả dụng',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      );
                    }

                    return Column(
                      children: [
                        ...displayPromotions.map((promotion) {
                          // Kiểm tra order có thỏa điều kiện không
                          final isEligible =
                              totalAmount >= (promotion.orderMinValue ?? 0);
                          final isSelected =
                              selectedPromotionId == promotion.id;

                          return _buildPromotionItem(
                            promotion: promotion,
                            isEligible: isEligible,
                            isSelected: isSelected,
                            onTap: () {
                              if (isEligible) {
                                setState(() {
                                  selectedPromotionId =
                                      isSelected ? null : promotion.id;
                                });
                              } else {
                                // Hiển thị thông báo không đủ điều kiện
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Đơn hàng chưa đạt giá trị tối thiểu ${FormatPrice.formatPrice(promotion.orderMinValue ?? 0)}',
                                    ),
                                    backgroundColor: Colors.orange,
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              }
                            },
                          );
                        }),
                        if (validPromotions.length > 2)
                          TextButton(
                            onPressed: () {
                              setState(() {
                                showAllPromotions = !showAllPromotions;
                              });
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  showAllPromotions
                                      ? 'Thu gọn'
                                      : 'Xem thêm ${validPromotions.length - 2} mã',
                                  style: TextStyle(
                                    color: AppColors.primaryDark,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Icon(
                                  showAllPromotions
                                      ? Icons.keyboard_arrow_up
                                      : Icons.keyboard_arrow_down,
                                  color: AppColors.primaryDark,
                                ),
                              ],
                            ),
                          ),
                      ],
                    );
                  },
                );
              } else if (promotionState is PromotionError) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Lỗi tải mã giảm giá',
                    style: TextStyle(color: Colors.red),
                  ),
                );
              }
              return SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSection() {
    return Container(
      margin: EdgeInsets.only(bottom: 10.0, top: 10.0, left: 18.0, right: 18.0),
      padding: EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.0),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            spreadRadius: 1,
            offset: Offset(0, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.payment, color: AppColors.black60, size: 30),
              SizedBox(width: 8.0),
              Text(
                'Phương thức thanh toán',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: 16.0),
          // Display hardcoded payment methods
          Column(
            children:
                _paymentMethods
                    .map(
                      (payment) => _buildPaymentMethodItem(
                        payment.name,
                        payment.icon,
                        payment.id,
                        payment.isActive,
                      ),
                    )
                    .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodItem(
    String title,
    IconData icon,
    int paymentId,
    bool isActive,
  ) {
    final isSelected = selectedPaymentId == paymentId;

    return Padding(
      padding: EdgeInsets.only(bottom: 12.0),
      child: GestureDetector(
        onTap:
            isActive
                ? () {
                  setState(() {
                    selectedPaymentId = paymentId;
                  });
                }
                : null,
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                color: isActive ? Colors.white : Colors.grey[200],
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    spreadRadius: 2,
                    offset: Offset(2, 4),
                  ),
                ],
              ),
              child: Icon(
                icon,
                size: 24,
                color: isActive ? AppColors.primaryDark : Colors.grey[400],
              ),
            ),
            SizedBox(width: 12.0),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w500,
                  color: isActive ? AppColors.black70 : Colors.grey[400],
                ),
              ),
            ),
            if (isActive) ...[
              CustomCircleCheckbox(
                value: isSelected,
                onChanged: (value) {
                  if (isActive) {
                    setState(() {
                      selectedPaymentId = paymentId;
                    });
                  }
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Helper function để tính giá trị giảm từ promotion
  double _calculatePromotionDiscount(Promotion promotion, double subtotal) {
    if (promotion.promotionType.toLowerCase() == 'freeship') {
      // Miễn phí ship, trả về giá trị shipping fee (30000)
      return 30000.0;
    } else if (promotion.promotionType.toLowerCase() == 'percent') {
      // Giảm theo phần trăm
      double discountValue = subtotal * (promotion.promotionValue ?? 0) / 100;
      // Kiểm tra giảm tối đa
      if (promotion.isMaxPromotionValue &&
          promotion.maxPromotionValue != null &&
          discountValue > promotion.maxPromotionValue!) {
        return promotion.maxPromotionValue!;
      }
      return discountValue;
    } else {
      // Giảm giá cố định
      return promotion.promotionValue ?? 0;
    }
  }

  Widget _buildPromotionItem({
    required Promotion promotion,
    required bool isEligible,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    // Format ngày hết hạn
    String validUntil = '';
    if (promotion.endDate != null) {
      try {
        final date = DateFormat('yyyy-MM-dd').parse(promotion.endDate!);
        validUntil = 'HSD: ${DateFormat('dd/MM/yyyy').format(date)}';
      } catch (e) {
        validUntil = 'HSD: ${promotion.endDate}';
      }
    }

    return Opacity(
      opacity: isEligible ? 1.0 : 0.5,
      child: Container(
        margin: EdgeInsets.only(bottom: 12.0),
        padding: EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? AppColors.primaryDark.withValues(alpha: 0.1)
                  : Colors.grey[100],
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color:
                isSelected
                    ? AppColors.primaryDark
                    : (isEligible ? Colors.grey[300]! : Colors.grey[400]!),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12.0),
          child: Row(
            children: [
              // Icon promotion
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color:
                      isEligible
                          ? AppColors.primaryDark.withValues(alpha: 0.1)
                          : Colors.grey[300],
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Icon(
                  promotion.promotionType.toLowerCase() == 'freeship'
                      ? Icons.local_shipping
                      : Icons.discount,
                  color: isEligible ? AppColors.primaryDark : Colors.grey[600],
                  size: 28,
                ),
              ),
              SizedBox(width: 12.0),
              // Thông tin promotion
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      promotion.name,
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        color: isEligible ? Colors.black87 : Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 4.0),
                    if (promotion.promotionType.toLowerCase() == 'percent')
                      Text(
                        'Giảm giá ${promotion.promotionValue}% cho đơn hàng từ ${FormatPrice.formatPrice(promotion.orderMinValue ?? 0)}',
                        style: TextStyle(
                          fontSize: 13.0,
                          color: isEligible ? Colors.black54 : Colors.grey[500],
                        ),
                      )
                    else
                      Text(
                        'Giảm giá ${FormatPrice.formatPrice(promotion.promotionValue ?? 0)} cho đơn hàng từ ${FormatPrice.formatPrice(promotion.orderMinValue ?? 0)}',
                        style: TextStyle(
                          fontSize: 13.0,
                          color: isEligible ? Colors.black54 : Colors.grey[500],
                        ),
                      ),
                    if (validUntil.isNotEmpty) ...[
                      SizedBox(height: 4.0),
                      Text(
                        validUntil,
                        style: TextStyle(
                          fontSize: 12.0,
                          color: isEligible ? AppColors.text : Colors.grey[400],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                    if (!isEligible) ...[
                      SizedBox(height: 4.0),
                      Text(
                        'Chưa đủ điều kiện',
                        style: TextStyle(
                          fontSize: 12.0,
                          color: Colors.red,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // Checkbox
              CustomCircleCheckbox(
                value: isSelected,
                onChanged:
                    isEligible
                        ? (value) {
                          onTap();
                        }
                        : (value) {},
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoteSection(TextEditingController noteController) {
    return Container(
      margin: EdgeInsets.only(bottom: 20.0, top: 10.0, left: 18.0, right: 18.0),
      padding: EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.0),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            spreadRadius: 1,
            offset: Offset(0, 0),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.note_alt_outlined, color: AppColors.black60, size: 30),
              SizedBox(width: 8.0),
              Text(
                //'Order Note',
                'Ghi chú đơn hàng',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: noteController,
              maxLines: 4,
              maxLength: 200,
              textInputAction: TextInputAction.done,
              style: TextStyle(
                fontSize: 15,
                color: Colors.black87,
                height: 1.5,
              ),
              decoration: InputDecoration(
                //hintText: 'Enter your note or special request to the shop...',
                hintText: 'Nhập ghi chú hoặc yêu cầu cho cửa hàng...',
                hintStyle: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 14,
                  height: 1.4,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                counterStyle: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummarySection() {
    return BlocBuilder<CartBloc, CartState>(
      builder: (context, state) {
        if (state is CartLoading) {
          return Center(child: CircularProgressIndicator());
        } else if (state is CartLoaded) {
          final cartItems =
              state.cart.items.where((item) => item.isSelected).toList();
          if (cartItems.isEmpty) {
            return SizedBox.shrink();
          } else {
            final subtotal = cartItems.fold<double>(
              0.0,
              (sum, item) => sum + (item.unitPrice) * item.quantity,
            );

            double shippingFee = 30000.0;
            final discount = cartItems.fold<double>(
              0.0,
              (sum, item) =>
                  sum + (item.unitPrice * (item.sale / 100)) * item.quantity,
            );

            // Tính giảm giá từ promotion
            return BlocBuilder<PromotionBloc, PromotionState>(
              builder: (context, promotionState) {
                double promotionDiscount = 0.0;
                bool isFreeShip = false;

                if (promotionState is PromotionLoaded &&
                    selectedPromotionId != null) {
                  final selectedPromotion = promotionState.promotions
                      .firstWhere(
                        (promo) => promo.id == selectedPromotionId,
                        orElse: () => promotionState.promotions.first,
                      );

                  if (selectedPromotion.promotionType.toLowerCase() ==
                      'freeship') {
                    isFreeShip = true;
                    promotionDiscount = shippingFee;
                    shippingFee = 0.0;
                  } else {
                    promotionDiscount = _calculatePromotionDiscount(
                      selectedPromotion,
                      subtotal,
                    );
                  }
                }

                final total =
                    subtotal + shippingFee - discount - promotionDiscount;

                return Container(
                  margin: EdgeInsets.only(
                    bottom: 20.0,
                    left: 18.0,
                    right: 18.0,
                  ),
                  padding: EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.0),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 8,
                        spreadRadius: 1,
                        offset: Offset(0, 0),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSummaryRow(
                        //'Subtotal',
                        'Tạm tính',
                        FormatPrice.formatPrice(subtotal),
                      ),
                      _buildSummaryRow(
                        //'Shipping Fee',
                        'Phí vận chuyển',
                        FormatPrice.formatPrice(isFreeShip ? 0.0 : 30000.0),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 12),
                        child: Text(
                          //'Discounts:',
                          'Giảm giá:',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.black70,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      SizedBox(height: 4),
                      if (isFreeShip)
                        Padding(
                          padding: EdgeInsets.only(left: 12),
                          child: _buildSummaryRow(
                            //'- Shipping Voucher',
                            '- Giảm phí vận chuyển',
                            '-${FormatPrice.formatPrice(30000.0)}',
                          ),
                        )
                      else
                        Padding(
                          padding: EdgeInsets.only(left: 12),
                          child: _buildSummaryRow(
                            //'- Shipping Voucher',
                            '- Giảm phí vận chuyển',
                            '-${FormatPrice.formatPrice(0.0)}',
                          ),
                        ),
                      Padding(
                        padding: EdgeInsets.only(left: 12),
                        child: _buildSummaryRow(
                          //'- Member Voucher',
                          '- Mã giảm giá',
                          '-${FormatPrice.formatPrice(isFreeShip ? 0.0 : promotionDiscount)}',
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 12),
                        child: _buildSummaryRow(
                          //'- Product Voucher',
                          '- Giảm giá sản phẩm',
                          '-${FormatPrice.formatPrice(discount)}',
                        ),
                      ),
                      Divider(color: Colors.grey, height: 32.0),
                      _buildSummaryRow(
                        //'Total Discounts',
                        'Tổng giảm giá',
                        '-${FormatPrice.formatPrice(discount + promotionDiscount)}',
                        isBold: true,
                      ),
                      _buildSummaryRow(
                        //'Total',
                        'Tổng cộng',
                        FormatPrice.formatPrice(total),
                        isBold: true,
                      ),
                    ],
                  ),
                );
              },
            );
          }
        } else if (state is CartError) {
          return Center(
            child: Text(
              //'Failed to load cart items'
              'Tải mục giỏ hàng thất bại',
            ),
          );
        } else {
          return SizedBox.shrink();
        }
      },
    );
  }

  Widget _buildBottomNavigationBar() {
    return BlocBuilder<CartBloc, CartState>(
      builder: (context, state) {
        if (state is CartLoading) {
          return SizedBox(
            height: 70,
            child: Center(child: CircularProgressIndicator()),
          );
        } else if (state is CartLoaded) {
          final cartItems =
              state.cart.items.where((item) => item.isSelected).toList();
          if (cartItems.isEmpty) {
            return SizedBox.shrink();
          } else {
            final subtotal = cartItems.fold<double>(
              0.0,
              (sum, item) => sum + (item.unitPrice) * item.quantity,
            );

            final totalQuantity = cartItems.fold<int>(
              0,
              (sum, item) => sum + item.quantity,
            );

            final discount = cartItems.fold<double>(
              0.0,
              (sum, item) =>
                  sum + (item.unitPrice * (item.sale / 100)) * item.quantity,
            );

            // Tính giảm giá từ promotion và shipping fee
            return BlocBuilder<PromotionBloc, PromotionState>(
              builder: (context, promotionState) {
                double promotionDiscount = 0.0;
                double shippingFee = 30000.0;

                if (promotionState is PromotionLoaded &&
                    selectedPromotionId != null) {
                  final selectedPromotion = promotionState.promotions
                      .firstWhere(
                        (promo) => promo.id == selectedPromotionId,
                        orElse: () => promotionState.promotions.first,
                      );

                  if (selectedPromotion.promotionType.toLowerCase() ==
                      'freeship') {
                    promotionDiscount = shippingFee;
                    shippingFee = 0.0;
                  } else {
                    promotionDiscount = _calculatePromotionDiscount(
                      selectedPromotion,
                      subtotal,
                    );
                  }
                }

                final totalPrice =
                    subtotal + shippingFee - discount - promotionDiscount;
                final totalSavings = discount + promotionDiscount;

                return Container(
                  height: 160,
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 18.0,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 8,
                        spreadRadius: 1,
                        offset: Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Text(
                            //'Total',
                            'Tổng cộng:',
                            style: TextStyle(
                              fontSize: 22.0,
                              fontWeight: FontWeight.w900,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(width: 4.0),
                          Text(
                            //'($totalQuantity items)',
                            '($totalQuantity sản phẩm)',
                            style: TextStyle(
                              fontSize: 14.0,
                              fontWeight: FontWeight.w900,
                              color: AppColors.black70,
                            ),
                          ),
                          Spacer(),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                FormatPrice.formatPrice(totalPrice),
                                style: TextStyle(
                                  fontSize: 22.0,
                                  color: Colors.red,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              Text(
                                //'Save ${FormatPrice.formatPrice(totalSavings)}',
                                'Tiết kiệm ${FormatPrice.formatPrice(totalSavings)}',
                                style: TextStyle(
                                  letterSpacing: -1,
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.black70,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 10.0),
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed:
                              (_isAddressValid() && selectedPaymentId != null)
                                  ? () {
                                    // Validate address fields
                                    if (_recipientNameController.text
                                        .trim()
                                        .isEmpty) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Vui lòng nhập tên người nhận',
                                          ),
                                          backgroundColor: Colors.orange,
                                        ),
                                      );
                                      return;
                                    }
                                    if (_phoneController.text.trim().isEmpty) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Vui lòng nhập số điện thoại',
                                          ),
                                          backgroundColor: Colors.orange,
                                        ),
                                      );
                                      return;
                                    }
                                    if (!RegExp(
                                      r'^0[0-9]{9,10}$',
                                    ).hasMatch(_phoneController.text.trim())) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Số điện thoại không hợp lệ (10-11 chữ số, bắt đầu bằng 0)',
                                          ),
                                          backgroundColor: Colors.orange,
                                        ),
                                      );
                                      return;
                                    }
                                    if (_selectedProvince == null ||
                                        _selectedDistrict == null ||
                                        _selectedWard == null) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Vui lòng chọn đầy đủ địa chỉ (Tỉnh/Huyện/Xã)',
                                          ),
                                          backgroundColor: Colors.orange,
                                        ),
                                      );
                                      return;
                                    }

                                    // Get user data
                                    final authState =
                                        context.read<UserBloc>().state;

                                    if (authState is! UserLoaded) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Vui lòng đăng nhập để đặt hàng',
                                          ),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                      return;
                                    }

                                    final userData = authState.userData;

                                    // Get payment method name from hardcoded list
                                    String paymentMethodName = 'COD';
                                    if (selectedPaymentId != null) {
                                      final selectedPayment = _paymentMethods
                                          .firstWhere(
                                            (p) => p.id == selectedPaymentId,
                                            orElse: () => _paymentMethods.first,
                                          );
                                      paymentMethodName = selectedPayment.name;
                                    }

                                    // Build items list from cart
                                    final items =
                                        cartItems.map((item) {
                                          return {
                                            'productId': item.bookId,
                                            'quantity': item.quantity,
                                            'cartItemId': item.id,
                                          };
                                        }).toList();

                                    // Dispatch CreateOrder event
                                    context.read<OrderBloc>().add(
                                      CreateOrder(
                                        note: _noteController.text.trim(),
                                        paymentMethod: paymentMethodName,
                                        phone: _phoneController.text.trim(),
                                        address: _getFullAddress(),
                                        name:
                                            _recipientNameController.text
                                                .trim(),
                                        items: items,
                                        promotionId: selectedPromotionId,
                                        customerId: userData.customer!.id,
                                      ),
                                    );
                                  }
                                  : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                (_isAddressValid() && selectedPaymentId != null)
                                    ? AppColors.primaryDark
                                    : Colors.grey,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                          ),
                          child: Text(
                            //'Place Order',
                            'Đặt hàng',
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          }
        } else if (state is CartError) {
          return SizedBox(
            height: 70,
            child: Center(
              child: Text(
                //'Failed to load cart items'
                'Tải mục giỏ hàng thất bại',
              ),
            ),
          );
        } else {
          return SizedBox.shrink();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OrderBloc, OrderState>(
      listener: (context, state) {
        if (state is OrderLoaded && state.message != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white, size: 24),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '${state.message}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: EdgeInsets.all(16),
              duration: Duration(seconds: 2),
              elevation: 8,
            ),
          );
          // Navigate back to home or orders screen after successful order
          final navigator = Navigator.of(context);
          Future.delayed(Duration(seconds: 3), () {
            if (mounted) {
              navigator.pushNamed('/main');
            }
          });
        } else if (state is OrderError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(
                    Icons.error_outline_outlined,
                    color: Colors.white,
                    size: 24,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      //'Order failed: ${state.message}',
                      'Đặt hàng thất bại: ${state.message}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: EdgeInsets.all(16),
              duration: Duration(seconds: 3),
              elevation: 8,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppbarCustomWidget(
          //title: 'Order Summary'
          title: 'Tóm tắt đơn hàng',
        ),
        body: Container(
          color: AppColors.background,
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildAddressSection(),
                _buildProductsSection(),
                _buildDiscountSection(),
                _buildPaymentSection(),
                _buildNoteSection(_noteController),
                _buildOrderSummarySection(),
              ],
            ),
          ),
        ),
        bottomNavigationBar: _buildBottomNavigationBar(),
      ),
    );
  }
}
