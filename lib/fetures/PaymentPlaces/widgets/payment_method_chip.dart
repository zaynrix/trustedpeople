// lib/fetures/PaymentPlaces/widgets/payment_method_chip.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PaymentMethodChip extends StatelessWidget {
  final String method;
  final bool compact;

  const PaymentMethodChip({
    Key? key,
    required this.method,
    this.compact = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color color;

    switch (method.toLowerCase()) {
      case 'visa':
      case 'فيزا':
        icon = Icons.credit_card;
        color = Colors.blue;
        break;
      case 'mastercard':
      case 'ماستركارد':
        icon = Icons.credit_card;
        color = Colors.deepOrange;
        break;
      case 'bank transfer':
      case 'تحويل بنكي':
        icon = Icons.account_balance;
        color = Colors.green;
        break;
      case 'cash':
      case 'نقد':
        icon = Icons.money;
        color = Colors.grey;
        break;
      case 'jawwal pay':
      case 'جوال باي':
        icon = Icons.phone_android;
        color = Colors.purple;
        break;
      default:
        icon = Icons.payment;
        color = Colors.teal;
    }

    return Container(
      margin: EdgeInsets.only(right: compact ? 4 : 8),
      child: Chip(
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: compact
            ? const VisualDensity(horizontal: -4, vertical: -4)
            : VisualDensity.standard,
        avatar: Icon(
          icon,
          color: Colors.white,
          size: compact ? 14 : 18,
        ),
        label: Text(
          method,
          style: GoogleFonts.cairo(
            color: Colors.white,
            fontSize: compact ? 10 : 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: color,
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 4 : 8,
          vertical: compact ? 0 : 4,
        ),
      ),
    );
  }
}
