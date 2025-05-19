import 'package:flutter/material.dart';

class PaymentMethodsUtil {
  static const List<String> availablePaymentMethods = [
    'فيزا',
    'ماستركارد',
    'تحويل بنكي',
    'جوال باي',
    'نقد',
  ];

  static IconData getIconForMethod(String method) {
    switch (method.toLowerCase()) {
      case 'visa':
      case 'فيزا':
        return Icons.credit_card;
      case 'mastercard':
      case 'ماستركارد':
        return Icons.credit_card;
      case 'bank transfer':
      case 'تحويل بنكي':
        return Icons.account_balance;
      case 'cash':
      case 'نقد':
        return Icons.money;
      case 'jawwal pay':
      case 'جوال باي':
        return Icons.phone_android;
      default:
        return Icons.payment;
    }
  }

  static Color getColorForMethod(String method) {
    switch (method.toLowerCase()) {
      case 'visa':
      case 'فيزا':
        return Colors.blue;
      case 'mastercard':
      case 'ماستركارد':
        return Colors.deepOrange;
      case 'bank transfer':
      case 'تحويل بنكي':
        return Colors.green;
      case 'cash':
      case 'نقد':
        return Colors.grey;
      case 'jawwal pay':
      case 'جوال باي':
        return Colors.purple;
      default:
        return Colors.teal;
    }
  }
}