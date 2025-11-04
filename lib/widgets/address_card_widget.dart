import 'package:flutter/material.dart';
import 'package:heaven_book_app/themes/app_colors.dart';

class AddressCardWidget extends StatelessWidget {
  final String title;
  final String name;
  final String phone;
  final String address;
  final bool hasIcon;
  final bool isDefault;
  final bool hasEditButton;
  final bool hasDeleteButton;
  final bool isTappable;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;

  const AddressCardWidget({
    super.key,
    required this.title,
    required this.name,
    required this.phone,
    required this.address,
    this.hasIcon = true,
    this.isDefault = false,
    this.hasEditButton = true,
    this.hasDeleteButton = true,
    this.isTappable = false,
    this.onEdit,
    this.onDelete,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isTappable ? onTap : null,
      child: Container(
        margin: EdgeInsets.only(
          bottom: 10.0,
          top: 10.0,
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
            Row(
              children: [
                if (hasIcon)
                  Icon(
                    Icons.location_on,
                    color: AppColors.primaryDark,
                    size: 28,
                  ),
                SizedBox(width: hasIcon ? 8.0 : 0),
                Text(
                  title,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Spacer(),
                if (isDefault)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.0,
                      vertical: 4.0,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(12.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          offset: Offset(1, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      'Default',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 16.0),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '$name | $phone',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
                if (isTappable) // Hiển thị icon arrow_forward_ios_rounded nếu isTappable = true
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: AppColors.primaryDark,
                    size: 30,
                  ),
              ],
            ),
            SizedBox(height: 4.0),
            Text(address, style: TextStyle(fontSize: 14)),
            SizedBox(height: 4.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (hasEditButton)
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primaryDark,
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: IconButton(
                      icon: Icon(Icons.edit, color: Colors.white),
                      onPressed: onEdit,
                    ),
                  ),
                SizedBox(width: 12.0),
                if (hasDeleteButton)
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: IconButton(
                      icon: Icon(Icons.delete, color: Colors.white),
                      onPressed: onDelete,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
