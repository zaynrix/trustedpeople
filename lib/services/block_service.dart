// // Create a new file: lib/services/block_service.dart
// import 'dart:convert';
// import 'dart:js' as js;
//
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/foundation.dart';
// import 'package:http/http.dart' as http;
//
// class BlockService {
//   static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//
//   // Check if current user is blocked
//   static Future<bool> isUserBlocked() async {
//     try {
//       // Get current IP
//       final ipResponse = await http.get(Uri.parse('https://ipapi.co/json/'));
//       if (ipResponse.statusCode != 200) {
//         return false; // Cannot determine IP, assume not blocked
//       }
//
//       final ipData = json.decode(ipResponse.body);
//       final currentIp = ipData['ip'];
//
//       // Get user agent
//       final userAgent =
//           kIsWeb ? js.context['navigator']['userAgent'].toString() : '';
//
//       // Check if IP is blocked
//       final ipBlocked = await _isIpBlocked(currentIp);
//       if (ipBlocked) return true;
//
//       // Check if user agent is blocked (for web only)
//       if (kIsWeb && userAgent.isNotEmpty) {
//         return await _isUserAgentBlocked(userAgent);
//       }
//
//       return false;
//     } catch (e) {
//       debugPrint('Error checking if user is blocked: $e');
//       return false; // On error, assume not blocked
//     }
//   }
//
//   static Future<bool> _isIpBlocked(String ip) async {
//     final snapshot = await _firestore
//         .collection('blockedUsers')
//         .where('ip', isEqualTo: ip)
//         .limit(1)
//         .get();
//
//     return snapshot.docs.isNotEmpty;
//   }
//
//   static Future<bool> _isUserAgentBlocked(String userAgent) async {
//     // This is a simplified check - in production, you might want a more
//     // sophisticated matching algorithm
//     final snapshot = await _firestore
//         .collection('blockedUsers')
//         .where('userAgent', isEqualTo: userAgent)
//         .limit(1)
//         .get();
//
//     return snapshot.docs.isNotEmpty;
//   }
// }
