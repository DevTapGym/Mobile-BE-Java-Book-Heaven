import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:heaven_book_app/bloc/address/address_bloc.dart';
import 'package:heaven_book_app/bloc/address/address_state.dart';
import 'package:heaven_book_app/bloc/book/book_bloc.dart';
import 'package:heaven_book_app/bloc/book/book_event.dart';
import 'package:heaven_book_app/bloc/order/order_bloc.dart';
import 'package:heaven_book_app/bloc/order/order_event.dart';
import 'package:heaven_book_app/bloc/order/order_state.dart';
import 'package:heaven_book_app/bloc/payment/payment_bloc.dart';
import 'package:heaven_book_app/bloc/payment/payment_event.dart';
import 'package:heaven_book_app/bloc/payment/payment_state.dart';
import 'package:heaven_book_app/model/checkout.dart';
import 'package:heaven_book_app/themes/app_colors.dart';
import 'package:heaven_book_app/themes/format_price.dart';
import 'package:heaven_book_app/widgets/address_card_widget.dart';
import 'package:heaven_book_app/widgets/appbar_custom_widget.dart';
import 'package:heaven_book_app/widgets/custom_circle_checkbox.dart';

class BuyNowScreen extends StatefulWidget {
  const BuyNowScreen({super.key});

  @override
  State<BuyNowScreen> createState() => _BuyNowScreenState();
}

class _BuyNowScreenState extends State<BuyNowScreen> {
  bool isChecked = false;
  int? selectedPaymentId;
  final TextEditingController _noteController = TextEditingController();

