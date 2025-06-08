import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EmailField extends StatelessWidget {
  final TextEditingController controller;
  final bool isMobile;
  final bool isLoading;
  final String? Function(String?)? validator;
  final String labelText;
  final String hintText;

  const EmailField({
    Key? key,
    required this.controller,
    this.isMobile = false,
    this.isLoading = false,
    this.validator,
    this.labelText = 'البريد الإلكتروني',
    this.hintText = 'admin@example.com',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      enabled: !isLoading,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: GoogleFonts.cairo(),
        hintText: hintText,
        prefixIcon: Icon(
          Icons.email_outlined,
          color: isLoading ? Colors.grey.shade400 : Colors.grey.shade600,
          size: isMobile ? 20 : 22,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade700, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16,
          vertical: isMobile ? 16 : 18,
        ),
        filled: true,
        fillColor: isLoading ? Colors.grey.shade100 : Colors.grey.shade50,
      ),
      style: GoogleFonts.cairo(
        color: isLoading ? Colors.grey.shade500 : Colors.black,
      ),
      keyboardType: TextInputType.emailAddress,
      autocorrect: false,
      validator: validator ?? _defaultValidator,
    );
  }

  String? _defaultValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'الرجاء إدخال البريد الإلكتروني';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'البريد الإلكتروني غير صحيح';
    }
    return null;
  }
}
