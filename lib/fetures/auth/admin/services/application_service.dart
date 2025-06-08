// application_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class ApplicationService {
  final FirebaseFirestore _firestore;

  ApplicationService(this._firestore);

  // Get all applications
  Future<List<Map<String, dynamic>>> getAllApplications() async {
    try {
      print('📋 Loading all applications');

      final querySnapshot = await _firestore
          .collection('user_applications')
          .orderBy('createdAt', descending: true)
          .get();

      final applications = querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['documentId'] = doc.id;
        return data;
      }).toList();

      print('📋 Loaded ${applications.length} applications');
      return applications;
    } catch (e) {
      print('📋 Error loading applications: $e');
      rethrow;
    }
  }

  // Get application by ID
  Future<Map<String, dynamic>?> getApplicationById(String applicationId) async {
    try {
      print('📋 Getting application by ID: $applicationId');

      final doc = await _firestore
          .collection('user_applications')
          .doc(applicationId)
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        data['documentId'] = doc.id;
        return data;
      }

      return null;
    } catch (e) {
      print('📋 Error getting application by ID: $e');
      rethrow;
    }
  }

  // Get application by email
  Future<Map<String, dynamic>?> getApplicationByEmail(String email) async {
    try {
      print('📋 Getting application by email: $email');

      final querySnapshot = await _firestore
          .collection('user_applications')
          .where('email', isEqualTo: email.toLowerCase())
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        final data = doc.data();
        data['documentId'] = doc.id;
        return data;
      }

      return null;
    } catch (e) {
      print('📋 Error getting application by email: $e');
      rethrow;
    }
  }

  // Submit new application
  Future<String> submitApplication({
    required String fullName,
    required String email,
    required String password,
    required String phoneNumber,
    String? additionalPhone,
    required String serviceProvider,
    required String location,
    String? telegramAccount,
    String? description,
    String? workingHours,
  }) async {
    try {
      print('📝 Submitting new application for: $email');

      // Check if email is already registered
      final existingApplication = await getApplicationByEmail(email);
      if (existingApplication != null) {
        throw Exception('البريد الإلكتروني مسجل مسبقاً');
      }

      // Create application document
      final applicationData = {
        'fullName': fullName,
        'email': email.toLowerCase(),
        'password': password, // In production, hash this password
        'phoneNumber': phoneNumber,
        'additionalPhone': additionalPhone ?? '',
        'serviceProvider': serviceProvider,
        'location': location,
        'telegramAccount': telegramAccount ?? '',
        'description': description ?? '',
        'workingHours': workingHours ?? '',
        'status': 'pending',
        'adminComment': '',
        'isApproved': false,
        'isActive': true,
        'role': 'trusted',
        'applicationId': '',
        'firebaseUid': '',
        'accountCreated': false,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'submittedAt': FieldValue.serverTimestamp(),
        'reviewedAt': null,
        'reviewedBy': '',
        'lastLoginAt': null,
        'profileCompleted': true,
        'emailVerified': false,
        'phoneVerified': false,
        'documentsSubmitted': false,
        'applicationNotes': '',
        'rejectionReason': '',
        'approvalDate': null,
        'version': '1.0',
        'addedToTrustedTable': false,
      };

      final docRef =
          await _firestore.collection('user_applications').add(applicationData);

      // Update with document ID
      await docRef.update({
        'uid': docRef.id,
        'applicationId': docRef.id,
      });

      print('📝 Application submitted successfully with ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('📝 Error submitting application: $e');
      rethrow;
    }
  }

  // Update application
  Future<void> updateApplication({
    required String email,
    String? fullName,
    String? phoneNumber,
    String? additionalPhone,
    String? serviceProvider,
    String? location,
    String? telegramAccount,
    String? description,
    String? workingHours,
  }) async {
    try {
      print('📝 Updating application for email: $email');

      // Find application by email
      final application = await getApplicationByEmail(email);
      if (application == null) {
        throw Exception('لم يتم العثور على طلب التسجيل بهذا البريد الإلكتروني');
      }

      final applicationId = application['documentId'];
      print('📝 Found application: $applicationId');

      // Prepare update data
      final Map<String, dynamic> updateData = {
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (fullName != null && fullName.isNotEmpty) {
        updateData['fullName'] = fullName;
      }
      if (phoneNumber != null && phoneNumber.isNotEmpty) {
        updateData['phoneNumber'] = phoneNumber;
      }
      if (additionalPhone != null) {
        updateData['additionalPhone'] = additionalPhone;
      }
      if (serviceProvider != null && serviceProvider.isNotEmpty) {
        updateData['serviceProvider'] = serviceProvider;
      }
      if (location != null && location.isNotEmpty) {
        updateData['location'] = location;
      }
      if (telegramAccount != null) {
        updateData['telegramAccount'] = telegramAccount;
      }
      if (description != null) {
        updateData['description'] = description;
      }
      if (workingHours != null) {
        updateData['workingHours'] = workingHours;
      }

      if (updateData.length > 1) {
        // More than just updatedAt
        await _firestore
            .collection('user_applications')
            .doc(applicationId)
            .update(updateData);

        print('📝 Application updated successfully');
      } else {
        print('📝 No changes detected, skipping update');
      }
    } catch (e) {
      print('📝 Error updating application: $e');
      rethrow;
    }
  }

  // Update application status
  Future<void> updateApplicationStatus(
    String applicationId,
    String status, {
    String? comment,
    String? reviewedBy,
  }) async {
    try {
      print('📝 Updating application status');
      print('  - Application ID: $applicationId');
      print('  - New Status: $status');

      final updateData = {
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
        'reviewedAt': FieldValue.serverTimestamp(),
      };

      if (comment != null && comment.isNotEmpty) {
        updateData['adminComment'] = comment;
      }

      if (reviewedBy != null) {
        updateData['reviewedBy'] = reviewedBy;
      }

      if (status.toLowerCase() == 'approved') {
        updateData['approvalDate'] = FieldValue.serverTimestamp();
        updateData['isApproved'] = true;
      } else if (status.toLowerCase() == 'rejected') {
        updateData['isApproved'] = false;
        if (comment != null) {
          updateData['rejectionReason'] = comment;
        }
      }

      await _firestore
          .collection('user_applications')
          .doc(applicationId)
          .update(updateData);

      print('📝 Application status updated successfully');
    } catch (e) {
      print('📝 Error updating application status: $e');
      rethrow;
    }
  }

  // Delete application
  Future<void> deleteApplication(String applicationId) async {
    try {
      print('📝 Deleting application: $applicationId');

      await _firestore
          .collection('user_applications')
          .doc(applicationId)
          .delete();

      print('📝 Application deleted successfully');
    } catch (e) {
      print('📝 Error deleting application: $e');
      rethrow;
    }
  }

  // Get applications by status
  Future<List<Map<String, dynamic>>> getApplicationsByStatus(
      String status) async {
    try {
      print('📋 Getting applications by status: $status');

      final querySnapshot = await _firestore
          .collection('user_applications')
          .where('status', isEqualTo: status)
          .orderBy('createdAt', descending: true)
          .get();

      final applications = querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['documentId'] = doc.id;
        return data;
      }).toList();

      print(
          '📋 Found ${applications.length} applications with status: $status');
      return applications;
    } catch (e) {
      print('📋 Error getting applications by status: $e');
      rethrow;
    }
  }

  // Get pending applications
  Future<List<Map<String, dynamic>>> getPendingApplications() async {
    return await getApplicationsByStatus('pending');
  }

  // Get approved applications
  Future<List<Map<String, dynamic>>> getApprovedApplications() async {
    return await getApplicationsByStatus('approved');
  }

  // Get application statistics
  Future<Map<String, int>> getApplicationStatistics() async {
    try {
      print('📊 Getting application statistics');

      final applications =
          await _firestore.collection('user_applications').get();

      final stats = <String, int>{
        'total': applications.docs.length,
        'pending': 0,
        'in_progress': 0,
        'approved': 0,
        'rejected': 0,
        'needs_review': 0,
      };

      for (final doc in applications.docs) {
        final status = doc.data()['status'] ?? 'pending';
        stats[status] = (stats[status] ?? 0) + 1;
      }

      print('📊 Statistics: $stats');
      return stats;
    } catch (e) {
      print('📊 Error getting statistics: $e');
      return {
        'total': 0,
        'pending': 0,
        'in_progress': 0,
        'approved': 0,
        'rejected': 0,
        'needs_review': 0,
      };
    }
  }

  // Search applications
  Future<List<Map<String, dynamic>>> searchApplications(
      String searchTerm) async {
    try {
      print('🔍 Searching applications for: $searchTerm');

      final searchTermLower = searchTerm.toLowerCase();

      // Get all applications (since Firestore doesn't support case-insensitive search)
      final querySnapshot = await _firestore
          .collection('user_applications')
          .orderBy('createdAt', descending: true)
          .get();

      final applications = querySnapshot.docs.where((doc) {
        final data = doc.data();
        final fullName = (data['fullName'] ?? '').toString().toLowerCase();
        final email = (data['email'] ?? '').toString().toLowerCase();
        final phoneNumber =
            (data['phoneNumber'] ?? '').toString().toLowerCase();
        final serviceProvider =
            (data['serviceProvider'] ?? '').toString().toLowerCase();
        final location = (data['location'] ?? '').toString().toLowerCase();

        return fullName.contains(searchTermLower) ||
            email.contains(searchTermLower) ||
            phoneNumber.contains(searchTermLower) ||
            serviceProvider.contains(searchTermLower) ||
            location.contains(searchTermLower);
      }).map((doc) {
        final data = doc.data();
        data['documentId'] = doc.id;
        return data;
      }).toList();

      print('🔍 Found ${applications.length} matching applications');
      return applications;
    } catch (e) {
      print('🔍 Error searching applications: $e');
      rethrow;
    }
  }

  // Bulk update applications
  Future<void> bulkUpdateApplications(
    List<String> applicationIds,
    Map<String, dynamic> updateData,
  ) async {
    try {
      print('📝 Bulk updating ${applicationIds.length} applications');

      final batch = _firestore.batch();

      for (final applicationId in applicationIds) {
        final docRef =
            _firestore.collection('user_applications').doc(applicationId);
        batch.update(docRef, {
          ...updateData,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
      print('📝 Bulk update completed successfully');
    } catch (e) {
      print('📝 Error in bulk update: $e');
      rethrow;
    }
  }

  // Get applications requiring review
  Future<List<Map<String, dynamic>>> getApplicationsRequiringReview() async {
    try {
      print('📋 Getting applications requiring review');

      final querySnapshot = await _firestore
          .collection('user_applications')
          .where('status', whereIn: ['pending', 'needs_review'])
          .orderBy('createdAt', descending: false) // Oldest first for review
          .get();

      final applications = querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['documentId'] = doc.id;
        return data;
      }).toList();

      print('📋 Found ${applications.length} applications requiring review');
      return applications;
    } catch (e) {
      print('📋 Error getting applications requiring review: $e');
      rethrow;
    }
  }

  // Get recent applications
  Future<List<Map<String, dynamic>>> getRecentApplications(
      {int limit = 10}) async {
    try {
      print('📋 Getting $limit recent applications');

      final querySnapshot = await _firestore
          .collection('user_applications')
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      final applications = querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['documentId'] = doc.id;
        return data;
      }).toList();

      print('📋 Found ${applications.length} recent applications');
      return applications;
    } catch (e) {
      print('📋 Error getting recent applications: $e');
      rethrow;
    }
  }

  // Get application status with formatted timestamps
  Future<Map<String, dynamic>> getApplicationStatus(String email) async {
    try {
      final application = await getApplicationByEmail(email);

      if (application == null) {
        throw Exception('لم يتم العثور على طلب بهذا البريد الإلكتروني');
      }

      // Convert Firestore timestamps to strings
      if (application['createdAt'] != null) {
        application['createdAt'] =
            (application['createdAt'] as Timestamp).toDate().toIso8601String();
      }
      if (application['updatedAt'] != null) {
        application['updatedAt'] =
            (application['updatedAt'] as Timestamp).toDate().toIso8601String();
      }
      if (application['reviewedAt'] != null) {
        application['reviewedAt'] =
            (application['reviewedAt'] as Timestamp).toDate().toIso8601String();
      }
      if (application['approvalDate'] != null) {
        application['approvalDate'] = (application['approvalDate'] as Timestamp)
            .toDate()
            .toIso8601String();
      }

      return application;
    } catch (e) {
      rethrow;
    }
  }

  // Check if email exists in applications
  Future<bool> emailExists(String email) async {
    try {
      final application = await getApplicationByEmail(email);
      return application != null;
    } catch (e) {
      return false;
    }
  }

  // Get applications by date range
  Future<List<Map<String, dynamic>>> getApplicationsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      print(
          '📋 Getting applications from ${startDate.toIso8601String()} to ${endDate.toIso8601String()}');

      final querySnapshot = await _firestore
          .collection('user_applications')
          .where('createdAt',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .orderBy('createdAt', descending: true)
          .get();

      final applications = querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['documentId'] = doc.id;
        return data;
      }).toList();

      print('📋 Found ${applications.length} applications in date range');
      return applications;
    } catch (e) {
      print('📋 Error getting applications by date range: $e');
      rethrow;
    }
  }

  // Get application metrics for dashboard
  Future<Map<String, dynamic>> getApplicationMetrics() async {
    try {
      print('📊 Getting application metrics');

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final weekAgo = today.subtract(const Duration(days: 7));
      final monthAgo = today.subtract(const Duration(days: 30));

      // Get all applications
      final allApps = await _firestore.collection('user_applications').get();

      // Get today's applications
      final todayApps = await getApplicationsByDateRange(today, now);

      // Get this week's applications
      final weekApps = await getApplicationsByDateRange(weekAgo, now);

      // Get this month's applications
      final monthApps = await getApplicationsByDateRange(monthAgo, now);

      // Calculate metrics
      final stats = await getApplicationStatistics();

      final metrics = {
        'total': stats['total'],
        'pending': stats['pending'],
        'approved': stats['approved'],
        'rejected': stats['rejected'],
        'todayCount': todayApps.length,
        'weekCount': weekApps.length,
        'monthCount': monthApps.length,
        'approvalRate': stats['total']! > 0
            ? (stats['approved']! / stats['total']! * 100).toStringAsFixed(1)
            : '0.0',
        'pendingRate': stats['total']! > 0
            ? (stats['pending']! / stats['total']! * 100).toStringAsFixed(1)
            : '0.0',
      };

      print('📊 Metrics: $metrics');
      return metrics;
    } catch (e) {
      print('📊 Error getting application metrics: $e');
      return {
        'total': 0,
        'pending': 0,
        'approved': 0,
        'rejected': 0,
        'todayCount': 0,
        'weekCount': 0,
        'monthCount': 0,
        'approvalRate': '0.0',
        'pendingRate': '0.0',
      };
    }
  }
}
