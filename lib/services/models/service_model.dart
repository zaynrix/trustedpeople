// lib/services/service_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

enum ServiceStatus { active, inactive, deleted }

enum ServiceCategory {
  webDevelopment,
  mobileDevelopment,
  graphicDesign,
  marketing,
  writing,
  translation,
  other
}

// Extension to add displayName to ServiceCategory
extension ServiceCategoryExtension on ServiceCategory {
  String get displayName {
    switch (this) {
      case ServiceCategory.webDevelopment:
        return 'تطوير الويب';
      case ServiceCategory.mobileDevelopment:
        return 'تطوير الجوال';
      case ServiceCategory.graphicDesign:
        return 'تصميم الجرافيك';
      case ServiceCategory.marketing:
        return 'التسويق';
      case ServiceCategory.writing:
        return 'الكتابة';
      case ServiceCategory.translation:
        return 'الترجمة';
      case ServiceCategory.other:
        return 'أخرى';
    }
  }
}

class ServiceModel {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final ServiceCategory category;
  final double price;
  final bool isActive;
  final int deliveryTimeInDays;
  final Timestamp createdAt;
  final Timestamp? updatedAt;
  final Map<String, dynamic>? additionalDetails;

  ServiceModel({
    required this.id,
    required this.title,
    required this.description,
    this.imageUrl = '',
    required this.category,
    required this.price,
    this.isActive = true,
    required this.deliveryTimeInDays,
    required this.createdAt,
    this.updatedAt,
    this.additionalDetails,
  });

  factory ServiceModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return ServiceModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      category: _categoryFromString(data['category'] ?? ''),
      price: (data['price'] ?? 0).toDouble(),
      isActive: data['isActive'] ?? true,
      deliveryTimeInDays: data['deliveryTimeInDays'] ?? 1,
      createdAt: data['createdAt'] as Timestamp? ?? Timestamp.now(),
      updatedAt: data['updatedAt'] as Timestamp?,
      additionalDetails: data['additionalDetails'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'category': category.toString().split('.').last,
      'price': price,
      'isActive': isActive,
      'deliveryTimeInDays': deliveryTimeInDays,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'additionalDetails': additionalDetails,
    };
  }

  static ServiceCategory _categoryFromString(String category) {
    for (var value in ServiceCategory.values) {
      if (value.toString().split('.').last == category) {
        return value;
      }
    }
    return ServiceCategory.other;
  }

  ServiceModel copyWith({
    String? id,
    String? title,
    String? description,
    String? imageUrl,
    ServiceCategory? category,
    double? price,
    bool? isActive,
    int? deliveryTimeInDays,
    Timestamp? createdAt,
    Timestamp? updatedAt,
    Map<String, dynamic>? additionalDetails,
  }) {
    return ServiceModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      price: price ?? this.price,
      isActive: isActive ?? this.isActive,
      deliveryTimeInDays: deliveryTimeInDays ?? this.deliveryTimeInDays,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      additionalDetails: additionalDetails ?? this.additionalDetails,
    );
  }
}

enum ServiceRequestStatus { pending, inProgress, completed, cancelled }

// Extension to add displayName to ServiceRequestStatus
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
  final Timestamp createdAt;
  final Timestamp? startedAt;
  final Timestamp? completedAt;
  final String? assignedAdminId;
  final String? assignedAdminName;
  final String? notes;

  ServiceRequestModel({
    required this.id,
    required this.serviceId,
    required this.serviceName,
    required this.clientName,
    required this.clientEmail,
    required this.clientPhone,
    required this.requirements,
    this.status = ServiceRequestStatus.pending,
    required this.createdAt,
    this.startedAt,
    this.completedAt,
    this.assignedAdminId,
    this.assignedAdminName,
    this.notes,
  });

  factory ServiceRequestModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return ServiceRequestModel(
      id: doc.id,
      serviceId: data['serviceId'] ?? '',
      serviceName: data['serviceName'] ?? '',
      clientName: data['clientName'] ?? data['userName'] ?? '',
      clientEmail: data['clientEmail'] ?? data['userEmail'] ?? '',
      clientPhone: data['clientPhone'] ?? data['userPhone'] ?? '',
      requirements: data['requirements'] ?? data['description'] ?? '',
      status: _statusFromString(data['status'] ?? 'pending'),
      createdAt: data['createdAt'] as Timestamp? ?? Timestamp.now(),
      startedAt: data['startedAt'] as Timestamp?,
      completedAt: data['completedAt'] as Timestamp?,
      assignedAdminId: data['assignedAdminId'],
      assignedAdminName: data['assignedAdminName'],
      notes: data['notes'],
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
      'createdAt': createdAt,
      'startedAt': startedAt,
      'completedAt': completedAt,
      'assignedAdminId': assignedAdminId,
      'assignedAdminName': assignedAdminName,
      'notes': notes,
    };
  }

  static ServiceRequestStatus _statusFromString(String status) {
    switch (status) {
      case 'pending':
        return ServiceRequestStatus.pending;
      case 'inProgress':
      case 'processing':
        return ServiceRequestStatus.inProgress;
      case 'completed':
        return ServiceRequestStatus.completed;
      case 'cancelled':
      case 'rejected':
        return ServiceRequestStatus.cancelled;
      default:
        return ServiceRequestStatus.pending;
    }
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
    Timestamp? createdAt,
    Timestamp? startedAt,
    Timestamp? completedAt,
    String? assignedAdminId,
    String? assignedAdminName,
    String? notes,
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
      createdAt: createdAt ?? this.createdAt,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      assignedAdminId: assignedAdminId ?? this.assignedAdminId,
      assignedAdminName: assignedAdminName ?? this.assignedAdminName,
      notes: notes ?? this.notes,
    );
  }
}
