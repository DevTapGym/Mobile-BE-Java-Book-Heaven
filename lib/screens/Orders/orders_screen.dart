import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:heaven_book_app/bloc/order/order_bloc.dart';
import 'package:heaven_book_app/bloc/order/order_event.dart';
import 'package:heaven_book_app/bloc/order/order_state.dart';
import 'package:heaven_book_app/model/checkout.dart';
import 'package:heaven_book_app/model/order.dart';
import 'package:heaven_book_app/model/order_item.dart';
import 'package:heaven_book_app/model/return_order.dart';
import 'package:heaven_book_app/model/return_order_item.dart';
import 'package:heaven_book_app/themes/format_price.dart';
import '../../themes/app_colors.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Track which orders have expanded items view
  Set<String> expandedOrders = {};

  // Date range filter variables
  DateTimeRange? _selectedDateRange;
  List<Order> _filteredOrders = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 8, vsync: this);
    _filteredOrders = [];

    // Load orders when screen initializes
    context.read<OrderBloc>().add(LoadAllOrders());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Order> getOrdersByStatus(String status) {
    return _filteredOrders.where((order) {
      if (order.statusHistory.isEmpty) return false;
      // Lấy trạng thái mới nhất
      final latestStatus = order.statusHistory.last.name.toLowerCase();
      return latestStatus == status.toLowerCase();
    }).toList();
  }

  List<Order> _getOrdersForTab(String tab) {
    switch (tab) {
      case 'WaitConfirm':
        return getOrdersByStatus('wait_confirm');
      case 'Processing':
        return getOrdersByStatus('processing');
      case 'Shipping':
        return getOrdersByStatus('shipping');
      case 'PaymentCompleted':
        return getOrdersByStatus('payment_completed');
      case 'Canceled':
        return getOrdersByStatus('canceled');
      case 'Returned':
        return getOrdersByStatus('returned');
      case 'Completed':
        return getOrdersByStatus('completed');
      default:
        return _filteredOrders;
    }
  }

  void _showDateRangeFilter() async {
    DateTime? tempStartDate = _selectedDateRange?.start;
    DateTime? tempEndDate = _selectedDateRange?.end;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                width: 450,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Row(
                      children: [
                        Icon(
                          Icons.date_range,
                          color: AppColors.primary,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          //'Filter Orders by Date Range',
                          'Chọn khoảng ngày',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Date selection buttons
                    Row(
                      children: [
                        // Start Date Button
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              final DateTime? picked = await showDatePicker(
                                context: context,
                                initialDate: tempStartDate ?? DateTime.now(),
                                firstDate: DateTime(2020),
                                lastDate: tempEndDate ?? DateTime.now(),
                                //helpText: 'Select Start Date',
                                helpText: 'Chọn ngày bắt đầu',
                                builder: (context, child) {
                                  return Theme(
                                    data: Theme.of(context).copyWith(
                                      colorScheme: ColorScheme.light(
                                        primary: AppColors.primary,
                                        onPrimary: Colors.white,
                                        surface: Colors.white,
                                        onSurface: Colors.black87,
                                      ),
                                    ),
                                    child: child!,
                                  );
                                },
                              );
                              if (picked != null) {
                                setDialogState(() {
                                  tempStartDate = picked;
                                  // If end date is before start date, reset it
                                  if (tempEndDate != null &&
                                      tempEndDate!.isBefore(picked)) {
                                    tempEndDate = null;
                                  }
                                });
                              }
                            },
                            icon: Icon(
                              Icons.calendar_today,
                              color:
                                  tempStartDate != null
                                      ? AppColors.primary
                                      : Colors.grey[600],
                              size: 18,
                            ),
                            label: Text(
                              tempStartDate != null
                                  ? '${tempStartDate!.day}/${tempStartDate!.month}/${tempStartDate!.year}'
                                  : //'Start Date',
                                  'Ngày bắt đầu',
                              style: TextStyle(
                                color:
                                    tempStartDate != null
                                        ? AppColors.primary
                                        : Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color:
                                    tempStartDate != null
                                        ? AppColors.primary
                                        : Colors.grey[400]!,
                                width: 1.5,
                              ),
                              backgroundColor:
                                  tempStartDate != null
                                      ? AppColors.primary.withValues(
                                        alpha: 0.05,
                                      )
                                      : null,
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 12),

                        // To text
                        Text(
                          //'to',
                          'đến',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                        const SizedBox(width: 12),

                        // End Date Button
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed:
                                tempStartDate != null
                                    ? () async {
                                      final DateTime?
                                      picked = await showDatePicker(
                                        context: context,
                                        initialDate:
                                            tempEndDate ?? tempStartDate!,
                                        firstDate: tempStartDate!,
                                        lastDate: DateTime.now(),
                                        helpText: //'Select End Date',
                                            'Chọn ngày kết thúc',
                                        builder: (context, child) {
                                          return Theme(
                                            data: Theme.of(context).copyWith(
                                              colorScheme: ColorScheme.light(
                                                primary: AppColors.primary,
                                                onPrimary: Colors.white,
                                                surface: Colors.white,
                                                onSurface: Colors.black87,
                                              ),
                                            ),
                                            child: child!,
                                          );
                                        },
                                      );
                                      if (picked != null) {
                                        setDialogState(() {
                                          tempEndDate = picked;
                                        });
                                      }
                                    }
                                    : null,
                            icon: Icon(
                              Icons.calendar_today,
                              color:
                                  tempEndDate != null
                                      ? AppColors.primary
                                      : Colors.grey[400],
                              size: 18,
                            ),
                            label: Text(
                              tempEndDate != null
                                  ? '${tempEndDate!.day}/${tempEndDate!.month}/${tempEndDate!.year}'
                                  : //'End Date',
                                  'Ngày kết thúc',
                              style: TextStyle(
                                color:
                                    tempEndDate != null
                                        ? AppColors.primary
                                        : Colors.grey[400],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color:
                                    tempEndDate != null
                                        ? AppColors.primary
                                        : Colors.grey[400]!,
                                width: 1.5,
                              ),
                              backgroundColor:
                                  tempEndDate != null
                                      ? AppColors.primary.withValues(
                                        alpha: 0.05,
                                      )
                                      : null,
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Current selection display
                    if (tempStartDate != null && tempEndDate != null)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.event,
                                  color: AppColors.primary,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  //'Selected Date Range:',
                                  'Khoảng ngày đã chọn:',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '${tempStartDate!.day}/${tempStartDate!.month}/${tempStartDate!.year}',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  //'  to  ',
                                  '  đến  ',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                Text(
                                  '${tempEndDate!.day}/${tempEndDate!.month}/${tempEndDate!.year}',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 24),

                    // Action Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        // Cancel Button
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text(
                            //'Cancel',
                            'Hủy',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),

                        const SizedBox(width: 12),

                        // Apply Button
                        ElevatedButton(
                          onPressed:
                              (tempStartDate != null && tempEndDate != null)
                                  ? () {
                                    setState(() {
                                      _selectedDateRange = DateTimeRange(
                                        start: tempStartDate!,
                                        end: tempEndDate!,
                                      );
                                      _filterOrdersByDateRange();
                                    });
                                    Navigator.pop(context);
                                  }
                                  : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: Colors.grey[300],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                          ),
                          child: const Text(
                            //'Apply Filter',
                            'Áp dụng',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _filterOrdersByDateRange() {
    final startDate = DateTime(
      _selectedDateRange!.start.year,
      _selectedDateRange!.start.month,
      _selectedDateRange!.start.day,
    );
    final endDate = DateTime(
      _selectedDateRange!.end.year,
      _selectedDateRange!.end.month,
      _selectedDateRange!.end.day,
      23,
      59,
      59,
      999,
    );

    setState(() {
      _filteredOrders =
          _filteredOrders.where((order) {
            final orderDate = DateTime(
              order.orderDate.year,
              order.orderDate.month,
              order.orderDate.day,
            );
            return (orderDate.isAtSameMomentAs(startDate) ||
                orderDate.isAtSameMomentAs(endDate) ||
                (orderDate.isAfter(startDate) && orderDate.isBefore(endDate)));
          }).toList();
    });

    debugPrint('✅ Date filter applied successfully');
  }

  List<Order> _applyDateFilter(List<Order> orders) {
    if (_selectedDateRange == null) {
      debugPrint('📋 No date filter - returning all ${orders.length} orders');
      return orders;
    }

    // Normalize dates to start and end of day for accurate comparison
    final startDate = DateTime(
      _selectedDateRange!.start.year,
      _selectedDateRange!.start.month,
      _selectedDateRange!.start.day,
    );

    final endDate = DateTime(
      _selectedDateRange!.end.year,
      _selectedDateRange!.end.month,
      _selectedDateRange!.end.day,
      23,
      59,
      59,
      999, // End of day
    );

    debugPrint('📅 Applying date filter:');
    debugPrint('  🟢 Start: ${startDate.toString().split(' ')[0]}');
    debugPrint('  🔴 End: ${endDate.toString().split(' ')[0]}');
    debugPrint('  📊 Total orders to filter: ${orders.length}');

    final filteredOrders =
        orders.where((order) {
          // Normalize order date to start of day for comparison
          final orderDateOnly = DateTime(
            order.orderDate.year,
            order.orderDate.month,
            order.orderDate.day,
          );

          final isInRange =
              orderDateOnly.isAtSameMomentAs(startDate) ||
              orderDateOnly.isAtSameMomentAs(endDate) ||
              (orderDateOnly.isAfter(startDate) &&
                  orderDateOnly.isBefore(endDate));

          if (isInRange) {
            debugPrint(
              '  ✅ Order ${order.orderNumber} - ${orderDateOnly.toString().split(' ')[0]} (included)',
            );
          } else {
            debugPrint(
              '  ❌ Order ${order.orderNumber} - ${orderDateOnly.toString().split(' ')[0]} (excluded)',
            );
          }

          return isInRange;
        }).toList();

    debugPrint(
      '📈 Filter result: ${filteredOrders.length}/${orders.length} orders match criteria',
    );
    return filteredOrders;
  }

  void _clearDateFilter() {
    debugPrint('🗑️ Clearing date filter...');
    setState(() {
      _selectedDateRange = null;
    });
    debugPrint('✅ Date filter cleared - showing all orders');
  }

  void _showCancelOrderBottomSheet(Order order) {
    String? selectedReason;
    String customReason = '';
    final TextEditingController reasonController = TextEditingController();

    final List<String> cancelReasons = [
      'Không còn nhu cầu mua',
      'Phí ship cao hoặc tổng tiền vượt dự tính',
      'Tìm thấy sản phẩm giá tốt hơn',
      'Đặt nhầm sản phẩm',
      'Khác (nhập lý do)',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header with close button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Lý do hủy đơn hàng',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: Icon(Icons.close, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Đơn hàng: ${order.orderNumber}',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 20),

                      // Cancel reasons list
                      ...cancelReasons.map((reason) {
                        final isSelected = selectedReason == reason;
                        final isCustomReason = reason.startsWith('Khác');

                        return Column(
                          children: [
                            InkWell(
                              onTap: () {
                                setModalState(() {
                                  selectedReason = reason;
                                  if (!isCustomReason) {
                                    reasonController.clear();
                                    customReason = '';
                                  }
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                  horizontal: 16,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      isSelected
                                          ? AppColors.primary.withValues(
                                            alpha: 0.1,
                                          )
                                          : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color:
                                        isSelected
                                            ? AppColors.primary
                                            : Colors.grey[300]!,
                                    width: isSelected ? 2 : 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      isSelected
                                          ? Icons.radio_button_checked
                                          : Icons.radio_button_unchecked,
                                      color:
                                          isSelected
                                              ? AppColors.primary
                                              : Colors.grey[400],
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        reason,
                                        style: TextStyle(
                                          fontSize: 16,
                                          color:
                                              isSelected
                                                  ? AppColors.primary
                                                  : Colors.black87,
                                          fontWeight:
                                              isSelected
                                                  ? FontWeight.w600
                                                  : FontWeight.normal,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // Custom reason input
                            if (isSelected && isCustomReason)
                              Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: TextField(
                                  controller: reasonController,
                                  onChanged: (value) {
                                    customReason = value;
                                  },
                                  maxLines: 3,
                                  decoration: InputDecoration(
                                    hintText: 'Nhập lý do hủy của bạn...',
                                    hintStyle: TextStyle(
                                      color: Colors.grey[400],
                                    ),
                                    border: OutlineInputBorder(
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
                                    contentPadding: const EdgeInsets.all(16),
                                  ),
                                ),
                              ),
                            const SizedBox(height: 12),
                          ],
                        );
                      }),

                      const SizedBox(height: 20),

                      // Cancel order button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed:
                              selectedReason != null &&
                                      (selectedReason!.startsWith('Khác')
                                          ? customReason.trim().isNotEmpty
                                          : true)
                                  ? () {
                                    Navigator.pop(context);
                                    _showConfirmCancelDialog(
                                      order,
                                      selectedReason!.startsWith('Khác')
                                          ? customReason
                                          : selectedReason!,
                                    );
                                  }
                                  : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            disabledBackgroundColor: Colors.grey[300],
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            'Hủy đơn hàng',
                            style: TextStyle(
                              color:
                                  selectedReason != null &&
                                          (selectedReason!.startsWith('Khác')
                                              ? customReason.trim().isNotEmpty
                                              : true)
                                      ? Colors.white
                                      : Colors.grey[600],
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showConfirmCancelDialog(Order order, String reason) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
              const SizedBox(width: 8),
              Text(
                'Xác nhận hủy đơn',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bạn có chắc chắn muốn hủy đơn hàng?',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Đơn hàng: ${order.orderNumber}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Lý do: $reason',
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Hành động này không thể hoàn tác!',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.red,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Không',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // Gọi sự kiện UpdateOrderStatus với statusId = 5
                context.read<OrderBloc>().add(
                  UpdateOrderStatus(
                    orderId: order.id,
                    statusId: 5,
                    note: reason,
                  ),
                );
                // Hiển thị thông báo
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Đang hủy đơn hàng...'),
                    backgroundColor: AppColors.primary,
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              child: Text(
                'Đồng ý hủy',
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

  void _showConfirmReturnDialog(
    Order order,
    Map<int, int> selectedItemsWithQty,
  ) {
    // Lấy danh sách các sản phẩm được chọn từ order
    List<OrderItem> selectedProducts =
        order.items
            .where((item) => selectedItemsWithQty.containsKey(item.bookId))
            .toList();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                Icons.assignment_return,
                color: AppColors.primaryDark,
                size: 28,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Xác nhận trả hàng',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bạn có chắc chắn muốn trả các sản phẩm sau?',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),

                // Thông tin đơn hàng
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.receipt_long,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Đơn hàng: ${order.orderNumber}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.event, size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 8),
                          Text(
                            'Ngày đặt: ${order.orderDate.day}/${order.orderDate.month}/${order.orderDate.year}',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Danh sách sản phẩm trả
                Text(
                  'Sản phẩm trả hàng:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 12),

                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppColors.primaryDark.withValues(alpha: 0.2),
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children:
                        selectedProducts.map((item) {
                          final returnQty =
                              selectedItemsWithQty[item.bookId] ?? 0;
                          final isLast = item == selectedProducts.last;

                          return Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  children: [
                                    // Product image
                                    Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        color: AppColors.card,
                                        borderRadius: BorderRadius.circular(8),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(
                                              alpha: 0.1,
                                            ),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child:
                                            item.bookThumbnail.isNotEmpty
                                                ? Image.network(
                                                  item.bookThumbnail,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (
                                                    context,
                                                    error,
                                                    stack,
                                                  ) {
                                                    return Icon(
                                                      Icons.book,
                                                      color: AppColors.primary,
                                                      size: 24,
                                                    );
                                                  },
                                                )
                                                : Icon(
                                                  Icons.book,
                                                  color: AppColors.primary,
                                                  size: 24,
                                                ),
                                      ),
                                    ),

                                    const SizedBox(width: 12),

                                    // Product info
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.bookTitle,
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black87,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: AppColors.primaryDark
                                                      .withValues(alpha: 0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                ),
                                                child: Text(
                                                  'x$returnQty',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                    color:
                                                        AppColors.primaryDark,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                FormatPrice.formatPrice(
                                                  item.unitPrice,
                                                ),
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey[700],
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (!isLast)
                                Divider(
                                  height: 1,
                                  thickness: 1,
                                  color: Colors.grey[200],
                                ),
                            ],
                          );
                        }).toList(),
                  ),
                ),

                const SizedBox(height: 16),

                // Warning message
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.orange.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.orange[800],
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Khi trả hàng bạn phải trả phí trả hàng theo quy định của cửa hàng. Phí trả hàng: 30.000 đ',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.orange[900],
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Hủy',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);

                // Tạo danh sách ReturnOrderItem từ selectedItemsWithQty
                List<ReturnOrderItem> returnOrderItems =
                    selectedItemsWithQty.entries.map((entry) {
                      // Tìm orderItem tương ứng trong order.items
                      final orderItem = order.items.firstWhere(
                        (item) => item.bookId == entry.key,
                      );

                      return ReturnOrderItem(
                        bookId: entry.key,
                        quantity: entry.value,
                        orderItemId: orderItem.id,
                      );
                    }).toList();

                // Tạo ReturnOrder object
                final returnOrder = ReturnOrder(
                  id: order.id,
                  receiverName: order.receiverName,
                  receiverAddress: order.receiverAddress,
                  receiverPhone: order.receiverPhone,
                  email: order.email,
                  paymentMethod: order.paymentMethod,
                  customerId: order.customerId,
                  totalPrice: order.totalAmount,
                  orderType: 'RETURN',
                  promotionId: null,
                  totalPromotionValue: null,
                  statusId: 1, // Trạng thái khởi tạo cho đơn trả hàng
                  returnFee: 30000.0, // Phí trả hàng cố định
                  returnFeeType: 'value',
                  orderItems: returnOrderItems,
                );

                // Gọi event CreateReturnOrder
                context.read<OrderBloc>().add(
                  CreateReturnOrder(
                    returnOrder: returnOrder,
                    customerId: order.customerId ?? 0,
                  ),
                );

                // Hiển thị thông báo
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: Text('Đang gửi yêu cầu trả hàng...')),
                      ],
                    ),
                    backgroundColor: AppColors.primaryDark,
                    duration: Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryDark,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              child: Text(
                'Xác nhận trả hàng',
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

  void _showReturnOrderDialog(Order order) {
    // Map để lưu số lượng trả của từng sản phẩm
    Map<int, int> returnQuantities = {};
    Map<int, bool> selectedItems = {};

    // Khởi tạo giá trị mặc định
    for (var item in order.items) {
      selectedItems[item.bookId] = false;
      returnQuantities[item.bookId] = 0;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            // Tính tổng số sản phẩm được chọn
            int totalSelectedItems =
                selectedItems.values.where((v) => v).length;

            return Container(
              height: MediaQuery.of(context).size.height * 0.85,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.assignment_return,
                                  color: AppColors.primaryDark,
                                  size: 24,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Chọn sản phẩm trả hàng',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: Icon(Icons.close, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Đơn hàng: ${order.orderNumber}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        if (totalSelectedItems > 0)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primaryDark.withValues(
                                  alpha: 0.1,
                                ),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: AppColors.primaryDark.withValues(
                                    alpha: 0.3,
                                  ),
                                ),
                              ),
                              child: Text(
                                'Đã chọn: $totalSelectedItems sản phẩm',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.primaryDark.withValues(
                                    alpha: 0.8,
                                  ),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Product list
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: order.items.length,
                      itemBuilder: (context, index) {
                        final item = order.items[index];
                        final isSelected = selectedItems[item.bookId] ?? false;
                        final returnQty = returnQuantities[item.bookId] ?? 0;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color:
                                isSelected
                                    ? AppColors.primaryDark.withValues(
                                      alpha: 0.05,
                                    )
                                    : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color:
                                  isSelected
                                      ? AppColors.primaryDark
                                      : Colors.grey[300]!,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    // Checkbox
                                    Checkbox(
                                      value: isSelected,
                                      onChanged: (value) {
                                        setModalState(() {
                                          selectedItems[item.bookId] = value!;
                                          if (!value) {
                                            returnQuantities[item.bookId] = 0;
                                          } else {
                                            returnQuantities[item.bookId] = 1;
                                          }
                                        });
                                      },
                                      activeColor: AppColors.primaryDark,
                                    ),

                                    // Product image
                                    Container(
                                      width: 60,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        color: AppColors.card,
                                        borderRadius: BorderRadius.circular(8),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(
                                              alpha: 0.1,
                                            ),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child:
                                            item.bookThumbnail.isNotEmpty
                                                ? Image.network(
                                                  item.bookThumbnail,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (
                                                    context,
                                                    error,
                                                    stack,
                                                  ) {
                                                    return Icon(
                                                      Icons.book,
                                                      color: AppColors.primary,
                                                    );
                                                  },
                                                )
                                                : Icon(
                                                  Icons.book,
                                                  color: AppColors.primary,
                                                ),
                                      ),
                                    ),

                                    const SizedBox(width: 12),

                                    // Product info
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.bookTitle,
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black87,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            FormatPrice.formatPrice(
                                              item.unitPrice,
                                            ),
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: AppColors.primary,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Đã mua: ${item.quantity} sản phẩm',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),

                                // Quantity selector (only show if selected)
                                if (isSelected)
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      top: 12,
                                      left: 48,
                                    ),
                                    child: Row(
                                      children: [
                                        Text(
                                          'Số lượng trả:',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Container(
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: AppColors.primaryDark,
                                              width: 1.5,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              // Decrease button
                                              InkWell(
                                                onTap: () {
                                                  if (returnQty > 1) {
                                                    setModalState(() {
                                                      returnQuantities[item
                                                              .bookId] =
                                                          returnQty - 1;
                                                    });
                                                  }
                                                },
                                                child: Container(
                                                  padding: const EdgeInsets.all(
                                                    8,
                                                  ),
                                                  child: Icon(
                                                    Icons.remove,
                                                    size: 18,
                                                    color:
                                                        returnQty > 1
                                                            ? AppColors
                                                                .primaryDark
                                                            : Colors.grey[400],
                                                  ),
                                                ),
                                              ),

                                              // Quantity display
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 16,
                                                    ),
                                                child: Text(
                                                  '$returnQty',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600,
                                                    color: AppColors.primaryDark
                                                        .withValues(alpha: 0.9),
                                                  ),
                                                ),
                                              ),

                                              // Increase button
                                              InkWell(
                                                onTap: () {
                                                  if (returnQty <
                                                      item.quantity) {
                                                    setModalState(() {
                                                      returnQuantities[item
                                                              .bookId] =
                                                          returnQty + 1;
                                                    });
                                                  }
                                                },
                                                child: Container(
                                                  padding: const EdgeInsets.all(
                                                    8,
                                                  ),
                                                  child: Icon(
                                                    Icons.add,
                                                    size: 18,
                                                    color:
                                                        returnQty <
                                                                item.quantity
                                                            ? AppColors
                                                                .primaryDark
                                                            : Colors.grey[400],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          '/ ${item.quantity}',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Bottom button
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 4,
                          offset: Offset(0, -2),
                        ),
                      ],
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed:
                            totalSelectedItems > 0
                                ? () {
                                  // Lọc ra các sản phẩm được chọn và số lượng
                                  Map<int, int> selectedItemsWithQty = {};
                                  selectedItems.forEach((bookId, isSelected) {
                                    if (isSelected) {
                                      selectedItemsWithQty[bookId] =
                                          returnQuantities[bookId] ?? 1;
                                    }
                                  });

                                  Navigator.pop(context);

                                  // Hiển thị dialog xác nhận trả hàng
                                  _showConfirmReturnDialog(
                                    order,
                                    selectedItemsWithQty,
                                  );
                                }
                                : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryDark,
                          disabledBackgroundColor: Colors.grey[300],
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          totalSelectedItems > 0
                              ? 'Tiếp tục ($totalSelectedItems sản phẩm)'
                              : 'Chọn sản phẩm cần trả',
                          style: TextStyle(
                            color:
                                totalSelectedItems > 0
                                    ? Colors.white
                                    : Colors.grey[600],
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDateFilterChip() {
    if (_selectedDateRange == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Chip(
        backgroundColor: AppColors.primary.withValues(alpha: 0.1),
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.date_range, size: 16, color: AppColors.primary),
            const SizedBox(width: 4),
            Text(
              '${_selectedDateRange!.start.day}/${_selectedDateRange!.start.month}/${_selectedDateRange!.start.year} - ${_selectedDateRange!.end.day}/${_selectedDateRange!.end.month}/${_selectedDateRange!.end.year}',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        deleteIcon: Icon(Icons.close, size: 16, color: AppColors.primary),
        onDeleted: _clearDateFilter,
        side: BorderSide(
          color: AppColors.primary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text(
          //'My Orders',
          'Đơn hàng của tôi',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: Colors.white,
            fontSize: 24,
            shadows: [
              Shadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _showDateRangeFilter,
            icon: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(8),
              child: const Icon(
                Icons.date_range,
                color: Colors.white,
                size: 20,
              ),
            ),
            //tooltip: 'Filter by date range',
            tooltip: 'Lọc theo khoảng ngày',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: BlocListener<OrderBloc, OrderState>(
        listener: (context, state) {
          if (state is OrderError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 3),
              ),
            );
          } else if (state is OrderLoaded && state.message != null) {
            // Hiển thị thông báo thành công khi có message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message!),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
            // Reload lại danh sách đơn hàng
            Future.delayed(Duration(milliseconds: 500), () {
              // ignore: use_build_context_synchronously
              context.read<OrderBloc>().add(LoadAllOrders());
            });
          }
        },
        child: BlocBuilder<OrderBloc, OrderState>(
          builder: (context, state) {
            if (state is OrderLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is OrderError) {
              return Center(
                child: Text(
                  //'Error loading orders: ${state.message}',
                  'Lỗi khi tải đơn hàng: ${state.message}',
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }

            if (state is OrderLoaded) {
              _filteredOrders =
                  _selectedDateRange != null
                      ? _applyDateFilter(state.orders)
                      : state.orders;
            }

            return Container(
              color: AppColors.background,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Material(
                    color: AppColors.primary,
                    child: TabBar(
                      controller: _tabController,
                      indicatorColor: AppColors.background,
                      labelColor: AppColors.background,
                      unselectedLabelColor: Colors.white60,
                      isScrollable: true,
                      tabs: [
                        const Tab(
                          child: Text(
                            //'All',
                            'Tất cả',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                        const Tab(
                          child: Text(
                            //'Wait confirm',
                            'Chờ xác nhận',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                        const Tab(
                          child: Text(
                            //'Processing',
                            'Đang xử lý',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                        const Tab(
                          child: Text(
                            //'Shipping',
                            'Đang giao',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                        const Tab(
                          child: Text(
                            //'Payment Completed',
                            'Đã thanh toán',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                        const Tab(
                          child: Text(
                            //'Canceled',
                            'Đã hủy',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                        const Tab(
                          child: Text(
                            //'Returned',
                            'Đã trả hàng',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                        const Tab(
                          child: Text(
                            //'Completed',
                            'Hoàn thành',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Date filter chip
                  _buildDateFilterChip(),

                  // Tab bar view
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildOrderList(_getOrdersForTab('All')),
                        _buildOrderList(_getOrdersForTab('WaitConfirm')),
                        _buildOrderList(_getOrdersForTab('Processing')),
                        _buildOrderList(_getOrdersForTab('Shipping')),
                        _buildOrderList(_getOrdersForTab('PaymentCompleted')),
                        _buildOrderList(_getOrdersForTab('Canceled')),
                        _buildOrderList(_getOrdersForTab('Returned')),
                        _buildOrderList(_getOrdersForTab('Completed')),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildOrderList(List<Order> orders) {
    if (orders.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(60),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.shopping_bag_outlined,
                  size: 60,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                //'No Orders Yet',
                'Chưa có đơn hàng',
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.grey[800],
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                //'You haven\'t placed any orders yet.\nStart shopping to see your orders here!',
                'Bạn chưa đặt đơn hàng nào.\nBắt đầu mua sắm để xem đơn hàng của bạn ở đây!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/main');
                },
                icon: const Icon(
                  Icons.shopping_bag,
                  color: Colors.white,
                  size: 20,
                ),
                label: Text(
                  //'Shop Now!',
                  'Mua sắm ngay!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    shadows: [
                      Shadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                  shadowColor: Colors.black.withValues(alpha: 0.3),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        return _buildOrderCard(orders[index]);
      },
    );
  }

  Widget _buildOrderCard(Order order) {
    final isExpanded = expandedOrders.contains(order.orderNumber);
    final itemsToShow = isExpanded ? order.items : [order.items.first];

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order ${order.orderNumber}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                _buildStatusChip(order.statusHistory.last.name),
              ],
            ),
            Text(
              'Date: ${order.orderDate.day}/${order.orderDate.month}/${order.orderDate.year} at ${order.orderDate.hour}:${order.orderDate.minute.toString().padLeft(2, '0')}',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 20),

            ...itemsToShow.map<Widget>((item) => _buildOrderItem(item)),

            // Show More/Less button if more than 1 item
            if (order.items.length > 1)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isExpanded) {
                        expandedOrders.remove(order.orderNumber);
                      } else {
                        expandedOrders.add(order.orderNumber);
                      }
                    });
                  },
                  child: Row(
                    children: [
                      Icon(
                        isExpanded ? Icons.expand_less : Icons.expand_more,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isExpanded
                            ? //'Show Less'
                            'Thu gọn'
                            : //'Show More (${order.items.length - 1} more items)',
                            'Xem thêm (${order.items.length - 1} sản phẩm)',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            const Divider(height: 24),

            // Order Summary
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  //'Total Amount',
                  'Tổng tiền',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  FormatPrice.formatPrice(order.totalAmount),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        '/detail-order',
                        arguments: {'orderId': order.id},
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                        color: AppColors.primary,
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      //'View Details',
                      'Xem chi tiết',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                if (order.statusHistory.last.name == 'completed' ||
                    order.statusHistory.last.name == 'returned')
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        final state = context.read<OrderBloc>().state;
                        if (state is OrderLoaded) {
                          Navigator.pushNamed(
                            context,
                            '/buy-now',
                            arguments: {
                              'items': [
                                for (var item in order.items)
                                  Checkout(
                                    bookId: item.bookId,
                                    quantity: item.quantity,
                                    bookTitle: item.bookTitle,
                                    unitPrice: item.unitPrice,
                                    saleOff: item.bookSaleOff,
                                    bookThumbnail: item.bookThumbnail,
                                  ),
                              ],
                            },
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        //'Re-order',
                        'Đặt hàng lại',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                if (order.statusHistory.last.name == 'wait_confirm' ||
                    order.statusHistory.last.name == 'processing')
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        _showCancelOrderBottomSheet(order);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        //'Cancel Order',
                        'Hủy đơn hàng',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                if (order.statusHistory.last.name == 'payment_completed')
                  Expanded(
                    child: ElevatedButton(
                      onPressed:
                          order.isParent == false
                              ? () {
                                _showReturnOrderDialog(order);
                              }
                              : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        //'Return Order',
                        'Trả hàng',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItem(OrderItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.16),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(Icons.book, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.bookTitle,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Qty: ${item.quantity} x ${FormatPrice.formatPrice(item.unitPrice)}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color backgroundColor;
    Color textColor;

    switch (status) {
      case 'wait_confirm':
      case 'processing':
      case 'shipping':
        backgroundColor = AppColors.primaryDark;
        textColor = Colors.white;
        break;
      case 'completed':
      case 'payment_completed':
        backgroundColor = Colors.green;
        textColor = Colors.white;
        break;
      case 'canceled':
        backgroundColor = Colors.red;
        textColor = Colors.white;
        break;
      case 'returned':
        backgroundColor = Colors.orange;
        textColor = Colors.white;
        break;
      default:
        backgroundColor = Colors.grey;
        textColor = Colors.white;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        status == "payment_completed" ? "paid" : status.replaceAll('_', ' '),
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
