// lib/fetures/Services/models/service_model2.dart
import 'package:cloud_firestore/cloud_firestore.dart';

import 'models/service_model.dart';

enum ServiceCategory {
  webDevelopment,
  mobileDevelopment,
  graphicDesign,
  marketing,
  writing,
  translation,
  other
}

extension ServiceCategoryExtension on ServiceCategory {
  String get displayName {
    switch (this) {
      case ServiceCategory.webDevelopment:
        return 'تطوير الويب';
      case ServiceCategory.mobileDevelopment:
        return 'تطوير التطبيقات';
      case ServiceCategory.graphicDesign:
        return 'تصميم جرافيك';
      case ServiceCategory.marketing:
        return 'تسويق';
      case ServiceCategory.writing:
        return 'كتابة محتوى';
      case ServiceCategory.translation:
        return 'ترجمة';
      case ServiceCategory.other:
        return 'خدمات أخرى';
    }
  }

  static ServiceCategory fromString(String value) {
    return ServiceCategory.values.firstWhere(
      (e) => e.toString().split('.').last == value,
      orElse: () => ServiceCategory.other,
    );
  }
}

class ServiceModel {
  final String id;
  final String title;
  final String description;
  final ServiceCategory category;
  final double price;
  final String imageUrl;
  final bool isActive;
  final int deliveryTimeInDays;
  final Map<String, dynamic>? additionalDetails;
  final Timestamp createdAt;

  ServiceModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.price,
    required this.imageUrl,
    required this.isActive,
    required this.deliveryTimeInDays,
    this.additionalDetails,
    required this.createdAt,
  });

  factory ServiceModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ServiceModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      category: ServiceCategoryExtension.fromString(data['category'] ?? ''),
      price: (data['price'] ?? 0).toDouble(),
      imageUrl: data['imageUrl'] ?? '',
      isActive: data['isActive'] ?? true,
      deliveryTimeInDays: data['deliveryTimeInDays'] ?? 1,
      additionalDetails: data['additionalDetails'],
      createdAt: data['createdAt'] ?? Timestamp.now(),
    );
  }
  ServiceModel copyWith({
    String? id,
    String? title,
    String? description,
    String? imageUrl,
    String? category,
    double? price,
    double? rating,
    int? reviewsCount,
    int? orderCount,
    int? estimatedTimeMinutes,
    ServiceStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ServiceModel(
      id: id ?? this.id,
      isActive: isActive ?? this.isActive,
      deliveryTimeInDays: deliveryTimeInDays,
      category: ServiceCategory.graphicDesign,
      createdAt: Timestamp.fromDate(DateTime.now()),
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      price: price ?? this.price,
    );
  }

//   ServiceModel copyWith({
//     String? id,
//     String? title,
//     String? description,
//     String? imageUrl,
//     String? category,
//     double? price,
//     double? rating,
//     int? reviewsCount,
//     int? orderCount,
//     int? estimatedTimeMinutes,
//     ServiceStatus? status,
//     DateTime? createdAt,
//     DateTime? updatedAt,
//   }) {
//     return ServiceModel(
//       id: id ?? this.id,
//       title: title ?? this.title,
//       description: description ?? this.description,
//       imageUrl: imageUrl ?? this.imageUrl,
//       category: category ?? this.category,
//       price: price ?? this.price,
//       rating: rating ?? this.rating,
//       reviewsCount: reviewsCount ?? this.reviewsCount,
//       orderCount: orderCount ?? this.orderCount,
//       estimatedTimeMinutes: estimatedTimeMinutes ?? this.estimatedTimeMinutes,
//       status: status ?? this.status,
//       createdAt: createdAt ?? this.createdAt,
//       updatedAt: updatedAt ?? this.updatedAt,
//     );
//   }
// }
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'category': category.toString().split('.').last,
      'price': price,
      'imageUrl': imageUrl,
      'isActive': isActive,
      'deliveryTimeInDays': deliveryTimeInDays,
      'additionalDetails': additionalDetails,
      'createdAt': createdAt,
    };
  }
}

