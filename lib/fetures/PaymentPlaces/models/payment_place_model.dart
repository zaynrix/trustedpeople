// lib/fetures/PaymentPlaces/models/payment_place_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentPlaceModel {
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

  PaymentPlaceModel({
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

  factory PaymentPlaceModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return PaymentPlaceModel(
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
}
