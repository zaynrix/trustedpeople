import 'package:cloud_firestore/cloud_firestore.dart';

class Activity {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final String type; // 'update', 'announcement', 'warning', etc.
  final String createdBy;
  final bool isPublic; // Whether it's visible to users

  Activity({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.type,
    required this.createdBy,
    this.isPublic = true,
  });

  // factory Activity.fromFirestore(DocumentSnapshot doc) {
  //   final data = doc.data() as Map<String, dynamic>;
  //   return Activity(
  //     id: doc.id,
  //     title: data['title'] ?? '',
  //     description: data['description'] ?? '',
  //     date: (data['date'] as Timestamp).toDate(),
  //     type: data['type'] ?? 'update',
  //     createdBy: data['createdBy'] ?? '',
  //     isPublic: data['isPublic'] ?? true,
  //   );
  // }
  factory Activity.fromFirestore(DocumentSnapshot doc) {
    try {
      final data = doc.data() as Map<String, dynamic>;

      // Validate date field is actually a Timestamp
      DateTime date;
      try {
        if (data['date'] is Timestamp) {
          date = (data['date'] as Timestamp).toDate();
        } else {
          // Fallback to current date if date field is invalid
          print('Invalid date format in document ${doc.id}');
          date = DateTime.now();
        }
      } catch (e) {
        print('Error parsing date in document ${doc.id}: $e');
        date = DateTime.now();
      }

      return Activity(
        id: doc.id,
        title: data['title'] ?? 'No Title',
        description: data['description'] ?? 'No Description',
        date: date,
        type: data['type'] ?? 'update',
        createdBy: data['createdBy'] ?? '',
        isPublic: data['isPublic'] ?? true,
      );
    } catch (e) {
      print('Error in Activity.fromFirestore for document ${doc.id}: $e');
      // Return a placeholder activity in case of error
      return Activity(
        id: doc.id,
        title: 'Error',
        description: 'There was an error loading this activity',
        date: DateTime.now(),
        type: 'error',
        createdBy: 'System',
        isPublic: true,
      );
    }
  }
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'date': Timestamp.fromDate(date),
      'type': type,
      'createdBy': createdBy,
      'isPublic': isPublic,
    };
  }

  // Create a copy with updated fields
  Activity copyWith({
    String? title,
    String? description,
    DateTime? date,
    String? type,
    String? createdBy,
    bool? isPublic,
  }) {
    return Activity(
      id: this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      type: type ?? this.type,
      createdBy: createdBy ?? this.createdBy,
      isPublic: isPublic ?? this.isPublic,
    );
  }
}
