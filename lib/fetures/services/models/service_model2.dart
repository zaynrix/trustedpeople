// // lib/fetures/fetures/services/models/service_model2.dart
// import 'package:cloud_firestore/cloud_firestore.dart';
//
// enum ServiceStatus {
//   active, // Service is available for ordering
//   inactive, // Service temporarily unavailable
//   deleted // Service has been removed
// }
//
// class ServiceModel {
//   final String id;
//   final String title;
//   final String description;
//   final String imageUrl;
//   final String category;
//   final double price;
//   final double rating;
//   final int reviewsCount;
//   final int orderCount;
//   final int estimatedTimeMinutes; // Estimated completion time in minutes
//   final ServiceStatus status;
//   final DateTime createdAt;
//   final DateTime? updatedAt;
//
//   ServiceModel({
//     required this.id,
//     required this.title,
//     required this.description,
//     this.imageUrl = '',
//     required this.category,
//     required this.price,
//     this.rating = 0.0,
//     this.reviewsCount = 0,
//     this.orderCount = 0,
//     required this.estimatedTimeMinutes,
//     this.status = ServiceStatus.active,
//     required this.createdAt,
//     this.updatedAt,
//   });
//
//   factory ServiceModel.fromFirestore(DocumentSnapshot doc) {
//     final data = doc.data() as Map<String, dynamic>? ?? {};
//
//     return ServiceModel(
//       id: doc.id,
//       title: data['title'] ?? '',
//       description: data['description'] ?? '',
//       imageUrl: data['imageUrl'] ?? '',
//       category: data['category'] ?? '',
//       price: (data['price'] ?? 0).toDouble(),
//       rating: (data['rating'] ?? 0).toDouble(),
//       reviewsCount: data['reviewsCount'] ?? 0,
//       orderCount: data['orderCount'] ?? 0,
//       estimatedTimeMinutes: data['estimatedTimeMinutes'] ?? 30,
//       status: _statusFromString(data['status'] ?? 'active'),
//       createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
//       updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
//     );
//   }
//
//   Map<String, dynamic> toMap() {
//     return {
//       'title': title,
//       'description': description,
//       'imageUrl': imageUrl,
//       'category': category,
//       'price': price,
//       'rating': rating,
//       'reviewsCount': reviewsCount,
//       'orderCount': orderCount,
//       'estimatedTimeMinutes': estimatedTimeMinutes,
//       'status': status.toString().split('.').last,
//       'createdAt': Timestamp.fromDate(createdAt),
//       'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
//     };
//   }
//
//   static ServiceStatus _statusFromString(String status) {
//     switch (status) {
//       case 'active':
//         return ServiceStatus.active;
//       case 'inactive':
//         return ServiceStatus.inactive;
//       case 'deleted':
//         return ServiceStatus.deleted;
//       default:
//         return ServiceStatus.active;
//     }
//   }
//
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
//
// // lib/fetures/fetures/services/models/service_request_model.dart
//
// enum RequestStatus {
//   pending, // Just submitted, waiting for admin response
//   processing, // Admin has started working on it
//   completed, // Service has been completed
//   rejected, // Request was rejected by admin
//   cancelled // Cancelled by user
// }
//
// class ServiceRequestModel {
//   final String id;
//   final String serviceId;
//   final String serviceName;
//   final String userName;
//   final String userEmail;
//   final String userPhone;
//   final String description;
//   final RequestStatus status;
//   final DateTime createdAt;
//   final DateTime? startedAt;
//   final DateTime? completedAt;
//   final String? assignedToAdminId;
//   final String? assignedToAdminName;
//   final String? notes; // Admin notes about the request
//
//   ServiceRequestModel({
//     required this.id,
//     required this.serviceId,
//     required this.serviceName,
//     required this.userName,
//     required this.userEmail,
//     required this.userPhone,
//     required this.description,
//     this.status = RequestStatus.pending,
//     required this.createdAt,
//     this.startedAt,
//     this.completedAt,
//     this.assignedToAdminId,
//     this.assignedToAdminName,
//     this.notes,
//   });
//
//   factory ServiceRequestModel.fromFirestore(DocumentSnapshot doc) {
//     final data = doc.data() as Map<String, dynamic>? ?? {};
//
//     return ServiceRequestModel(
//       id: doc.id,
//       serviceId: data['serviceId'] ?? '',
//       serviceName: data['serviceName'] ?? '',
//       userName: data['userName'] ?? '',
//       userEmail: data['userEmail'] ?? '',
//       userPhone: data['userPhone'] ?? '',
//       description: data['description'] ?? '',
//       status: _statusFromString(data['status'] ?? 'pending'),
//       createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
//       startedAt: (data['startedAt'] as Timestamp?)?.toDate(),
//       completedAt: (data['completedAt'] as Timestamp?)?.toDate(),
//       assignedToAdminId: data['assignedToAdminId'],
//       assignedToAdminName: data['assignedToAdminName'],
//       notes: data['notes'],
//     );
//   }
//
//   Map<String, dynamic> toMap() {
//     return {
//       'serviceId': serviceId,
//       'serviceName': serviceName,
//       'userName': userName,
//       'userEmail': userEmail,
//       'userPhone': userPhone,
//       'description': description,
//       'status': status.toString().split('.').last,
//       'createdAt': Timestamp.fromDate(createdAt),
//       'startedAt': startedAt != null ? Timestamp.fromDate(startedAt!) : null,
//       'completedAt':
//           completedAt != null ? Timestamp.fromDate(completedAt!) : null,
//       'assignedToAdminId': assignedToAdminId,
//       'assignedToAdminName': assignedToAdminName,
//       'notes': notes,
//     };
//   }
//
//   static RequestStatus _statusFromString(String status) {
//     switch (status) {
//       case 'pending':
//         return RequestStatus.pending;
//       case 'processing':
//         return RequestStatus.processing;
//       case 'completed':
//         return RequestStatus.completed;
//       case 'rejected':
//         return RequestStatus.rejected;
//       case 'cancelled':
//         return RequestStatus.cancelled;
//       default:
//         return RequestStatus.pending;
//     }
//   }
//
//   ServiceRequestModel copyWith({
//     String? id,
//     String? serviceId,
//     String? serviceName,
//     String? userName,
//     String? userEmail,
//     String? userPhone,
//     String? description,
//     RequestStatus? status,
//     DateTime? createdAt,
//     DateTime? startedAt,
//     DateTime? completedAt,
//     String? assignedToAdminId,
//     String? assignedToAdminName,
//     String? notes,
//   }) {
//     return ServiceRequestModel(
//       id: id ?? this.id,
//       serviceId: serviceId ?? this.serviceId,
//       serviceName: serviceName ?? this.serviceName,
//       userName: userName ?? this.userName,
//       userEmail: userEmail ?? this.userEmail,
//       userPhone: userPhone ?? this.userPhone,
//       description: description ?? this.description,
//       status: status ?? this.status,
//       createdAt: createdAt ?? this.createdAt,
//       startedAt: startedAt ?? this.startedAt,
//       completedAt: completedAt ?? this.completedAt,
//       assignedToAdminId: assignedToAdminId ?? this.assignedToAdminId,
//       assignedToAdminName: assignedToAdminName ?? this.assignedToAdminName,
//       notes: notes ?? this.notes,
//     );
//   }
// }
