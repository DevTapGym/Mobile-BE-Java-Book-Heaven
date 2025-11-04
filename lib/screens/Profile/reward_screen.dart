import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:heaven_book_app/bloc/promotion/promotion_bloc.dart';
import 'package:heaven_book_app/bloc/promotion/promotion_event.dart';
import 'package:heaven_book_app/bloc/promotion/promotion_state.dart';
import 'package:heaven_book_app/themes/app_colors.dart';
import 'package:heaven_book_app/themes/format_price.dart';
import 'package:heaven_book_app/widgets/voucher_card_widget.dart';
import 'package:intl/intl.dart';

class RewardScreen extends StatelessWidget {
  const RewardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          centerTitle: true,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.white,
              size: 28,
              weight: 24,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: Text(
            //'Rewards',
            'Phần thưởng',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          bottom: TabBar(
            tabs: const [Tab(text: 'Mã giảm giá'), Tab(text: 'Thành viên')],
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            labelStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            unselectedLabelStyle: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
        body: TabBarView(children: [VoucherTab(), MemberTab()]),
      ),
    );
  }
}

// Widget cho tab Member
class MemberTab extends StatelessWidget {
  const MemberTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 16.0, left: 8.0, right: 8.0, bottom: 16.0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            _buildMemberCard(),
            SizedBox(height: 16.0),
            _buildMemberBenefits(),
            SizedBox(height: 16.0),
            _buildMemberVouchers(),
            SizedBox(height: 16.0),
          ],
        ),
      ),
    );
  }
}

// Widget cho tab Voucher
class VoucherTab extends StatefulWidget {
  const VoucherTab({super.key});

  @override
  State<VoucherTab> createState() => _VoucherTabState();
}

