import 'dart:convert';
import 'dart:html' as html;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class BlockService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Check if current user is blocked
  static Future<bool> isUserBlocked() async {
    try {
      // Get user IP address
      final String ip = await _getUserIP();
      final String userAgent = html.window.navigator.userAgent;

      // Check if IP is blocked
      final ipQuery = await _firestore
          .collection('blockedUsers')
          .where('ip', isEqualTo: ip)
          .limit(1)
          .get();

      if (ipQuery.docs.isNotEmpty) {
        return true;
      }

      // Additional check for advanced blocking (fingerprinting)
      // This is more complex in real implementation
      // You'd typically use a combination of factors

      return false;
    } catch (e) {
      debugPrint('Error checking if user is blocked: $e');
      return false;
    }
  }

  // Get user's IP address
  static Future<String> _getUserIP() async {
    try {
      // Fetch IP using a third-party service
      final response = await html.HttpRequest.request(
        'https://api.ipify.org?format=json',
        method: 'GET',
      );

      final data = response.responseText;
      if (data != null) {
        final Map<String, dynamic> jsonData = Map<String, dynamic>.from(
          json.decode(data),
        );
        return jsonData['ip'] as String? ?? 'unknown';
      }

      return 'unknown';
    } catch (e) {
      debugPrint('Error getting user IP: $e');
      return 'unknown';
    }
  }

  // Block a user by IP
  static Future<bool> blockUser(String ip, String reason, String blockedBy,
      [String? userAgent, String? location]) async {
    try {
      await _firestore.collection('blockedUsers').add({
        'ip': ip,
        'userAgent': userAgent ?? 'Not provided',
        'reason': reason,
        'blockedAt': Timestamp.now(),
        'blockedBy': blockedBy,
        'location': location ?? 'Not provided',
      });

      return true;
    } catch (e) {
      debugPrint('Error blocking user: $e');
      return false;
    }
  }

  // Unblock a user
  static Future<bool> unblockUser(String blockId) async {
    try {
      await _firestore.collection('blockedUsers').doc(blockId).delete();

      return true;
    } catch (e) {
      debugPrint('Error unblocking user: $e');
      return false;
    }
  }
}
