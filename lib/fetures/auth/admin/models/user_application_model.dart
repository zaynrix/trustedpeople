// user_application_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

// Updated User application model to handle both data structures
class UserApplication {
  final String id;
  final String email;
  final String password;
  final String fullName;
  final String phoneNumber;
  final String? additionalPhone;
  final String serviceProvider;
  final String location;
  final String? telegramAccount;
  final String? description;
  final String? workingHours;
  final String status;
  final String? adminComment;
  final String? firebaseUid;
  final bool accountCreated;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? reviewedAt;
  final String? reviewedBy;
  final DateTime? submittedAt;
  final bool? addedToTrustedTable;

  // Additional fields from users collection
  final bool? canAccessDashboard;
  final bool? canEditProfile;
  final bool? emailVerified;
  final bool? phoneVerified;
  final bool? documentsSubmitted;
  final String? firstName;
  final String? lastName;
  final String? profileImageUrl;
  final String? rejectionReason;

  const UserApplication({
    required this.id,
    required this.email,
    required this.password,
    required this.fullName,
    required this.phoneNumber,
    this.additionalPhone,
    required this.serviceProvider,
    required this.location,
    this.telegramAccount,
    this.description,
    this.workingHours,
    this.status = 'pending',
    this.adminComment,
    this.firebaseUid,
    this.accountCreated = false,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
    this.reviewedAt,
    this.reviewedBy,
    this.submittedAt,
    this.addedToTrustedTable,
    this.canAccessDashboard,
    this.canEditProfile,
    this.emailVerified,
    this.phoneVerified,
    this.documentsSubmitted,
    this.firstName,
    this.lastName,
    this.profileImageUrl,
    this.rejectionReason,
  });

