import 'dart:convert';
import 'dart:html' as html;

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class LocationService {
  static const String _ipifyApi = 'https://api.ipify.org?format=json';
  static const String _ipApiUrl = 'https://ipapi.co/';

  // Get visitor location data based on IP
  static Future<Map<String, dynamic>> getLocationData() async {
    try {
      // First get the visitor's IP address
      final ip = await _getIpAddress();

      // Then get location data for that IP
      final locationData = await _getLocationFromIp(ip);

      return {
        'ip': ip,
        ...locationData,
      };
    } catch (e) {
      debugPrint('Error getting location data: $e');
      return {
        'ip': 'Unknown',
        'country': 'Unknown',
        'city': 'Unknown',
        'region': 'Unknown',
        'latitude': 0.0,
        'longitude': 0.0,
      };
    }
  }

  // Get visitor's IP address
  static Future<String> _getIpAddress() async {
    try {
      final response = await http.get(Uri.parse(_ipifyApi));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['ip'] as String? ?? 'Unknown';
      } else {
        throw Exception('Failed to get IP address');
      }
    } catch (e) {
      debugPrint('Error getting IP address: $e');
      return 'Unknown';
    }
  }

  // Get location data from IP address
  static Future<Map<String, dynamic>> _getLocationFromIp(String ip) async {
    try {
      // Skip API call if IP is unknown
      if (ip == 'Unknown') {
        return {
          'country': 'Unknown',
          'city': 'Unknown',
          'region': 'Unknown',
          'latitude': 0.0,
          'longitude': 0.0,
        };
      }

      // Call IP geolocation API
      final response = await http.get(Uri.parse('$_ipApiUrl$ip/json'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        return {
          'country': data['country_name'] ?? 'Unknown',
          'city': data['city'] ?? 'Unknown',
          'region': data['region'] ?? 'Unknown',
          'latitude':
              double.tryParse(data['latitude']?.toString() ?? '0') ?? 0.0,
          'longitude':
              double.tryParse(data['longitude']?.toString() ?? '0') ?? 0.0,
          'timezone': data['timezone'] ?? 'Unknown',
          'isp': data['org'] ?? 'Unknown',
        };
      } else {
        throw Exception('Failed to get location data');
      }
    } catch (e) {
      debugPrint('Error getting location from IP: $e');
      return {
        'country': 'Unknown',
        'city': 'Unknown',
        'region': 'Unknown',
        'latitude': 0.0,
        'longitude': 0.0,
      };
    }
  }

  // A simple way to get approximate language and locale
  static String getUserLanguage() {
    return html.window.navigator.language;
  }
}
