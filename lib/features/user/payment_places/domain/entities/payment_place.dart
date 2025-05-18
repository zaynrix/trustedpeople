// lib/features/user/payment_places/domain/entities/payment_place.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentPlace {
  final String id;
  final String name;
  final String phoneNumber;
  final String location;
  final String category;
  final List<String> paymentMethods;
  final String workingHours;
  final String description;
  final String imageUrl;
  final bool isVerified;
  final double rating;
  final int reviewsCount;

  PaymentPlace({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.location,
    required this.category,
    required this.paymentMethods,
    this.workingHours = '',
    this.description = '',
    this.imageUrl = '',
    this.isVerified = true,
    this.rating = 0.0,
    this.reviewsCount = 0,
  });

  factory PaymentPlace.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return PaymentPlace(
      id: doc.id,
      name: data['name'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      location: data['location'] ?? '',
      category: data['category'] ?? '',
      paymentMethods: List<String>.from(data['paymentMethods'] ?? []),
      workingHours: data['workingHours'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      isVerified: data['isVerified'] ?? true,
      rating: (data['rating'] ?? 0.0).toDouble(),
      reviewsCount: data['reviewsCount'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phoneNumber': phoneNumber,
      'location': location,
      'category': category,
      'paymentMethods': paymentMethods,
      'workingHours': workingHours,
      'description': description,
      'imageUrl': imageUrl,
      'isVerified': isVerified,
      'rating': rating,
      'reviewsCount': reviewsCount,
    };
  }

  PaymentPlace copyWith({
    String? id,
    String? name,
    String? phoneNumber,
    String? location,
    String? category,
    List<String>? paymentMethods,
    String? workingHours,
    String? description,
    String? imageUrl,
    bool? isVerified,
    double? rating,
    int? reviewsCount,
  }) {
    return PaymentPlace(
      id: id ?? this.id,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      location: location ?? this.location,
      category: category ?? this.category,
      paymentMethods: paymentMethods ?? this.paymentMethods,
      workingHours: workingHours ?? this.workingHours,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      isVerified: isVerified ?? this.isVerified,
      rating: rating ?? this.rating,
      reviewsCount: reviewsCount ?? this.reviewsCount,
    );
  }
}