class _VoucherTabState extends State<VoucherTab> {
  @override
  void initState() {
    super.initState();
    // Load promotions khi khởi tạo
    context.read<PromotionBloc>().add(LoadPromotions());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PromotionBloc, PromotionState>(
      builder: (context, state) {
        if (state is PromotionLoading) {
          return Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        if (state is PromotionError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red),
                SizedBox(height: 16),
                Text(
                  'Lỗi khi tải voucher',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  state.message,
                  style: TextStyle(color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    context.read<PromotionBloc>().add(LoadPromotions());
                  },
                  icon: Icon(Icons.refresh),
                  label: Text('Thử lại'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          );
        }

        if (state is PromotionLoaded) {
          final promotions = state.promotions;

          if (promotions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.card_giftcard_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Chưa có voucher nào',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Hãy quay lại sau để nhận voucher mới!',
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                ],
              ),
            );
          }

          // // Lọc vouchers theo loại
          // final now = DateTime.now();
          // final expiringDays = 7; // Voucher sắp hết hạn trong 7 ngày

          // final expiringSoon =
          //     promotions.where((p) {
          //       if (p.endDate == null) return false;
          //       try {
          //         final endDate = DateFormat('yyyy-MM-dd').parse(p.endDate!);
          //         final daysUntilExpiry = endDate.difference(now).inDays;
          //         return daysUntilExpiry >= 0 &&
          //             daysUntilExpiry <= expiringDays;
          //       } catch (e) {
          //         return false;
          //       }
          //     }).toList();

          // final freeShipping =
          //     promotions
          //         .where((p) => p.promotionType.toLowerCase() == 'freeship')
          //         .toList();

          // final discountVouchers =
          //     promotions
          //         .where(
          //           (p) =>
          //               p.promotionType.toLowerCase() == 'discount' ||
          //               p.promotionType.toLowerCase() == 'percentage',
          //         )
          //         .toList();

          return Container(
            margin: EdgeInsets.all(16.0),
            child: RefreshIndicator(
              onRefresh: () async {
                context.read<PromotionBloc>().add(LoadPromotions());
              },
              color: AppColors.primary,
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    // if (expiringSoon.isNotEmpty)
                    //   _buildVoucherSection(
                    //     context,
                    //     title: 'Expiring soon',
                    //     promotions: expiringSoon,
                    //   ),
                    // if (expiringSoon.isNotEmpty) SizedBox(height: 16.0),
                    // if (freeShipping.isNotEmpty)
                    //   _buildVoucherSection(
                    //     context,
                    //     title: 'Free shipping',
                    //     promotions: freeShipping,
                    //   ),
                    // if (freeShipping.isNotEmpty) SizedBox(height: 16.0),
                    if (promotions.isNotEmpty)
                      _buildVoucherSection(
                        context,
                        //title: 'Discount vouchers',
                        title: 'Mã giảm giá',
                        promotions: promotions,
                      ),
                  ],
                ),
              ),
            ),
          );
        }

        return SizedBox.shrink();
      },
    );
  }

  Widget _buildVoucherSection(
    BuildContext context, {
    required String title,
    required List promotions,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                title,
                style: TextStyle(
                  color: AppColors.text,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(child: Container(height: 2, color: AppColors.text)),
          ],
        ),
        SizedBox(height: 8.0),
        ...promotions.map((promotion) {
          // Format ngày hết hạn
          String validUntil = 'N/A';
          if (promotion.endDate != null) {
            try {
              final date = DateFormat('yyyy-MM-dd').parse(promotion.endDate!);
              validUntil = DateFormat('dd-MM-yyyy').format(date);
            } catch (e) {
              validUntil = promotion.endDate!;
            }
          }

          return VoucherCardWidget(
            title: promotion.name,
            minimumOrder: FormatPrice.formatPrice(promotion.orderMinValue ?? 0),
            points: 0, // Có thể thêm field points trong Promotion model nếu cần
            validUntil: validUntil,
            type:
                promotion.promotionType == 'freeship'
                    ? 'Miễn phí vận chuyển'
                    : promotion.promotionType == 'percent'
                    ? 'Giảm theo %'
                    : 'Giảm giá cố định',
            showRedeemButton: false,
            voucherCode: promotion.code,
            onTap: () => _showVoucherDetails(context, promotion),
          );
        }),
      ],
    );
  }

  void _showVoucherDetails(BuildContext context, promotion) {
    showDialog(
      context: context,
      builder: (builder) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.card_giftcard, color: AppColors.primary),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Chi tiết Voucher',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('Mã', promotion.code),
                _buildDetailRow('Tên', promotion.name),
                _buildDetailRow(
                  'Loại',
                  promotion.promotionType == 'freeship'
                      ? 'Miễn phí vận chuyển'
                      : promotion.promotionType == 'percentage'
                      ? 'Giảm theo %'
                      : 'Giảm giá cố định',
                ),
                if (promotion.promotionValue != null)
                  _buildDetailRow(
                    'Giá trị',
                    promotion.promotionType == 'percentage'
                        ? '${promotion.promotionValue?.toInt() ?? 0}%'
                        : FormatPrice.formatPrice(
                          promotion.promotionValue ?? 0,
                        ),
                  ),
                if (promotion.orderMinValue != null)
                  _buildDetailRow(
                    'Đơn tối thiểu',
                    FormatPrice.formatPrice(promotion.orderMinValue ?? 0),
                  ),
                if (promotion.maxPromotionValue != null &&
                    promotion.isMaxPromotionValue)
                  _buildDetailRow(
                    'Giảm tối đa',
                    FormatPrice.formatPrice(promotion.maxPromotionValue ?? 0),
                  ),
                if (promotion.startDate != null)
                  _buildDetailRow(
                    'Ngày bắt đầu',
                    _formatDate(promotion.startDate!),
                  ),
                if (promotion.endDate != null)
                  _buildDetailRow(
                    'Ngày hết hạn',
                    _formatDate(promotion.endDate!),
                  ),
                if (promotion.note != null && promotion.note!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ghi chú:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[700],
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          promotion.note!,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
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
                'Đóng',
                style: TextStyle(
                  color: AppColors.primary,
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: TextStyle(color: Colors.grey[800])),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateFormat('yyyy-MM-dd').parse(dateString);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (e) {
      return dateString;
    }
  }
}

