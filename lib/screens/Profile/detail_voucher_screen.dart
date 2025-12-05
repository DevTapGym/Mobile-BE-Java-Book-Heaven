import 'package:flutter/material.dart';
import 'package:heaven_book_app/model/promotion.dart';
import 'package:heaven_book_app/themes/app_colors.dart';
import 'package:heaven_book_app/themes/format_price.dart';
import 'package:heaven_book_app/widgets/voucher_card_widget.dart';
import 'package:intl/intl.dart';

class DetailVoucherScreen extends StatefulWidget {
  const DetailVoucherScreen({super.key});

  @override
  State<DetailVoucherScreen> createState() => _DetailVoucherScreenState();
}

class _DetailVoucherScreenState extends State<DetailVoucherScreen> {
  Promotion? promotion;
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_isInitialized) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null && args['promotion'] != null) {
        promotion = args['promotion'] as Promotion;
      }
      _isInitialized = true;
    }

    debugPrint('Promotion in DetailVoucherScreen: $promotion');
  }

  String _formatDate(String dateString) {
    try {
      final date = DateFormat('yyyy-MM-dd').parse(dateString);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (e) {
      return dateString;
    }
  }

  String _getPromotionType() {
    if (promotion == null) return 'N/A';

    if (promotion!.promotionType.toLowerCase() == 'freeship') {
      return 'Miễn phí vận chuyển';
    } else if (promotion!.promotionType.toLowerCase() == 'percent' ||
        promotion!.promotionType.toLowerCase() == 'percentage') {
      return 'Giảm theo phần trăm';
    } else {
      return 'Giảm giá cố định';
    }
  }

  String _getPromotionValue() {
    if (promotion == null || promotion!.promotionValue == null) return 'N/A';

    if (promotion!.promotionType.toLowerCase() == 'percent' ||
        promotion!.promotionType.toLowerCase() == 'percentage') {
      return '${promotion!.promotionValue!.toInt()}%';
    } else if (promotion!.promotionType.toLowerCase() == 'freeship') {
      return 'Miễn phí vận chuyển';
    } else {
      return FormatPrice.formatPrice(promotion!.promotionValue!);
    }
  }

  int _calculateDaysUntilExpiry() {
    if (promotion?.endDate == null) return 0;

    try {
      final endDate = DateFormat('yyyy-MM-dd').parse(promotion!.endDate!);
      final now = DateTime.now();
      return endDate.difference(now).inDays;
    } catch (e) {
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (promotion == null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: AppColors.primaryDark,
              size: 30,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Chi tiết Voucher',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
        body: Center(child: Text('Không tìm thấy thông tin voucher')),
      );
    }

    // Format dates
    String validUntil = 'N/A';
    if (promotion!.endDate != null) {
      validUntil = _formatDate(promotion!.endDate!);
    }

    final daysLeft = _calculateDaysUntilExpiry();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.primaryDark, size: 30),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Chi tiết Voucher',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.primary.withAlpha(80), AppColors.background],
            stops: [0.20, 0.20],
          ),
        ),
        child: Stack(
          children: [
            // Background circle
            Positioned(
              top: -220,
              right: 180,
              child: Container(
                width: 400,
                height: 400,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryDark,
                ),
              ),
            ),
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 64),
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0, right: 16.0),
                    child: VoucherCardWidget(
                      title: promotion!.name,
                      minimumOrder: FormatPrice.formatPrice(
                        promotion!.orderMinValue ?? 0,
                      ),
                      points: 0,
                      validUntil: validUntil,
                      type: _getPromotionType(),
                      showRedeemButton: false,
                      hasMargin: false,
                      showPerforation: false,
                      voucherCode: promotion!.code,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0, right: 16.0),
                    child: _buildExpiryInfo(daysLeft),
                  ),
                  SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0, right: 16.0),
                    child: _buildDetailsSection(),
                  ),
                  SizedBox(height: 32),
                  if (daysLeft > 0)
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0, right: 16.0),
                      child: _buildUseNowButton(),
                    ),
                  SizedBox(height: 62),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpiryInfo(int daysLeft) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      margin: EdgeInsets.symmetric(horizontal: 4.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.black38)),
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 2, offset: Offset(2, 2)),
        ],
      ),
      child: Row(
        children: [
          SizedBox(width: 16),
          Icon(Icons.timer_rounded, color: Colors.black54),
          SizedBox(width: 10),
          Text(
            daysLeft > 0 ? 'Hết hạn sau: $daysLeft ngày' : 'Đã hết hạn',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: daysLeft > 0 ? Colors.black54 : Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsSection() {
    String startDate =
        promotion!.startDate != null
            ? _formatDate(promotion!.startDate!)
            : 'N/A';
    String endDate =
        promotion!.endDate != null ? _formatDate(promotion!.endDate!) : 'N/A';

    // Kiểm tra có hiển thị "Giảm tối đa" không
    bool showMaxDiscount =
        promotion!.isMaxPromotionValue && promotion!.maxPromotionValue != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Thông tin chính - Grid 2x2 nghiêm ngặt
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cột trái - luôn có đúng 2 ô
            Expanded(
              child: Column(
                children: [
                  // Ô 1 cột trái
                  if (showMaxDiscount)
                    // Có giảm tối đa: hiện Giá trị giảm
                    _buildInfoCard(
                      icon: Icons.discount,
                      label: 'Giá trị giảm',
                      value: _getPromotionValue(),
                    )
                  else
                    // Không có giảm tối đa: hiện Mã voucher
                    _buildInfoCard(
                      icon: Icons.qr_code_2,
                      label: 'Mã voucher',
                      value: promotion!.code,
                    ),
                  SizedBox(height: 12),
                  // Ô 2 cột trái - luôn là Đơn tối thiểu
                  _buildInfoCard(
                    icon: Icons.shopping_cart,
                    label: 'Đơn tối thiểu',
                    value:
                        promotion!.orderMinValue != null
                            ? FormatPrice.formatPrice(promotion!.orderMinValue!)
                            : 'Không yêu cầu',
                  ),
                ],
              ),
            ),
            SizedBox(width: 12),
            // Cột phải - luôn có đúng 2 ô
            Expanded(
              child: Column(
                children: [
                  // Ô 1 cột phải - luôn là Loại voucher
                  _buildInfoCard(
                    icon: Icons.card_giftcard,
                    label: 'Loại voucher',
                    value: _getPromotionType(),
                  ),
                  SizedBox(height: 12),
                  // Ô 2 cột phải
                  if (showMaxDiscount)
                    // Có giảm tối đa: hiện Giảm tối đa
                    _buildInfoCard(
                      icon: Icons.monetization_on,
                      label: 'Giảm tối đa',
                      value: FormatPrice.formatPrice(
                        promotion!.maxPromotionValue!,
                      ),
                    )
                  else
                    // Không có giảm tối đa: hiện Giá trị giảm
                    _buildInfoCard(
                      icon: Icons.discount,
                      label: 'Giá trị giảm',
                      value: _getPromotionValue(),
                    ),
                ],
              ),
            ),
          ],
        ),

        SizedBox(height: 16),

        // Thời gian áp dụng - Full width
        _buildInfoCard(
          icon: Icons.access_time_rounded,
          label: 'Thời gian áp dụng',
          value: 'Từ $startDate đến $endDate',
          isFullWidth: true,
        ),

        SizedBox(height: 16),

        // Điều khoản - Full width
        _buildInfoCard(
          icon: Icons.receipt_long_outlined,
          label: 'Điều khoản & Điều kiện',
          value:
              (promotion!.note != null && promotion!.note!.isNotEmpty)
                  ? promotion!.note!
                  : 'Áp dụng cho tất cả sản phẩm',
          isFullWidth: true,
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
    bool isFullWidth = false,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            spreadRadius: 1,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primaryDark, size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.text,
            ),
            maxLines: isFullWidth ? null : 2,
            overflow: isFullWidth ? null : TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildUseNowButton() {
    return Center(
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            // Quay về màn checkout với voucher đã chọn
            //Navigator.pop(context, promotion);
            Navigator.pushNamed(
              context,
              '/main',
              arguments: {'promotion': promotion},
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryDark,
            padding: EdgeInsets.symmetric(horizontal: 40.0, vertical: 12.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
          ),
          child: Text(
            'Sử dụng ngay',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
