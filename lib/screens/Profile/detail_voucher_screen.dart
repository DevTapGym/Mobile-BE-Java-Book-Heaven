import 'package:flutter/material.dart';
import 'package:heaven_book_app/themes/app_colors.dart';
import 'package:heaven_book_app/widgets/voucher_card_widget.dart';

class DetailVoucherScreen extends StatefulWidget {
  const DetailVoucherScreen({super.key});

  @override
  State<DetailVoucherScreen> createState() => _DetailVoucherScreenState();
}

class _DetailVoucherScreenState extends State<DetailVoucherScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: AppColors.primaryDark,
            size: 30,
            weight: 100,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Detail Voucher',
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
            // Thêm hình tròn lớn màu xanh đậm vào background
            Positioned(
              top: -220,
              right: 180,
              child: Container(
                width: 400,
                height: 400,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryDark, // Màu xanh đậm
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
                      title: 'Save up to 20k',
                      minimumOrder: '80k',
                      points: 2000,
                      validUntil: '12-12-2015',
                      type: 'Free Shipping',
                      showRedeemButton: false,
                      hasMargin: false,
                      showPerforation: false,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0, right: 16.0),
                    child: _buildExpiryInfo(),
                  ),
                  SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0, right: 16.0),
                    child: _buildDetailsSection(),
                  ),
                  SizedBox(height: 42),
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0, right: 16.0),
                    child: _buildUseNowButton(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpiryInfo() {
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
            'Expiry after: 3 days',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsSection() {
    return Container(
      padding: const EdgeInsets.only(
        top: 32.0,
        left: 24.0,
        right: 24.0,
        bottom: 32.0,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 12,
            offset: Offset(0, 0),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailRow(
            icon: Icons.person_2_outlined,
            label: 'Usage Limit :',
            detailWidget: '',
          ),
          Row(
            children: [
              SizedBox(
                width: 200,
                child: LinearProgressIndicator(
                  value: 0.4,
                  borderRadius: BorderRadius.circular(4.0),
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.primaryDark,
                  ),
                  minHeight: 6.0,
                ),
              ),
              SizedBox(width: 12.0),
              Text(
                '40',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppColors.primaryDark,
                ),
              ),
              Text('/100', style: TextStyle(fontSize: 12, color: Colors.black)),
            ],
          ),
          SizedBox(height: 16.0),
          _buildDetailRow(
            icon: Icons.access_time_rounded,
            label: 'Expiry Date :',
            detailWidget: 'From 04:00 15-08-2025 to 00:00 20-09-2025',
          ),
          SizedBox(height: 16.0),
          _buildDetailRow(
            icon: Icons.receipt_long_outlined,
            label: 'Terms & Conditions :',
            detailWidget:
                'Limited uses, hurry before it\'s gone! Get 10% OFF on orders over 800k, up to 300k discount.',
          ),
          SizedBox(height: 16.0),
          _buildDetailRow(
            icon: Icons.privacy_tip_outlined,
            label: 'Applicable products :',
            detailWidget: 'All textbooks and books in the science category',
          ),
          SizedBox(height: 16.0),
          _buildDetailRow(
            icon: Icons.payment_outlined,
            label: 'Payment methods :',
            detailWidget: 'All payment methods',
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String detailWidget,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.black87),
            SizedBox(width: 8.0),
            Text(
              label,
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        if (detailWidget.isNotEmpty) ...[
          SizedBox(height: 4.0),
          Text(
            detailWidget,
            style: TextStyle(fontSize: 14.0, color: Colors.black54),
          ),
        ],
      ],
    );
  }

  Widget _buildUseNowButton() {
    return Center(
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            // Handle redeem action
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryDark,
            padding: EdgeInsets.symmetric(horizontal: 40.0, vertical: 12.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
          ),
          child: Text(
            'Use Now',
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