Widget _buildMemberCard() {
  return Container(
    padding: EdgeInsets.only(top: 16.0, left: 12.0, right: 12.0, bottom: 30.0),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(18.0),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFFFA500), Color(0xFFFFD700)],
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'GOLD',
          style: TextStyle(
            fontSize: 26.0,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [
              Shadow(
                offset: Offset(2.0, 2.0),
                blurRadius: 2.0,
                color: Colors.black26,
              ),
            ],
          ),
        ),
        Text(
          'Huỳnh Công Tiến',
          style: TextStyle(
            fontSize: 20.0,
            color: Colors.white,
            fontWeight: FontWeight.w600,
            shadows: [
              Shadow(
                offset: Offset(0, 0),
                blurRadius: 12.0,
                color: Colors.black26,
              ),
            ],
          ),
        ),
        SizedBox(height: 8.0),
        Container(
          padding: EdgeInsets.only(top: 12.0, left: 8, right: 8, bottom: 14.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.0),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 2.0,
                offset: Offset(2, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                //'Maintenance conditions',
                'Điều kiện duy trì',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.0),
              Row(
                children: [
                  // Phần Order
                  SizedBox(
                    width: 120,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          //'Order',
                          'Đơn hàng',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4.0),
                        Row(
                          children: [
                            Text(
                              '12',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: AppColors.primaryDark,
                              ),
                            ),
                            Text('/10'),
                          ],
                        ),
                        SizedBox(height: 8.0),
                        LinearProgressIndicator(
                          value: 1.0,
                          borderRadius: BorderRadius.circular(4.0),
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.primaryDark,
                          ),
                          minHeight: 6.0,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 72.0,
                    width: 2.0,
                    color: Colors.black26,
                    margin: EdgeInsets.symmetric(horizontal: 12.0),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          //'Spending',
                          'Chi tiêu',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4.0),
                        Row(
                          children: [
                            Text(
                              '1,200,000 đ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: AppColors.primaryDark,
                              ),
                            ),
                            Text('/2,000,000 đ'),
                          ],
                        ),
                        SizedBox(height: 8.0),
                        LinearProgressIndicator(
                          value: 1200000 / 2000000,
                          borderRadius: BorderRadius.circular(4.0),
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.primaryDark,
                          ),
                          minHeight: 6.0,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 14.0),
              Text(
                //'Ranking will be updated after 12-31-2025',
                'Xếp hạng sẽ được cập nhật sau 31-12-2025',
                style: TextStyle(color: Colors.black54, fontSize: 13),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _buildMemberBenefits() {
  return Container(
    margin: EdgeInsets.all(12),
    padding: EdgeInsets.all(16.0),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12.0),
      boxShadow: [
        BoxShadow(
          color: Colors.black26,
          blurRadius: 12.0,
          spreadRadius: 2.0,
          offset: Offset(0, 0),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.info_outline, color: AppColors.primaryDark, size: 28.0),
            SizedBox(width: 8.0),
            Text(
              //'Membership benefits',
              'Lợi ích thành viên',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryDark,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.0),
        Text(
          //'- Free shipping over 200k',
          '- Miễn phí vận chuyển đơn trên 200k',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54),
        ),
        SizedBox(height: 4.0),
        Text(
          //'- 10% off orders above 200k',
          '- Giảm 10% đơn hàng trên 200k',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54),
        ),
        SizedBox(height: 4.0),
        Text(
          //'- 30% off on birthday',
          '- Giảm 30% vào ngày sinh nhật',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54),
        ),
      ],
    ),
  );
}

Widget _buildMemberVouchers() {
  return Column(
    children: [
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  //'Points Redemption',
                  'Đổi điểm',
                  style: TextStyle(
                    color: AppColors.text,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(child: Container(height: 2, color: AppColors.text)),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Icon(Icons.stars_rounded, color: AppColors.primaryDark),
              SizedBox(width: 4),
              Text(
                '2000',
                style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.black54,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
      SizedBox(height: 8.0),
      VoucherCardWidget(
        //title: 'Save up to 20k',
        title: 'Tiết kiệm đến 20k',
        minimumOrder: '80k',
        points: 2000,
        validUntil: '12-12-2015',
        type: 'Free Shipping',
        showPoints: true,
      ),
      VoucherCardWidget(
        //title: 'Save up to 20k',
        title: 'Tiết kiệm đến 20k',
        minimumOrder: '80k',
        points: 2000,
        validUntil: '12-12-2015',
        type: 'Free Shipping',
        showPoints: true,
      ),
      VoucherCardWidget(
        //title: 'Save up to 20k',
        title: 'Tiết kiệm đến 50k',
        minimumOrder: '80k',
        points: 2000,
        validUntil: '12-12-2015',
        type: 'Free Shipping',
        showPoints: true,
      ),
    ],
  );
}
