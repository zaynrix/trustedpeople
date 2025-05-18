import 'package:cloud_firestore/cloud_firestore.dart';

class AppUpdate {
  final String id;
  final String title;
  final String description;
  final String version;
  final DateTime date;

  AppUpdate({
    required this.id,
    required this.title,
    required this.description,
    required this.version,
    required this.date,
  });

  factory AppUpdate.fromMap(Map<String, dynamic> map, String documentId) {
    return AppUpdate(
      id: documentId,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      version: map['version'] ?? '',
      date: (map['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

class HomeData {
  final int trustedCount;
  final int untrustedCount;
  final int totalVisitors;
  final List<AppUpdate> recentUpdates;

  HomeData({
    required this.trustedCount,
    required this.untrustedCount,
    required this.totalVisitors,
    required this.recentUpdates,
  });
}
