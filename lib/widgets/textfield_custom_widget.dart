import 'package:flutter/material.dart';
import 'package:heaven_book_app/themes/app_colors.dart';

class TextfieldCustomWidget extends StatelessWidget {
  final String label;
  final Widget? suffixIcon;
  final TextEditingController controller;

  const TextfieldCustomWidget({
    super.key,
    required this.label,
    required this.controller,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          TextFormField(
            controller: controller,
            style: TextStyle(color: Colors.black54, fontSize: 17),
            decoration: InputDecoration(
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.black54),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.black54),
              ),
              suffixIcon:
                  suffixIcon ??
                  IconButton(
                    icon: Icon(
                      Icons.clear_rounded,
                      size: 20,
                      color: Colors.black54,
                    ),
                    onPressed: () {
                      controller.clear();
                    },
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class LabelTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool obscureText;
  final String? hintText;
  final Widget? suffixIcon;
  final Function(String)? onChanged;
  final TextInputType? keyboardType;
  final EdgeInsetsGeometry? contentPadding;

  const LabelTextField({
    super.key,
    required this.label,
    required this.controller,
    this.obscureText = false,
    this.hintText,
    this.suffixIcon,
    this.onChanged,
    this.keyboardType,
    this.contentPadding,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.w500,
            color: AppColors.black60,
          ),
        ),
        const SizedBox(height: 8.0),
        TextField(
          controller: controller,
          obscureText: obscureText,
          onChanged: onChanged,
          keyboardType: keyboardType,
          style: const TextStyle(fontSize: 14.0),
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: const BorderSide(
                color: AppColors.black60,
                width: 2.0,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: const BorderSide(
                color: AppColors.black60,
                width: 2.0,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: const BorderSide(
                color: AppColors.primaryDark,
                width: 2.0,
              ),
            ),
            filled: true,
            fillColor: Colors.white,
            suffixIcon: suffixIcon,
            hintText: hintText,
            contentPadding:
                contentPadding ??
                const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
          ),
        ),
      ],
    );
  }
}
