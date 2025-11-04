import 'package:flutter/material.dart';
import '../themes/app_colors.dart';

class CustomCircleCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?> onChanged;

  const CustomCircleCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: value ? AppColors.primaryDark : Colors.grey,
            width: 3,
          ),
          color: value ? AppColors.primaryDark : Colors.white,
        ),
        child:
            value
                ? Center(
                  child: Icon(
                    Icons.check,
                    size: 18,
                    color: Colors.white,
                    weight: 900,
                  ),
                )
                : null,
      ),
    );
  }
}