  // Checkout items từ arguments
  List<Checkout> checkoutItems = [];
  bool _isInitialized = false;
  @override
  void initState() {
    super.initState();
    context.read<PaymentBloc>().add(LoadPaymentMethods());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _isInitialized = true;
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null && args['items'] != null) {
        checkoutItems = args['items'] as List<Checkout>;
      }
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
    return BlocBuilder<AddressBloc, AddressState>(
      builder: (context, state) {
        if (state is AddressLoading) {
          return Center(child: CircularProgressIndicator());
        } else if (state is AddressLoaded) {
          final address = state.addresses;
          if (address.isEmpty) {
            return Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 40.0,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.location_off_outlined,
                    size: 80,
                    color: Colors.grey.withValues(alpha: 0.6),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    //'No shipping address found',
                    'Chưa có địa chỉ giao hàng',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    //'Please add a shipping address in your profile to continue.',
                    'Vui lòng thêm địa chỉ giao hàng trong hồ sơ của bạn để tiếp tục.',
                    style: TextStyle(fontSize: 15, color: Colors.black54),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, '/shipping-address');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    icon: const Icon(
                      Icons.add_location_alt_outlined,
                      color: Colors.white,
                    ),
                    label: const Text(
                      //'Add Address',
                      'Thêm địa chỉ',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else {
            final defaultAddress = address.firstWhere(
              (addr) => addr.isDefault == 1,
              orElse: () => address[0],
            );
            return AddressCardWidget(
              title: defaultAddress.tagName,
              name: defaultAddress.recipientName,
              phone: defaultAddress.phoneNumber,
              address: defaultAddress.address,
              isDefault: false,
              hasEditButton: false,
              hasDeleteButton: false,
              isTappable: true,
              onTap: () {
                Navigator.pushNamed(context, '/shipping-address');
              },
            );
          }
        } else if (state is AddressError) {
          return Center(
            child: Text(
              //'Failed to load addresses'
              'Tải địa chỉ thất bại',
            ),
          );
        } else {
          return SizedBox.shrink();
        }
      },
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
                    'http://10.0.2.2:8000$thumbnailUrl',
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
                  Text(
                    price,
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (discount > 0) ...[
                        Text(
                          originalPrice,
                          style: TextStyle(
                            decoration: TextDecoration.lineThrough,
                            decorationColor: Colors.grey,
                            color: Colors.grey,
                            fontSize: 15,
                          ),
                        ),
                      ],
                      SizedBox(width: 8),
                      if (discount > 0) ...[
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.discountRed,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 4,
                                offset: Offset(2, 4),
                              ),
                            ],
                          ),
                          child: Text(
                            '-$discount%',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],

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
    if (checkoutItems.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(20.0),
        child: Text(
          //'No products for checkout.',
          'Không có sản phẩm để thanh toán.',
          style: TextStyle(fontSize: 16, color: AppColors.black70),
        ),
      );
    }

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
          ...checkoutItems.map(
            (item) => _buildProductItem(
              title: item.bookTitle,
              price: FormatPrice.formatPrice(
                item.unitPrice - (item.unitPrice * item.saleOff / 100),
              ),
              thumbnailUrl: item.bookThumbnail,
              originalPrice: FormatPrice.formatPrice(item.unitPrice),
              discount: item.saleOff.toInt(),
              quantity: 'x${item.quantity}',
              gift: ['Tặng kèm 1 bookmark', 'Tặng kèm 1 túi vải'],
            ),
          ),
        ],
      ),
    );
  }

  // ignore: unused_element
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
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.discount_rounded,
                    color: AppColors.black60,
                    size: 30,
                  ),
                  SizedBox(width: 8.0),
                  Text(
                    'Discount:',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.0),
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 18.0,
                      vertical: 4.0,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      border: Border.all(
                        color: AppColors.primaryDark,
                        width: 2,
                      ),
                    ),
                    child: Text(
                      'Free Ship',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.0),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 18.0,
                      vertical: 4.0,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.discountRed.withAlpha(40),
                      border: Border.all(
                        color: AppColors.discountRed,
                        width: 2,
                      ),
                    ),
                    child: Text(
                      '-60.000 đ',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.discountRed,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Spacer(),
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.arrow_forward_ios,
              color: AppColors.primaryDark,
              size: 20,
            ),
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
                //'Payment Method',
                'Phương Thức Thanh Toán',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: 16.0),
          BlocBuilder<PaymentBloc, PaymentState>(
            builder: (context, state) {
              if (state is PaymentLoading) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              } else if (state is PaymentLoaded) {
                return Column(
                  children:
                      state.payments
                          .map(
                            (payment) => _buildPaymentMethodItem(
                              payment.name,
                              payment.imageUrl ?? '',
                              payment.id,
                              payment.isActive,
                            ),
                          )
                          .toList(),
                );
              } else if (state is PaymentError) {
                return Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Icon(Icons.error, color: Colors.red, size: 40),
                      SizedBox(height: 8),
                      Text(
                        //'Failed to load payment methods',
                        'Tải phương thức thanh toán thất bại',
                        style: TextStyle(color: Colors.red),
                      ),
                      SizedBox(height: 8),
                      Text(
                        state.message,
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              } else {
                return SizedBox.shrink();
              }
            },
          ),
          Divider(color: Colors.black54, height: 32.0, thickness: 1.5),
          SizedBox(height: 12.0),
          Row(
            children: [
              Icon(
                Icons.currency_exchange_rounded,
                color: Colors.black,
                size: 30,
              ),
              Spacer(),
              GestureDetector(
                onTap: () {},
                child: Row(
                  children: [
                    SizedBox(width: 4.0),
                    Text(
                      //'View All Options',
                      'Xem Tất Cả Tùy Chọn',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(width: 8.0),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.black,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodItem(
    String title,
    String logoUrl,
    int paymentId,
    int isActive,
  ) {
    final isSelected = selectedPaymentId == paymentId;

    return Padding(
      padding: EdgeInsets.only(bottom: 12.0),
      child: GestureDetector(
        onTap:
            isActive == 1
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
                color: isActive == 1 ? Colors.white : Colors.grey[200],
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    spreadRadius: 2,
                    offset: Offset(2, 4),
                  ),
                ],
              ),
              child:
                  logoUrl.isNotEmpty
                      ? ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Image.network(
                          'http://10.0.2.2:8000$logoUrl',
                          fit: BoxFit.cover,
                          errorBuilder:
                              (context, error, stackTrace) => Icon(
                                Icons.payment,
                                size: 24,
                                color: Colors.black,
                              ),
                        ),
                      )
                      : Icon(
                        Icons.attach_money_outlined,
                        size: 30,
                        color:
                            isActive == 1
                                ? AppColors.black70
                                : Colors.grey[400],
                      ),
            ),
            SizedBox(width: 8.0),
            Text(
              title,
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.w500,
                color: isActive == 1 ? AppColors.black70 : Colors.grey[400],
              ),
            ),
            Spacer(),
            if (isActive == 1) ...[
              CustomCircleCheckbox(
                value: isSelected,
                onChanged: (value) {
                  if (isActive == 1) {
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
                'Ghi Chú Đơn Hàng',
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
                hintText: 'Nhập ghi chú hoặc yêu cầu đặc biệt cho cửa hàng...',
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
    if (checkoutItems.isEmpty) {
      return SizedBox.shrink();
    }

    final subtotal = checkoutItems.fold<double>(
      0.0,
      (sum, item) => sum + (item.unitPrice) * item.quantity,
    );

    final shippingFee = 30000.0;
    final discount = checkoutItems.fold<double>(
      0.0,
      (sum, item) =>
          sum + (item.unitPrice * (item.saleOff / 100)) * item.quantity,
    );
    final total = subtotal + shippingFee - discount;

    return Container(
      margin: EdgeInsets.only(bottom: 20.0, left: 18.0, right: 18.0),
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
            'Phí Vận Chuyển',
            FormatPrice.formatPrice(shippingFee),
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
              '-${FormatPrice.formatPrice(0.0)}',
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
            'Tổng Giảm Giá',
            '-${FormatPrice.formatPrice(discount)}',
            isBold: true,
          ),
          _buildSummaryRow(
            //'Total',
            'Tổng Cộng',
            FormatPrice.formatPrice(total),
            isBold: true,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    final addressState = context.read<AddressBloc>().state;

    if (checkoutItems.isEmpty) {
      return SizedBox.shrink();
    }

    final totalPrice = checkoutItems.fold<double>(
      0.0,
      (sum, item) =>
          sum + (item.unitPrice * (1 - (item.saleOff / 100))) * item.quantity,
    );

    final totalQuantity = checkoutItems.fold<int>(
      0,
      (sum, item) => sum + item.quantity,
    );

    final discount = checkoutItems.fold<double>(
      0.0,
      (sum, item) =>
          sum + (item.unitPrice * (item.saleOff / 100)) * item.quantity,
    );

    return Container(
      height: 160,
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 18.0),
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
                'Tổng Cộng',
                style: TextStyle(
                  fontSize: 22.0,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                ),
              ),
              SizedBox(width: 4.0),
              Text(
                '($totalQuantity items)',
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
                    FormatPrice.formatPrice(totalPrice + 30000),
                    style: TextStyle(
                      fontSize: 22.0,
                      color: Colors.red,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    'Save ${FormatPrice.formatPrice(discount)}',
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
                  (addressState is AddressLoaded &&
                          addressState.addresses.isNotEmpty &&
                          selectedPaymentId != null)
                      ? () {
                        // Validate address
                        final receiver = addressState.addresses.firstWhere(
                          (addr) => addr.isDefault == 1,
                          orElse: () => addressState.addresses[0],
                        );

                        // Get payment method name
                        final paymentState = context.read<PaymentBloc>().state;
                        String paymentMethodName = 'COD';
                        if (paymentState is PaymentLoaded) {
                          final selectedPayment = paymentState.payments
                              .firstWhere(
                                (p) => p.id == selectedPaymentId,
                                orElse: () => paymentState.payments.first,
                              );
                          paymentMethodName = selectedPayment.name;
                        }

                        // Convert checkoutItems to items format
                        final items =
                            checkoutItems
                                .map(
                                  (item) => {
                                    'book_id': item.bookId,
                                    'quantity': item.quantity,
                                  },
                                )
                                .toList();

                        context.read<OrderBloc>().add(
                          CreateOrder(
                            note: _noteController.text.trim(),
                            paymentMethod: paymentMethodName,
                            phone: receiver.phoneNumber,
                            address: receiver.address,
                            name: receiver.recipientName,
                            items: items,
                          ),
                        );
                      }
                      : null,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    (addressState is AddressLoaded &&
                            addressState.addresses.isNotEmpty &&
                            selectedPaymentId != null)
                        ? AppColors.primaryDark
                        : Colors.grey,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              child: Text(
                //'Place Order',
                'Đặt Hàng',
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
          context.read<BookBloc>().add(LoadBooks());
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
                  Icon(Icons.check_circle, color: Colors.white, size: 24),
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
          title: 'Tóm Tắt Đơn Hàng',
        ),
        body: Container(
          color: AppColors.background,
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildAddressSection(),
                _buildProductsSection(),
                //_buildDiscountSection(),
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