// lib/fetures/Services/models/service_request_model.dart
// import 'package:cloud_firestore/cloud_firestore.dart';

enum ServiceRequestStatus { pending, inProgress, completed, cancelled }

extension ServiceRequestStatusExtension on ServiceRequestStatus {
  String get displayName {
    switch (this) {
      case ServiceRequestStatus.pending:
        return 'قيد الانتظار';
      case ServiceRequestStatus.inProgress:
        return 'قيد التنفيذ';
      case ServiceRequestStatus.completed:
        return 'مكتمل';
      case ServiceRequestStatus.cancelled:
        return 'ملغي';
    }
  }

  static ServiceRequestStatus fromString(String value) {
    return ServiceRequestStatus.values.firstWhere(
      (e) => e.toString().split('.').last == value,
      orElse: () => ServiceRequestStatus.pending,
    );
  }
}

class ServiceRequestModel {
  final String id;
  final String serviceId;
  final String serviceName;
  final String clientName;
  final String clientEmail;
  final String clientPhone;
  final String requirements;
  final ServiceRequestStatus status;
  final String? assignedAdminId;
  final String? assignedAdminName;
  final Timestamp createdAt;
  final Timestamp? startedAt;
  final Timestamp? completedAt;

  ServiceRequestModel({
    required this.id,
    required this.serviceId,
    required this.serviceName,
    required this.clientName,
    required this.clientEmail,
    required this.clientPhone,
    required this.requirements,
    required this.status,
    this.assignedAdminId,
    this.assignedAdminName,
    required this.createdAt,
    this.startedAt,
    this.completedAt,
  });

  factory ServiceRequestModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ServiceRequestModel(
      id: doc.id,
      serviceId: data['serviceId'] ?? '',
      serviceName: data['serviceName'] ?? '',
      clientName: data['clientName'] ?? '',
      clientEmail: data['clientEmail'] ?? '',
      clientPhone: data['clientPhone'] ?? '',
      requirements: data['requirements'] ?? '',
      status: ServiceRequestStatusExtension.fromString(data['status'] ?? ''),
      assignedAdminId: data['assignedAdminId'],
      assignedAdminName: data['assignedAdminName'],
      createdAt: data['createdAt'] ?? Timestamp.now(),
      startedAt: data['startedAt'],
      completedAt: data['completedAt'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'serviceId': serviceId,
      'serviceName': serviceName,
      'clientName': clientName,
      'clientEmail': clientEmail,
      'clientPhone': clientPhone,
      'requirements': requirements,
      'status': status.toString().split('.').last,
      'assignedAdminId': assignedAdminId,
      'assignedAdminName': assignedAdminName,
      'createdAt': createdAt,
      'startedAt': startedAt,
      'completedAt': completedAt,
    };
  }

  ServiceRequestModel copyWith({
    String? id,
    String? serviceId,
    String? serviceName,
    String? clientName,
    String? clientEmail,
    String? clientPhone,
    String? requirements,
    ServiceRequestStatus? status,
    String? assignedAdminId,
    String? assignedAdminName,
    Timestamp? createdAt,
    Timestamp? startedAt,
    Timestamp? completedAt,
  }) {
    return ServiceRequestModel(
      id: id ?? this.id,
      serviceId: serviceId ?? this.serviceId,
      serviceName: serviceName ?? this.serviceName,
      clientName: clientName ?? this.clientName,
      clientEmail: clientEmail ?? this.clientEmail,
      clientPhone: clientPhone ?? this.clientPhone,
      requirements: requirements ?? this.requirements,
      status: status ?? this.status,
      assignedAdminId: assignedAdminId ?? this.assignedAdminId,
      assignedAdminName: assignedAdminName ?? this.assignedAdminName,
      createdAt: createdAt ?? this.createdAt,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}
