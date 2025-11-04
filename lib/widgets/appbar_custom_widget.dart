import 'package:flutter/material.dart';
import 'package:heaven_book_app/themes/app_colors.dart';

class AppbarCustomWidget extends StatelessWidget
    implements PreferredSizeWidget {
  final String title;
  final bool hasActionButton;
  final String? actionText;
  final VoidCallback? onActionPressed;

  const AppbarCustomWidget({
    super.key,
    required this.title,
    this.hasActionButton = false,
    this.actionText,
    this.onActionPressed,
  });

  @override
  Size get preferredSize => const Size.fromHeight(200.0);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(
        top: 50.0,
        left: 8.0,
        right: 8.0,
        bottom: 16.0,
      ),
      decoration: BoxDecoration(color: AppColors.primary),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
              radius: 20.0,
              backgroundColor: Colors.white,
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: AppColors.primaryDark,
                  size: 24,
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
                shadows: [
                  Shadow(
                    color: Colors.black26,
                    offset: Offset(1.0, 1.0),
                    blurRadius: 4.0,
                  ),
                ],
              ),
            ),
          ),
          if (hasActionButton && actionText != null && onActionPressed != null)
            TextButton(
              onPressed: onActionPressed,
              child: Text(
                actionText!,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 16.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