  // Factory constructor for Firestore documents
  factory UserApplication.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      throw Exception('Document data is null');
    }

    return UserApplication._fromData(data, doc.id);
  }

  // Factory constructor for Map data
  factory UserApplication.fromMap(Map<String, dynamic> data,
      [String? documentId]) {
    final id =
        documentId ?? data['documentId'] ?? data['id'] ?? data['uid'] ?? '';
    return UserApplication._fromData(data, id);
  }

  // Private helper method to handle both data structures
  factory UserApplication._fromData(Map<String, dynamic> data, String id) {
    // Check if this is from users collection (has nested structure)
    final hasProfileStructure = data.containsKey('profile');
    final hasApplicationStructure = data.containsKey('application');
    final hasPermissionsStructure = data.containsKey('permissions');
    final hasVerificationStructure = data.containsKey('verification');

    // Extract data based on structure
    String email = data['email'] ?? '';
    String password =
        data['password'] ?? ''; // Usually empty for users collection
    String fullName = '';
    String phoneNumber = '';
    String? additionalPhone;
    String serviceProvider = '';
    String location = '';
    String? telegramAccount;
    String? description;
    String? workingHours;
    String? firstName;
    String? lastName;
    String? profileImageUrl;

    if (hasProfileStructure) {
      // New users collection structure
      final profile = data['profile'] as Map<String, dynamic>? ?? {};
      fullName = profile['fullName'] ?? '';
      firstName = profile['firstName'] ?? '';
      lastName = profile['lastName'] ?? '';
      phoneNumber = profile['phone'] ?? '';
      additionalPhone = profile['additionalPhone'];
      serviceProvider = profile['serviceProvider'] ?? '';
      location = profile['location'] ?? '';
      telegramAccount = profile['telegramAccount'];
      description = profile['bio']; // Note: bio vs description
      workingHours = profile['workingHours'];
      profileImageUrl = profile['profileImageUrl'];
    } else {
      // Old user_applications collection structure (flat)
      fullName = data['fullName'] ?? '';
      phoneNumber = data['phoneNumber'] ?? '';
      additionalPhone = data['additionalPhone'];
      serviceProvider = data['serviceProvider'] ?? '';
      location = data['location'] ?? '';
      telegramAccount = data['telegramAccount'];
      description = data['description'];
      workingHours = data['workingHours'];
      profileImageUrl = data['profileImageUrl'];

      // Extract first and last names from full name if not provided
      if (fullName.isNotEmpty) {
        final nameParts = fullName.split(' ');
        firstName = nameParts.isNotEmpty ? nameParts.first : '';
        lastName = nameParts.length > 1 ? nameParts.skip(1).join(' ') : '';
      }
    }

    // Extract application-related data
    String status = data['status'] ?? 'pending';
    String? adminComment;
    String? reviewedBy;
    DateTime? reviewedAt;
    DateTime? submittedAt;

    if (hasApplicationStructure) {
      // New users collection structure
      final application = data['application'] as Map<String, dynamic>? ?? {};
      adminComment = application['rejectionReason'];
      reviewedBy = application['reviewedBy'];
      submittedAt = _parseTimestamp(application['submittedAt']);
      reviewedAt = _parseTimestamp(application['reviewedAt']);
    } else {
      // Old user_applications collection structure
      adminComment = data['adminComment'] ?? data['rejectionReason'];
      reviewedBy = data['reviewedBy'];
      submittedAt = _parseTimestamp(data['submittedAt']);
      reviewedAt = _parseTimestamp(data['reviewedAt']);
    }

    // Extract permissions
    bool? canAccessDashboard;
    bool? canEditProfile;
    if (hasPermissionsStructure) {
      final permissions = data['permissions'] as Map<String, dynamic>? ?? {};
      canAccessDashboard = permissions['canAccessDashboard'];
      canEditProfile = permissions['canEditProfile'];
    }

    // Extract verification data
    bool? emailVerified;
    bool? phoneVerified;
    bool? documentsSubmitted;
    if (hasVerificationStructure) {
      final verification = data['verification'] as Map<String, dynamic>? ?? {};
      emailVerified = verification['emailVerified'];
      phoneVerified = verification['phoneVerified'];
      documentsSubmitted = verification['documentsSubmitted'];
    }

    // Common fields
    final firebaseUid = data['firebaseUid'] ?? data['uid'];
    final accountCreated =
        data['accountCreated'] ?? (firebaseUid?.isNotEmpty ?? false);
    final isActive = data['isActive'] ?? true;
    final addedToTrustedTable = data['addedToTrustedTable'];

    // Parse timestamps
    final createdAt = _parseTimestamp(data['createdAt']);
    final updatedAt = _parseTimestamp(data['updatedAt']);

    return UserApplication(
      id: id,
      email: email,
      password: password,
      fullName: fullName,
      firstName: firstName,
      lastName: lastName,
      phoneNumber: phoneNumber,
      additionalPhone: additionalPhone,
      serviceProvider: serviceProvider,
      location: location,
      telegramAccount: telegramAccount,
      description: description,
      workingHours: workingHours,
      profileImageUrl: profileImageUrl,
      status: status,
      adminComment: adminComment,
      rejectionReason: adminComment, // Alias for compatibility
      firebaseUid: firebaseUid,
      accountCreated: accountCreated,
      isActive: isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
      reviewedAt: reviewedAt,
      reviewedBy: reviewedBy,
      submittedAt: submittedAt,
      addedToTrustedTable: addedToTrustedTable,
      canAccessDashboard: canAccessDashboard,
      canEditProfile: canEditProfile,
      emailVerified: emailVerified,
      phoneVerified: phoneVerified,
      documentsSubmitted: documentsSubmitted,
    );
  }

  // Helper method to parse timestamps
  static DateTime? _parseTimestamp(dynamic timestamp) {
    if (timestamp == null) return null;

    try {
      if (timestamp is Timestamp) {
        return timestamp.toDate();
      } else if (timestamp is DateTime) {
        return timestamp;
      } else if (timestamp is String) {
        return DateTime.parse(timestamp);
      }
    } catch (e) {
      print('Error parsing timestamp: $e');
    }

    return null;
  }

  // Convert to Firestore format (user_applications collection)
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'password': password,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'additionalPhone': additionalPhone,
      'serviceProvider': serviceProvider,
      'location': location,
      'telegramAccount': telegramAccount,
      'description': description,
      'workingHours': workingHours,
      'status': status,
      'adminComment': adminComment,
      'rejectionReason': rejectionReason ?? adminComment,
      'firebaseUid': firebaseUid,
      'accountCreated': accountCreated,
      'isActive': isActive,
      'applicationId': id,
      'uid': firebaseUid ?? id,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'submittedAt': submittedAt != null
          ? Timestamp.fromDate(submittedAt!)
          : FieldValue.serverTimestamp(),
      'reviewedAt': reviewedAt != null ? Timestamp.fromDate(reviewedAt!) : null,
      'reviewedBy': reviewedBy,
      'addedToTrustedTable': addedToTrustedTable ?? false,
    };
  }

  // Convert to new users collection format
  Map<String, dynamic> toUsersFormat() {
    return {
      'uid': firebaseUid ?? id,
      'email': email.toLowerCase(),
      'status': status,
      'profile': {
        'fullName': fullName,
        'firstName': firstName ?? _extractFirstName(),
        'lastName': lastName ?? _extractLastName(),
        'phone': phoneNumber,
        'additionalPhone': additionalPhone ?? '',
        'serviceProvider': serviceProvider,
        'location': location,
        'telegramAccount': telegramAccount ?? '',
        'bio': description ?? '', // Note: bio vs description
        'workingHours': workingHours ?? '',
        'profileImageUrl': profileImageUrl ?? '',
      },
      'application': {
        'submittedAt': submittedAt != null
            ? Timestamp.fromDate(submittedAt!)
            : FieldValue.serverTimestamp(),
        'reviewedAt':
            reviewedAt != null ? Timestamp.fromDate(reviewedAt!) : null,
        'reviewedBy': reviewedBy,
        'rejectionReason': adminComment ?? rejectionReason ?? '',
      },
      'permissions': {
        'canEditProfile':
            canEditProfile ?? (status.toLowerCase() == 'approved'),
        'canAccessDashboard': canAccessDashboard ?? true,
      },
      'verification': {
        'emailVerified': emailVerified ?? false,
        'phoneVerified': phoneVerified ?? false,
        'documentsSubmitted': documentsSubmitted ?? false,
      },
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  // Helper methods to extract names
  String _extractFirstName() {
    if (firstName?.isNotEmpty == true) return firstName!;
    final nameParts = fullName.split(' ');
    return nameParts.isNotEmpty ? nameParts.first : '';
  }

  String _extractLastName() {
    if (lastName?.isNotEmpty == true) return lastName!;
    final nameParts = fullName.split(' ');
    return nameParts.length > 1 ? nameParts.skip(1).join(' ') : '';
  }

  // Convert to Map (for general use)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'password': password,
      'fullName': fullName,
      'firstName': firstName,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
      'additionalPhone': additionalPhone,
      'serviceProvider': serviceProvider,
      'location': location,
      'telegramAccount': telegramAccount,
      'description': description,
      'workingHours': workingHours,
      'profileImageUrl': profileImageUrl,
      'status': status,
      'adminComment': adminComment,
      'rejectionReason': rejectionReason,
      'firebaseUid': firebaseUid,
      'accountCreated': accountCreated,
      'isActive': isActive,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'reviewedAt': reviewedAt?.toIso8601String(),
      'reviewedBy': reviewedBy,
      'submittedAt': submittedAt?.toIso8601String(),
      'addedToTrustedTable': addedToTrustedTable,
      'canAccessDashboard': canAccessDashboard,
      'canEditProfile': canEditProfile,
      'emailVerified': emailVerified,
      'phoneVerified': phoneVerified,
      'documentsSubmitted': documentsSubmitted,
      'documentId': id,
    };
  }

  // Status getters
  bool get isPending => status.toLowerCase() == 'pending';
  bool get isApproved => status.toLowerCase() == 'approved';
  bool get isRejected => status.toLowerCase() == 'rejected';
  bool get isInProgress => status.toLowerCase() == 'in_progress';
  bool get isSuspended => status.toLowerCase() == 'suspended';

  // Validation getters
  bool get hasFirebaseUid => firebaseUid?.isNotEmpty ?? false;
  bool get canLogin => hasFirebaseUid && (isApproved || isPending);
  bool get requiresReview => isPending && !hasFirebaseUid;
  bool get canEdit => isPending || isInProgress;
  bool get hasCompleteProfile =>
      fullName.isNotEmpty &&
      phoneNumber.isNotEmpty &&
      serviceProvider.isNotEmpty &&
      location.isNotEmpty;

  // Display helpers
  String get statusText {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'في انتظار المراجعة';
      case 'approved':
        return 'معتمد';
      case 'rejected':
        return 'مرفوض';
      case 'in_progress':
        return 'قيد المراجعة';
      case 'suspended':
        return 'معلق';
      default:
        return status;
    }
  }

  String get displayName => fullName.isNotEmpty ? fullName : email;

  String get shortLocation {
    if (location.length > 20) {
      return '${location.substring(0, 17)}...';
    }
    return location;
  }

  // Time helpers
  String get timeAgo {
    final now = DateTime.now();
    final submitTime = submittedAt ?? createdAt;

    if (submitTime == null) return 'غير محدد';

    final difference = now.difference(submitTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} يوم';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ساعة';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} دقيقة';
    } else {
      return 'الآن';
    }
  }

  // Enhanced copyWith method
  UserApplication copyWith({
    String? id,
    String? email,
    String? password,
    String? fullName,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? additionalPhone,
    String? serviceProvider,
    String? location,
    String? telegramAccount,
    String? description,
    String? workingHours,
    String? profileImageUrl,
    String? status,
    String? adminComment,
    String? rejectionReason,
    String? firebaseUid,
    bool? accountCreated,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? reviewedAt,
    String? reviewedBy,
    DateTime? submittedAt,
    bool? addedToTrustedTable,
    bool? canAccessDashboard,
    bool? canEditProfile,
    bool? emailVerified,
    bool? phoneVerified,
    bool? documentsSubmitted,
  }) {
    return UserApplication(
      id: id ?? this.id,
      email: email ?? this.email,
      password: password ?? this.password,
      fullName: fullName ?? this.fullName,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      additionalPhone: additionalPhone ?? this.additionalPhone,
      serviceProvider: serviceProvider ?? this.serviceProvider,
      location: location ?? this.location,
      telegramAccount: telegramAccount ?? this.telegramAccount,
      description: description ?? this.description,
      workingHours: workingHours ?? this.workingHours,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      status: status ?? this.status,
      adminComment: adminComment ?? this.adminComment,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      firebaseUid: firebaseUid ?? this.firebaseUid,
      accountCreated: accountCreated ?? this.accountCreated,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      reviewedBy: reviewedBy ?? this.reviewedBy,
      submittedAt: submittedAt ?? this.submittedAt,
      addedToTrustedTable: addedToTrustedTable ?? this.addedToTrustedTable,
      canAccessDashboard: canAccessDashboard ?? this.canAccessDashboard,
      canEditProfile: canEditProfile ?? this.canEditProfile,
      emailVerified: emailVerified ?? this.emailVerified,
      phoneVerified: phoneVerified ?? this.phoneVerified,
      documentsSubmitted: documentsSubmitted ?? this.documentsSubmitted,
    );
  }

  // Validation method
  String? validate() {
    if (email.isEmpty) return 'البريد الإلكتروني مطلوب';
    if (fullName.isEmpty) return 'الاسم الكامل مطلوب';
    if (phoneNumber.isEmpty) return 'رقم الهاتف مطلوب';
    if (serviceProvider.isEmpty) return 'نوع الخدمة مطلوب';
    if (location.isEmpty) return 'الموقع مطلوب';

    // Email validation
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      return 'البريد الإلكتروني غير صحيح';
    }

    // Phone validation (basic)
    if (phoneNumber.length < 8) {
      return 'رقم الهاتف قصير جداً';
    }

    return null; // No validation errors
  }

  // Static helper methods
  static List<UserApplication> fromMapList(List<Map<String, dynamic>> mapList) {
    return mapList.map((data) {
      final documentId = data['documentId'] ?? data['id'] ?? data['uid'] ?? '';
      return UserApplication.fromMap(data, documentId);
    }).toList();
  }

  static List<UserApplication> fromFirestoreList(List<DocumentSnapshot> docs) {
    return docs.map((doc) => UserApplication.fromFirestore(doc)).toList();
  }

  // Filter methods (unchanged)
  static List<UserApplication> filterByStatus(
      List<UserApplication> applications, String status) {
    return applications
        .where((app) => app.status.toLowerCase() == status.toLowerCase())
        .toList();
  }

  static List<UserApplication> filterPending(
      List<UserApplication> applications) {
    return applications.where((app) => app.isPending).toList();
  }

  static List<UserApplication> filterApproved(
      List<UserApplication> applications) {
    return applications.where((app) => app.isApproved).toList();
  }

  static List<UserApplication> filterRejected(
      List<UserApplication> applications) {
    return applications.where((app) => app.isRejected).toList();
  }

  // Sort methods (unchanged)
  static List<UserApplication> sortByDate(List<UserApplication> applications,
      {bool descending = true}) {
    final sorted = List<UserApplication>.from(applications);
    sorted.sort((a, b) {
      final aDate = a.submittedAt ?? a.createdAt ?? DateTime.now();
      final bDate = b.submittedAt ?? b.createdAt ?? DateTime.now();
      return descending ? bDate.compareTo(aDate) : aDate.compareTo(bDate);
    });
    return sorted;
  }

  static List<UserApplication> sortByName(List<UserApplication> applications,
      {bool descending = false}) {
    final sorted = List<UserApplication>.from(applications);
    sorted.sort((a, b) {
      final comparison = a.fullName.compareTo(b.fullName);
      return descending ? -comparison : comparison;
    });
    return sorted;
  }

  @override
  String toString() {
    return 'UserApplication(id: $id, email: $email, fullName: $fullName, status: $status, firebaseUid: $firebaseUid, hasProfile: ${firstName != null}, hasPermissions: ${canEditProfile != null})';
  }
}
