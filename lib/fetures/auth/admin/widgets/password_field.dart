import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PasswordField extends StatefulWidget {
  final TextEditingController controller;
  final bool isMobile;
  final bool isLoading;
  final String? Function(String?)? validator;
  final String labelText;
  final String hintText;

  const PasswordField({
    Key? key,
    required this.controller,
    this.isMobile = false,
    this.isLoading = false,
    this.validator,
    this.labelText = 'كلمة المرور',
    this.hintText = '••••••••',
  }) : super(key: key);

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      enabled: !widget.isLoading,
      obscureText: _obscurePassword,
      decoration: InputDecoration(
        labelText: widget.labelText,
        labelStyle: GoogleFonts.cairo(),
        hintText: widget.hintText,
        prefixIcon: Icon(
          Icons.lock_outlined,
          color: widget.isLoading ? Colors.grey.shade400 : Colors.grey.shade600,
          size: widget.isMobile ? 20 : 22,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            color:
                widget.isLoading ? Colors.grey.shade400 : Colors.grey.shade600,
            size: widget.isMobile ? 20 : 22,
          ),
          onPressed: widget.isLoading
              ? null
              : () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
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
          vertical: widget.isMobile ? 16 : 18,
        ),
        filled: true,
        fillColor:
            widget.isLoading ? Colors.grey.shade100 : Colors.grey.shade50,
      ),
      style: GoogleFonts.cairo(
        color: widget.isLoading ? Colors.grey.shade500 : Colors.black,
      ),
      autocorrect: false,
      enableSuggestions: false,
      validator: widget.validator ?? _defaultValidator,
    );
  }

  String? _defaultValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'الرجاء إدخال كلمة المرور';
    }
    if (value.length < 6) {
      return 'كلمة المرور قصيرة جداً';
    }
    return null;
  }
}
