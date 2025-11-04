import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:heaven_book_app/bloc/address/address_bloc.dart';
import 'package:heaven_book_app/bloc/address/address_state.dart';
import 'package:heaven_book_app/bloc/cart/cart_bloc.dart';
import 'package:heaven_book_app/bloc/cart/cart_state.dart';
import 'package:heaven_book_app/bloc/order/order_bloc.dart';
import 'package:heaven_book_app/bloc/order/order_event.dart';
import 'package:heaven_book_app/bloc/order/order_state.dart';
import 'package:heaven_book_app/bloc/payment/payment_bloc.dart';
import 'package:heaven_book_app/bloc/payment/payment_event.dart';
import 'package:heaven_book_app/bloc/payment/payment_state.dart';
import 'package:heaven_book_app/bloc/promotion/promotion_bloc.dart';
import 'package:heaven_book_app/bloc/promotion/promotion_event.dart';
import 'package:heaven_book_app/bloc/promotion/promotion_state.dart';
import 'package:heaven_book_app/model/promotion.dart';
import 'package:heaven_book_app/themes/app_colors.dart';
import 'package:heaven_book_app/themes/format_price.dart';
import 'package:heaven_book_app/widgets/address_card_widget.dart';
import 'package:heaven_book_app/widgets/appbar_custom_widget.dart';
import 'package:heaven_book_app/widgets/custom_circle_checkbox.dart';
import 'package:intl/intl.dart';

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

  @override
  void initState() {
    super.initState();
    context.read<PaymentBloc>().add(LoadPaymentMethods());
    context.read<PromotionBloc>().add(LoadPromotions());
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
                    'Chưa tìm thấy địa chỉ giao hàng',
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
                    'Vui lòng thêm địa chỉ giao hàng trong hồ sơ để tiếp tục.',
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
          return Center(child: Text('Failed to load addresses'));
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
                      Text(
                        originalPrice,
                        style: TextStyle(
                          decoration: TextDecoration.lineThrough,
                          decorationColor: Colors.grey,
                          color: Colors.grey,
                          fontSize: 15,
                        ),
                      ),
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
                      price: FormatPrice.formatPrice(
                        item.unitPrice - (item.unitPrice * item.sale / 100),
                      ),
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
                //'Payment Method',
                'Phương thức thanh toán',
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
                      'Xem tất cả tùy chọn',
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
    final addressState = context.read<AddressBloc>().state;

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
                              (addressState is AddressLoaded &&
                                      addressState.addresses.isNotEmpty &&
                                      selectedPaymentId != null)
                                  ? () {
                                    // Validate address
                                    final receiver = addressState.addresses
                                        .firstWhere(
                                          (addr) => addr.isDefault == 1,
                                          orElse:
                                              () => addressState.addresses[0],
                                        );

                                    // Get payment method name
                                    final paymentState =
                                        context.read<PaymentBloc>().state;
                                    String paymentMethodName = 'COD';
                                    if (paymentState is PaymentLoaded) {
                                      final selectedPayment = paymentState
                                          .payments
                                          .firstWhere(
                                            (p) => p.id == selectedPaymentId,
                                            orElse:
                                                () =>
                                                    paymentState.payments.first,
                                          );
                                      paymentMethodName = selectedPayment.name;
                                    }
                                    context.read<OrderBloc>().add(
                                      PlaceOrder(
                                        note: _noteController.text.trim(),
                                        paymentMethod: paymentMethodName,
                                        cartId: state.cart.id,
                                        phone: receiver.phoneNumber,
                                        address: receiver.address,
                                        name: receiver.recipientName,
                                        promotionId: selectedPromotionId,
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
