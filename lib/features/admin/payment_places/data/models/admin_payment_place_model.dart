import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/admin_payment_place.dart';

class AdminPaymentPlaceModel extends AdminPaymentPlace {
  const AdminPaymentPlaceModel({
    required String id,
    required String name,
    required String phoneNumber,
    required String location,
    required String category,
    required List<String> paymentMethods,
    String workingHours = '',
    String description = '',
    String imageUrl = '',
    bool isVerified = true,
    double rating = 0.0,
    int reviewsCount = 0,
  }) : super(
    id: id,
    name: name,
    phoneNumber: phoneNumber,
    location: location,
    category: category,
    paymentMethods: paymentMethods,
    workingHours: workingHours,
    description: description,
    imageUrl: imageUrl,
    isVerified: isVerified,
    rating: rating,
    reviewsCount: reviewsCount,

  );

  factory AdminPaymentPlaceModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return AdminPaymentPlaceModel(
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

  factory AdminPaymentPlaceModel.fromEntity(AdminPaymentPlace place) {
    return AdminPaymentPlaceModel(
      id: place.id,
      name: place.name,
      phoneNumber: place.phoneNumber,
      location: place.location,
      category: place.category,
      paymentMethods: place.paymentMethods,
      workingHours: place.workingHours,
      description: place.description,
      imageUrl: place.imageUrl,
      isVerified: place.isVerified,
      rating: place.rating,
      reviewsCount: place.reviewsCount,
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

  // For new document creation
  Map<String, dynamic> toMapWithCreatedAt() {
    return {
      ...toMap(),
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  // Create a new model with updated verification status
  AdminPaymentPlaceModel copyWithVerificationStatus(bool isVerified) {
    return AdminPaymentPlaceModel(
      id: id,
      name: name,
      phoneNumber: phoneNumber,
      location: location,
      category: category,
      paymentMethods: paymentMethods,
      workingHours: workingHours,
      description: description,
      imageUrl: imageUrl,
      isVerified: isVerified,
      rating: rating,
      reviewsCount: reviewsCount,

    );
  }
}