import 'package:flutter/material.dart';
import 'package:heaven_book_app/interceptors/app_session.dart';
import 'package:heaven_book_app/model/checkout.dart';
import 'package:heaven_book_app/model/order.dart';
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
  Order? _order;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_order == null) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

      if (args != null && args['order'] != null) {
        _order = args['order'] as Order;
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
                if (_order == null)
                  const Center(
                    child: Text(
                      'Không có chi tiết đơn hàng.',
                      style: TextStyle(fontSize: 16, color: Colors.red),
                    ),
                  )
                else
                  Card(
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
                          child: _statusSection(_order!.statusHistory),
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
                  ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  // Chuyển đổi trạng thái từ tiếng Anh sang tiếng Việt
  String _getVietnameseStatus(String status) {
    switch (status.toLowerCase()) {
      case 'wait_confirm':
        return 'Chờ xác nhận';
      case 'processing':
        return 'Đang xử lý';
      case 'shipping':
        return 'Đang giao';
      case 'payment_completed':
        return 'Đã thanh toán';
      case 'completed':
        return 'Hoàn thành';
      case 'canceled':
        return 'Đã hủy';
      case 'returned':
        return 'Đã trả hàng';
      default:
        return status.replaceAll('_', ' ');
    }
  }

  Widget _statusSection(List<StatusOrder> statusHistory) {
    // Sort by timestamp (descending) to show newest first
    final sortedHistory = List<StatusOrder>.from(statusHistory)
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

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
                                _getVietnameseStatus(sortedHistory.first.name),
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
                                          _getVietnameseStatus(
                                            statusOrder.name,
                                          ),
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
    if (_order == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Thông tin giao hàng',
          style: TextStyle(
            fontSize: 18,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),

        // Container với padding và background đẹp hơn
        Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Tên người nhận
              _buildInfoRow(
                icon: Icons.person_outline,
                label: 'Người nhận',
                value: _order!.receiverName,
              ),

              const SizedBox(height: 16),

              // Số điện thoại
              _buildInfoRow(
                icon: Icons.phone_outlined,
                label: 'Số điện thoại',
                value: _order!.receiverPhone,
              ),

              const SizedBox(height: 16),

              // Địa chỉ
              _buildInfoRow(
                icon: Icons.location_on_outlined,
                label: 'Địa chỉ giao hàng',
                value: _order!.receiverAddress,
                isMultiline: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Helper method để tạo info row thống nhất
  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    bool isMultiline = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _itemsSection() {
    if (_order == null) return const SizedBox.shrink();

    return Column(
      children: _order!.items.map((item) => _buildOrderItem(item)).toList(),
    );
  }

  Widget _orderSummarySection() {
    if (_order == null) return const SizedBox.shrink();

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
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryRow(
              //'Subtotal',
              'Tạm tính',
              FormatPrice.formatPrice(
                (_order!.totalAmount) + (_order!.totalPromotionValue ?? 0),
              ),
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
                '-${FormatPrice.formatPrice(_order!.totalPromotionValue ?? 0)}',
              ),
            ),
            const Divider(),
            _buildSummaryRow(
              //'Total',
              'Tổng cộng',
              FormatPrice.formatPrice(
                _order!.totalAmount + _order!.shippingFee,
              ),
              isBold: true,
            ),
          ],
        ),
      ],
    );
  }

  Widget _orderDetailsSection() {
    if (_order == null) return const SizedBox.shrink();

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
        Column(
          children: [
            _buildDetailRow(
              //'Order Number:',
              'Mã đơn hàng:',
              _order!.orderNumber,
            ),
            _buildDetailRow(
              //'Order Date:',
              'Ngày đặt hàng:',
              '${_order!.orderDate.hour}:${_order!.orderDate.minute} ${_order!.orderDate.day}-${_order!.orderDate.month}-${_order!.orderDate.year}',
            ),
            _buildDetailRow(
              //'Payment Method:',
              'Phương thức thanh toán:',
              _order!.paymentMethod,
            ),
            _buildDetailRow(
              //'Receiver Name:',
              'Tên người nhận:',
              _order!.receiverName,
            ),
            _buildDetailRow(
              //'Receiver Phone:',
              'Số điện thoại người nhận:',
              _order!.receiverPhone,
            ),
            _buildDetailRow(
              //'Receiver Address:',
              'Địa chỉ người nhận:',
              _order!.receiverAddress,
            ),
            _buildDetailRow(
              //'Note:',
              'Ghi chú:',
              _order!.note,
            ),
          ],
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
                  '${AppSession.baseUrlImg}${item.bookThumbnail}',
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
                onPressed: () {
                  if (_order != null) {
                    // Chuyển đổi OrderItem sang Checkout
                    List<Checkout> checkoutItems =
                        _order!.items.map((item) {
                          return Checkout(
                            bookId: item.bookId,
                            bookTitle: item.bookTitle,
                            bookThumbnail: item.bookThumbnail,
                            unitPrice: item.unitPrice,
                            quantity: item.quantity,
                            saleOff:
                                0.0, // Có thể tính từ unitPrice và totalPrice nếu cần
                          );
                        }).toList();

                    // Điều hướng đến màn buy_now với dữ liệu
                    Navigator.pushNamed(
                      context,
                      '/buy-now',
                      arguments: {'items': checkoutItems},
                    );
                  }
                },
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
