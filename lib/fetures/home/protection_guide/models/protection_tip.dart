// Protection tip model
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ProtectionTip {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final int order;

  ProtectionTip({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.order,
  });

  factory ProtectionTip.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Convert string icon name to IconData
    final iconName = data['icon'] ?? 'shield';
    final IconData iconData = _getIconFromString(iconName);

    return ProtectionTip(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      icon: iconData,
      order: (data['order'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'icon': _getStringFromIcon(icon),
      'order': order,
    };
  }

  static IconData _getIconFromString(String iconName) {
    switch (iconName) {
      case 'money':
        return Icons.money_off;
      case 'verify':
        return Icons.verified_user;
      case 'warning':
        return Icons.warning;
      case 'security':
        return Icons.security;
      case 'lock':
        return Icons.lock;
      case 'person':
        return Icons.person_off;
      default:
        return Icons.shield;
    }
  }

  static String _getStringFromIcon(IconData icon) {
    if (icon == Icons.money_off) return 'money';
    if (icon == Icons.verified_user) return 'verify';
    if (icon == Icons.warning) return 'warning';
    if (icon == Icons.security) return 'security';
    if (icon == Icons.lock) return 'lock';
    if (icon == Icons.person_off) return 'person';
    return 'shield';
  }
}
