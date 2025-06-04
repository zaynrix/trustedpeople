import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// ==================== Visitor Info Model ====================
class VisitorInfo {
  final String id;
  final String ipAddress;
  final String country;
  final String city;
  final String region;
  final DateTime timestamp;
  final String userAgent;
  final Map<String, dynamic> additionalData;

  const VisitorInfo({
    required this.id,
    required this.ipAddress,
    required this.country,
    required this.city,
    required this.region,
    required this.timestamp,
    required this.userAgent,
    this.additionalData = const {},
  });

  factory VisitorInfo.fromMap(Map<String, dynamic> data, String id) {
    return VisitorInfo(
      id: id,
      ipAddress: data['ipAddress'] ?? 'غير معروف',
      country: data['country'] ?? 'غير معروف',
      city: data['city'] ?? 'غير معروف',
      region: data['region'] ?? 'غير معروف',
      timestamp: data['timestamp'] != null
          ? (data['timestamp'] as Timestamp).toDate()
          : DateTime.now(),
      userAgent: data['userAgent'] ?? 'غير معروف',
      additionalData: Map<String, dynamic>.from(data),
    );
  }

  DeviceInfo get deviceInfo => DeviceInfo.fromUserAgent(userAgent);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ipAddress': ipAddress,
      'country': country,
      'city': city,
      'region': region,
      'timestamp': Timestamp.fromDate(timestamp),
      'userAgent': userAgent,
      ...additionalData,
    };
  }

  VisitorInfo copyWith({
    String? id,
    String? ipAddress,
    String? country,
    String? city,
    String? region,
    DateTime? timestamp,
    String? userAgent,
    Map<String, dynamic>? additionalData,
  }) {
    return VisitorInfo(
      id: id ?? this.id,
      ipAddress: ipAddress ?? this.ipAddress,
      country: country ?? this.country,
      city: city ?? this.city,
      region: region ?? this.region,
      timestamp: timestamp ?? this.timestamp,
      userAgent: userAgent ?? this.userAgent,
      additionalData: additionalData ?? this.additionalData,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is VisitorInfo && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'VisitorInfo(id: $id, ipAddress: $ipAddress, country: $country, city: $city)';
  }
}

// ==================== Device Info Model ====================
class DeviceInfo {
  final String type;
  final String browser;
  final IconData deviceIcon;
  final IconData browserIcon;

  const DeviceInfo({
    required this.type,
    required this.browser,
    required this.deviceIcon,
    required this.browserIcon,
  });

  factory DeviceInfo.fromUserAgent(String userAgent) {
    final ua = userAgent.toLowerCase();

    // Device detection
    String deviceType = 'غير معروف';
    IconData deviceIcon = Icons.devices;

    if (ua.contains('iphone')) {
      deviceType = 'iPhone';
      deviceIcon = Icons.phone_iphone;
    } else if (ua.contains('android')) {
      deviceType = 'Android';
      deviceIcon = Icons.phone_android;
    } else if (ua.contains('mobile')) {
      deviceType = 'جوال';
      deviceIcon = Icons.smartphone;
    } else if (ua.contains('tablet')) {
      deviceType = 'لوحي';
      deviceIcon = Icons.tablet_mac;
    } else if (ua.contains('windows')) {
      deviceType = 'Windows';
      deviceIcon = Icons.laptop_windows;
    } else if (ua.contains('mac')) {
      deviceType = 'Mac';
      deviceIcon = Icons.laptop_mac;
    } else {
      deviceType = 'كمبيوتر';
      deviceIcon = Icons.computer;
    }

    // Browser detection
    String browser = 'غير معروف';
    IconData browserIcon = Icons.public;

    if (ua.contains('chrome')) {
      browser = 'Chrome';
      browserIcon = Icons.web;
    } else if (ua.contains('firefox')) {
      browser = 'Firefox';
      browserIcon = Icons.web;
    } else if (ua.contains('safari')) {
      browser = 'Safari';
      browserIcon = Icons.web;
    } else if (ua.contains('edge')) {
      browser = 'Edge';
      browserIcon = Icons.web;
    }

    return DeviceInfo(
      type: deviceType,
      browser: browser,
      deviceIcon: deviceIcon,
      browserIcon: browserIcon,
    );
  }

  bool get isMobile =>
      type.contains('جوال') ||
      type.contains('iPhone') ||
      type.contains('Android');

  bool get isTablet => type.contains('لوحي');

  bool get isDesktop => !isMobile && !isTablet;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DeviceInfo &&
        other.type == type &&
        other.browser == browser;
  }

  @override
  int get hashCode => type.hashCode ^ browser.hashCode;

  @override
  String toString() {
    return 'DeviceInfo(type: $type, browser: $browser)';
  }
}
