import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// A reusable search field widget used throughout the app
class SearchField extends StatelessWidget {
  final Function(String) onChanged;
  final String? initialValue;
  final String? hintText;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;

  const SearchField({
    Key? key,
    required this.onChanged,
    this.initialValue,
    this.hintText,
    this.padding,
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        initialValue: initialValue,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hintText ?? 'بحث...',
          hintStyle: GoogleFonts.cairo(color: Colors.grey.shade500),
          prefixIcon: Icon(
            Icons.search,
            color: Colors.grey.shade600,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
        style: GoogleFonts.cairo(),
      ),
    );
  }
}
