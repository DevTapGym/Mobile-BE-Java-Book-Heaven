import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:heaven_book_app/bloc/order/order_bloc.dart';
import 'package:heaven_book_app/bloc/order/order_event.dart';
import 'package:heaven_book_app/bloc/order/order_state.dart';
import 'package:heaven_book_app/model/order_item.dart';
import 'package:heaven_book_app/model/status_order.dart';
import 'package:heaven_book_app/themes/app_colors.dart';
import 'package:heaven_book_app/themes/format_price.dart';
import 'package:heaven_book_app/widgets/appbar_custom_widget.dart';

class DetailOrderScreen extends StatefulWidget {
  const DetailOrderScreen({super.key});

  @override
  State<DetailOrderScreen> createState() => _DetailOrderScreenState();
}

class _DetailOrderScreenState extends State<DetailOrderScreen> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _isInitialized = true;

      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

      if (args != null) {
        final orderId = args['orderId'];
        context.read<OrderBloc>().add(LoadDetailOrder(orderId: orderId));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppbarCustomWidget(
        title:
            //'Order Details'
            'Chi tiết đơn hàng',
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.primary, AppColors.background],
            stops: [0.3, 0.3],
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BlocBuilder<OrderBloc, OrderState>(
                  builder: (context, state) {
                    if (state is OrderLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is OrderDetailLoaded) {
                      return Card(
                        color: Colors.white,
                        margin: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(14, 20, 14, 4),
                              child: _statusSection(state.order.statusHistory),
                            ),
                            Container(
                              height: 6,
                              width: double.infinity,
                              color: AppColors.background,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(14.0),
                              child: _shippingAddressSection(),
                            ),
                            Container(
                              height: 6,
                              width: double.infinity,
                              color: AppColors.background,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(14.0),
                              child: _itemsSection(),
                            ),
                            Container(
                              height: 6,
                              width: double.infinity,
                              color: AppColors.background,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(14.0),
                              child: _orderSummarySection(),
                            ),
                            Container(
                              height: 6,
                              width: double.infinity,
                              color: AppColors.background,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(14.0),
                              child: _orderDetailsSection(),
                            ),
                          ],
                        ),
                      );
                    } else if (state is OrderError) {
                      return Center(
                        child: Text(
                          'Error: ${state.message}',
                          style: const TextStyle(color: Colors.red),
                        ),
                      );
                    } else {
                      return const Center(
                        //child: Text('No order details available.'),
                        child: Text('Không có chi tiết đơn hàng.'),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _statusSection(List<StatusOrder> statusHistory) {
    // Sort by sequence (descending) to show latest first
    final sortedHistory = List<StatusOrder>.from(statusHistory)
      ..sort((a, b) => b.sequence.compareTo(a.sequence));

    bool showAll = false;
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              //'Status Order:',
              'Trạng thái đơn hàng:',
              style: TextStyle(
                fontSize: 18,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            // Timeline card
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 18),
              child: Column(
                children: [
                  // show either single latest or full timeline
                  if (!showAll) ...[
                    Row(
                      children: [
                        // dot
                        Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: _getStatusColor(sortedHistory.first.name),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                sortedHistory.first.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _formatDateTime(sortedHistory.first.timestamp),
                                style: TextStyle(color: Colors.black54),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    Column(
                      children:
                          sortedHistory.asMap().entries.map((entry) {
                            final idx = entry.key;
                            final statusOrder = entry.value;
                            final isLast = idx == sortedHistory.length - 1;
                            Color dotColor = _getStatusColor(statusOrder.name);

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: 28,
                                    child: Column(
                                      children: [
                                        Container(
                                          width: 14,
                                          height: 14,
                                          decoration: BoxDecoration(
                                            color: dotColor,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        if (!isLast)
                                          Container(
                                            width: 2,
                                            height: 50,
                                            color: Colors.black54,
                                            margin: const EdgeInsets.only(
                                              top: 6,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          statusOrder.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          _formatDateTime(
                                            statusOrder.timestamp,
                                          ),
                                          style: TextStyle(
                                            color: Colors.black54,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                    ),
                  ],

                  // show more/less button - only show if more than 1 status
                  if (sortedHistory.length > 1) ...[
                    const SizedBox(height: 4),
                    Center(
                      child: TextButton.icon(
                        onPressed: () => setState(() => showAll = !showAll),
                        icon: Icon(
                          showAll ? Icons.expand_less : Icons.expand_more,
                          color: AppColors.primary,
                        ),
                        label: Text(
                          //showAll ? 'Show less' : 'Show more',
                          showAll ? 'Thu gọn' : 'Xem thêm',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  // Helper method to get color based on status name
  Color _getStatusColor(String statusName) {
    final lowerStatus = statusName.toLowerCase();
    if (lowerStatus.contains('completed') ||
        lowerStatus.contains('payment_completed')) {
      return Colors.green;
    } else if (lowerStatus.contains('wait_confirm') ||
        lowerStatus.contains('processing') ||
        lowerStatus.contains('shipping')) {
      return Colors.blue;
    } else if (lowerStatus.contains('returned')) {
      return Colors.orange;
    } else if (lowerStatus.contains('canceled')) {
      return Colors.red;
    } else {
      return Colors.black54;
    }
  }

  // Helper method to format DateTime
  String _formatDateTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final year = dateTime.year;
    return '$hour:$minute $day-$month-$year';
  }

  Widget _shippingAddressSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BlocBuilder<OrderBloc, OrderState>(
          builder: (context, state) {
            if (state is OrderDetailLoaded) {
              final order = state.order;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    //'Shipping address:',
                    'Địa chỉ giao hàng:',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.only(left: 18.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.location_on, color: Colors.blue),
                            const SizedBox(width: 8),
                            Text(
                              //'Home',
                              'Nhà riêng',
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          order.receiverAddress,
                          style: const TextStyle(color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            } else {
              return const SizedBox.shrink();
            }
          },
        ),
      ],
    );
  }

  Widget _itemsSection() {
    return Column(
      children: [
        BlocBuilder<OrderBloc, OrderState>(
          builder: (context, state) {
            if (state is OrderDetailLoaded) {
              final order = state.order;
              return Column(
                children:
                    order.items.map((item) => _buildOrderItem(item)).toList(),
              );
            } else {
              return const SizedBox.shrink();
            }
          },
        ),
      ],
    );
  }

  Widget _orderSummarySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          //'Order summary',
          'Tóm tắt đơn hàng',
          style: TextStyle(
            fontSize: 18,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        BlocBuilder<OrderBloc, OrderState>(
          builder: (context, state) {
            if (state is OrderDetailLoaded) {
              final order = state.order;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSummaryRow(
                    //'Subtotal',
                    'Tạm tính',
                    FormatPrice.formatPrice(
                      (order.totalAmount) + (order.totalPromotionValue ?? 0),
                    ),
                  ),
                  _buildSummaryRow(
                    //'Shipping',
                    'Phí vận chuyển',
                    FormatPrice.formatPrice(order.shippingFee),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 12),
                    child: Text(
                      //'Discounts:',
                      'Giảm giá:',
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 12),
                    child: _buildSummaryRow(
                      //'- Shipping Voucher',
                      '- Giảm phí vận chuyển',
                      '-0 đ',
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 12),
                    child: _buildSummaryRow(
                      //'- Member Discount',
                      '- Mã giảm giá',
                      '-0 đ',
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 12),
                    child: _buildSummaryRow(
                      //'- Product Voucher',
                      '- Giảm giá sản phẩm',
                      '-${FormatPrice.formatPrice(order.totalPromotionValue ?? 0)}',
                    ),
                  ),
                  const Divider(),
                  _buildSummaryRow(
                    //'Total',
                    'Tổng cộng',
                    FormatPrice.formatPrice(
                      order.totalAmount + order.shippingFee,
                    ),
                    isBold: true,
                  ),
                ],
              );
            } else {
              return const SizedBox.shrink();
            }
          },
        ),
      ],
    );
  }

  Widget _orderDetailsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          //'Order details',
          'Chi tiết đơn hàng',
          style: TextStyle(
            fontSize: 18,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        BlocBuilder<OrderBloc, OrderState>(
          builder: (context, state) {
            if (state is OrderDetailLoaded) {
              final order = state.order;
              return Column(
                children: [
                  _buildDetailRow(
                    //'Order Number:',
                    'Mã đơn hàng:',
                    order.orderNumber,
                  ),
                  _buildDetailRow(
                    //'Order Date:',
                    'Ngày đặt hàng:',
                    '${order.orderDate.hour}:${order.orderDate.minute} ${order.orderDate.day}-${order.orderDate.month}-${order.orderDate.year}',
                  ),
                  _buildDetailRow(
                    //'Payment Method:',
                    'Phương thức thanh toán:',
                    order.paymentMethod,
                  ),
                  _buildDetailRow(
                    //'Receiver Name:',
                    'Tên người nhận:',
                    order.receiverName,
                  ),
                  _buildDetailRow(
                    //'Receiver Phone:',
                    'Số điện thoại người nhận:',
                    order.receiverPhone,
                  ),
                  _buildDetailRow(
                    //'Receiver Address:',
                    'Địa chỉ người nhận:',
                    order.receiverAddress,
                  ),
                  _buildDetailRow(
                    //'Note:',
                    'Ghi chú:',
                    order.note,
                  ),
                ],
              );
            } else {
              return const SizedBox.shrink();
            }
          },
        ),

        // Center(
        //   child: TextButton(
        //     onPressed: () {},
        //     child: Row(
        //       mainAxisSize: MainAxisSize.min,
        //       children: const [
        //         Text(
        //           'Export Receipt',
        //           style: TextStyle(color: AppColors.primaryDark),
        //         ),
        //         SizedBox(width: 8),
        //         Icon(Icons.arrow_forward_ios, color: AppColors.primaryDark),
        //       ],
        //     ),
        //   ),
        // ),
      ],
    );
  }

  Widget _buildOrderItem(OrderItem item) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 80,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 6,
                    spreadRadius: 2,
                    offset: const Offset(2, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  'http://10.0.2.2:8000${item.bookThumbnail}',
                  fit: BoxFit.cover,
                  errorBuilder:
                      (context, error, stackTrace) =>
                          Icon(Icons.broken_image, color: Colors.grey[200]),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: SizedBox(
                height: 120,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.bookTitle,
                          maxLines: 2,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          item.bookAuthor,
                          style: TextStyle(color: Colors.black54),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          '${FormatPrice.formatPrice(item.unitPrice)} x ${item.quantity}',
                        ),
                        const Spacer(),
                        Text(
                          FormatPrice.formatPrice(item.totalPrice),
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppColors.primaryDark,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isBold ? AppColors.primaryDark : Colors.black54,
              fontSize: 15,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isBold ? AppColors.primaryDark : Colors.black54,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              softWrap: true,
              label,
              style: const TextStyle(color: Colors.black54, fontSize: 15),
            ),
          ),
          SizedBox(
            width: 180,
            child: Text(
              value,
              textAlign: TextAlign.right,
              softWrap: true,
              overflow: TextOverflow.visible,
              style: const TextStyle(color: Colors.black54, fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Add to cart button
            // Expanded(
            //   flex: 2,
            //   child: ElevatedButton.icon(
            //     onPressed: () {},
            //     label: Text(
            //       //'Review',
            //       'Đánh giá',
            //       style: TextStyle(
            //         color: Colors.white,
            //         fontWeight: FontWeight.bold,
            //         fontSize: 16,
            //         shadows: [
            //           Shadow(
            //             color: Colors.black.withValues(alpha: 0.2),
            //             offset: const Offset(0, 2),
            //             blurRadius: 4,
            //           ),
            //         ],
            //       ),
            //     ),
            //     style: ElevatedButton.styleFrom(
            //       backgroundColor: AppColors.primary,
            //       padding: const EdgeInsets.symmetric(vertical: 16),
            //       shape: RoundedRectangleBorder(
            //         borderRadius: BorderRadius.circular(12),
            //       ),
            //     ),
            //   ),
            // ),

            // const SizedBox(width: 12),

            // Buy now button
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryDark,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  //'Buy Again',
                  'Mua lại',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    shadows: [
                      Shadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        offset: const Offset(0, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
