// trusted_user_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TrustedUserService {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  TrustedUserService(this._auth, this._firestore);

  // Sign in trusted user with improved error handling
  Future<Map<String, dynamic>> signInTrustedUser(
      String email, String password) async {
    try {
      print('🔐 =================================');
      print('🔐 TRUSTED USER SIGN IN');
      print('🔐 =================================');
      print('🔐 Email: $email');

      final emailLower = email.toLowerCase().trim();

      // Step 1: Try Firebase Authentication first
      UserCredential? userCredential;
      bool firebaseAuthSuccess = false;
      String? authErrorMessage;

      try {
        print('🔐 Step 1: Attempting Firebase Authentication...');
        userCredential = await _auth.signInWithEmailAndPassword(
          email: emailLower,
          password: password,
        );
        firebaseAuthSuccess = true;
        print(
            '🔐 ✅ Firebase Auth successful for UID: ${userCredential.user?.uid}');
      } catch (authError) {
        print('🔐 ⚠️ Firebase Auth failed: $authError');
        firebaseAuthSuccess = false;
        authErrorMessage = authError.toString();
      }

      // Step 2: Check in 'users' collection (new structure)
      print('🔐 Step 2: Checking users collection...');
      try {
        final userQuery = await _firestore
            .collection('users')
            .where('email', isEqualTo: emailLower)
            .limit(1)
            .get();

        if (userQuery.docs.isNotEmpty) {
          print('🔐 ✅ User found in users collection');
          final userDoc = userQuery.docs.first;
          final userData = userDoc.data();
          final userStatus = userData['status'] ?? 'pending';

          print('🔐 User status: $userStatus');

          // If Firebase auth failed but user exists in our DB, handle appropriately
          if (!firebaseAuthSuccess) {
            if (authErrorMessage?.contains('user-not-found') == true) {
              throw Exception(
                  'المستخدم غير موجود في نظام المصادقة. يرجى التواصل مع الإدارة');
            } else if (authErrorMessage?.contains('wrong-password') == true) {
              throw Exception('كلمة المرور غير صحيحة');
            } else if (authErrorMessage?.contains('user-disabled') == true) {
              throw Exception('الحساب معطل. يرجى التواصل مع الإدارة');
            } else {
              throw Exception('خطأ في تسجيل الدخول: $authErrorMessage');
            }
          }

          // Update last login
          await userDoc.reference.update({
            'lastLoginAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });

          final bool isApproved = userStatus.toLowerCase() == 'approved';
          final permissions =
              userData['permissions'] as Map<String, dynamic>? ?? {};
          final bool canEditProfile = permissions['canEditProfile'] ?? false;

          // Get application data if exists
          Map<String, dynamic>? applicationData;
          if (!isApproved) {
            applicationData = _convertUserDataToApplicationFormat(userData);
          }

          return {
            'firebaseAuth': true,
            'isApproved': isApproved,
            'userData': userData,
            'userDocument': userDoc,
            'canEditProfile': canEditProfile,
            'applicationData': applicationData,
          };
        }
      } catch (e) {
        print('🔐 ⚠️ Error checking users collection: $e');
      }

      // Step 3: Check 'userstransed' collection (trusted users)
      print('🔐 Step 3: Checking userstransed collection...');
      try {
        final trustedUserDoc = await _firestore
            .collection('userstransed')
            .where('email', isEqualTo: emailLower)
            .limit(1)
            .get();

        if (trustedUserDoc.docs.isNotEmpty) {
          print('🔐 ✅ User found in userstransed collection');
          final userDoc = trustedUserDoc.docs.first;
          final userData = userDoc.data();
          final isApproved = userData['isApproved'] ?? false;

          if (!firebaseAuthSuccess) {
            throw Exception('خطأ في المصادقة: $authErrorMessage');
          }

          // Update last active
          await userDoc.reference.update({
            'lastActive': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });

          return {
            'firebaseAuth': true,
            'isApproved': isApproved,
            'userData': userData,
            'userDocument': userDoc,
            'canEditProfile': isApproved,
            'applicationData': null,
          };
        }
      } catch (e) {
        print('🔐 ⚠️ Error checking userstransed collection: $e');
      }

      // Step 4: Fallback - Check old 'user_applications' collection
      print('🔐 Step 4: Checking user_applications collection as fallback...');
      try {
        final oldAppQuery = await _firestore
            .collection('user_applications')
            .where('email', isEqualTo: emailLower)
            .limit(1)
            .get();

        if (oldAppQuery.docs.isNotEmpty) {
          print('🔐 ⚠️ User found in old user_applications collection');
          final appDoc = oldAppQuery.docs.first;
          final appData = appDoc.data();

          // Check password for old applications (if stored)
          final storedPassword = appData['password'];
          if (storedPassword != null && storedPassword != password) {
            throw Exception('كلمة المرور غير صحيحة');
          }

          // Check if user has Firebase UID
          final firebaseUid = appData['firebaseUid'];
          print('🔐 Firebase UID in old collection: $firebaseUid');

          if (firebaseUid == null || firebaseUid.toString().isEmpty) {
            print('🔐 🚨 MIGRATION NEEDED: User has no Firebase UID');
            throw Exception(
                'حسابك يحتاج لتحديث. يرجى التواصل مع الإدارة أو إعادة التسجيل');
          }

          if (!firebaseAuthSuccess) {
            throw Exception('كلمة المرور غير صحيحة أو الحساب معطل');
          }

          // Migrate user to new structure
          print('🔐 🔄 Migrating user to new structure...');
          await _migrateUserToNewStructure(firebaseUid.toString(), appData);

          // Retry with new structure
          return await signInTrustedUser(email, password);
        }
      } catch (e) {
        if (e.toString().contains('حسابك يحتاج لتحديث') ||
            e.toString().contains('كلمة المرور غير صحيحة')) {
          rethrow;
        }
        print('🔐 ⚠️ Error checking old user_applications: $e');
      }

      // Step 5: User not found anywhere
      throw Exception('لا يوجد حساب مسجل بهذا البريد الإلكتروني');
    } catch (e) {
      print('🔐 ❌ TrustedUserService error: $e');
      rethrow;
    }
  }

  // Migrate user from old to new structure
  Future<void> _migrateUserToNewStructure(
      String firebaseUid, Map<String, dynamic> oldAppData) async {
    try {
      print('🔄 Starting migration for UID: $firebaseUid');

      // Check if user already exists in new structure
      final existingUser =
          await _firestore.collection('users').doc(firebaseUid).get();
      if (existingUser.exists) {
        print('🔄 User already migrated');
        return;
      }

      final fullName = oldAppData['fullName']?.toString() ?? '';
      final nameParts = fullName.split(' ');

      final userData = {
        'uid': firebaseUid,
        'email': oldAppData['email']?.toString().toLowerCase() ?? '',
        'status': oldAppData['status']?.toString() ?? 'pending',
        'profile': {
          'fullName': fullName,
          'firstName': nameParts.isNotEmpty ? nameParts.first : '',
          'lastName': nameParts.length > 1 ? nameParts.skip(1).join(' ') : '',
          'phone': oldAppData['phoneNumber']?.toString() ?? '',
          'additionalPhone': oldAppData['additionalPhone']?.toString() ?? '',
          'serviceProvider': oldAppData['serviceProvider']?.toString() ?? '',
          'location': oldAppData['location']?.toString() ?? '',
          'telegramAccount': oldAppData['telegramAccount']?.toString() ?? '',
          'bio': oldAppData['description']?.toString() ?? '',
          'workingHours': oldAppData['workingHours']?.toString() ?? '',
          'profileImageUrl': '',
        },
        'application': {
          'submittedAt':
              oldAppData['submittedAt'] ?? FieldValue.serverTimestamp(),
          'reviewedAt': oldAppData['reviewedAt'],
          'reviewedBy': oldAppData['reviewedBy'],
          'rejectionReason': oldAppData['adminComment']?.toString() ?? '',
        },
        'permissions': {
          'canEditProfile':
              (oldAppData['status']?.toString().toLowerCase() == 'approved'),
          'canAccessDashboard': true,
        },
        'verification': {
          'emailVerified': oldAppData['emailVerified'] ?? false,
          'phoneVerified': oldAppData['phoneVerified'] ?? false,
          'documentsSubmitted': oldAppData['documentsSubmitted'] ?? false,
        },
        'createdAt': oldAppData['createdAt'] ?? FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'migratedFrom': 'user_applications',
        'migratedAt': FieldValue.serverTimestamp(),
      };

      // Create user in new collection
      await _firestore.collection('users').doc(firebaseUid).set(userData);

      // If approved, create userstransed entry
      if (oldAppData['status']?.toString().toLowerCase() == 'approved') {
        await _createTrustedUserEntry(firebaseUid, userData);
      }

      print('🔄 ✅ Migration completed for UID: $firebaseUid');
    } catch (e) {
      print('🔄 ❌ Migration failed: $e');
      throw Exception('فشل في ترحيل البيانات. يرجى التواصل مع الإدارة');
    }
  }

  // Create trusted user entry in userstransed collection
  Future<void> _createTrustedUserEntry(
      String uid, Map<String, dynamic> userData) async {
    try {
      final profile = userData['profile'] as Map<String, dynamic>? ?? {};

      final trustedUserData = {
        'uid': uid,
        'email': userData['email'],
        'fullName': profile['fullName'] ?? '',
        'aliasName': profile['fullName'] ?? '',
        'phoneNumber': profile['phone'] ?? '',
        'mobileNumber': profile['phone'] ?? '',
        'additionalPhone': profile['additionalPhone'] ?? '',
        'serviceProvider': profile['serviceProvider'] ?? '',
        'servicesProvided': profile['serviceProvider'] ?? '',
        'location': profile['location'] ?? '',
        'telegramAccount': profile['telegramAccount'] ?? '',
        'description': profile['bio'] ?? '',
        'workingHours': profile['workingHours'] ?? '',
        'profileImageUrl': profile['profileImageUrl'] ?? '',
        'role': 1, // Trusted user role
        'isActive': true,
        'isApproved': true,
        'verificationStatus': 'verified',
        'rating': 0.0,
        'totalReviews': 0,
        'reviews': [],
        'statusText': 'موثوق',
        'socialLinks': {},
        'joinedDate': FieldValue.serverTimestamp(),
        'lastActive': FieldValue.serverTimestamp(),
        'canUpdateProfile': true,
        'profileCompleted': false,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('userstransed').doc(uid).set(trustedUserData);
      print('✅ Trusted user entry created');
    } catch (e) {
      print('❌ Error creating trusted user entry: $e');
      // Don't rethrow - this is not critical for login
    }
  }

  // Convert user data format for compatibility
  Map<String, dynamic> _convertUserDataToApplicationFormat(
      Map<String, dynamic> userData) {
    final profile = userData['profile'] as Map<String, dynamic>? ?? {};
    final application = userData['application'] as Map<String, dynamic>? ?? {};
    final permissions = userData['permissions'] as Map<String, dynamic>? ?? {};
    final verification =
        userData['verification'] as Map<String, dynamic>? ?? {};

    return {
      'uid': userData['uid'],
      'email': userData['email'],
      'fullName': profile['fullName'] ?? '',
      'firstName': profile['firstName'] ?? '',
      'lastName': profile['lastName'] ?? '',
      'phoneNumber': profile['phone'] ?? '',
      'additionalPhone': profile['additionalPhone'] ?? '',
      'serviceProvider': profile['serviceProvider'] ?? '',
      'location': profile['location'] ?? '',
      'telegramAccount': profile['telegramAccount'] ?? '',
      'description': profile['bio'] ?? '', // Note: bio vs description
      'workingHours': profile['workingHours'] ?? '',
      'profileImageUrl': profile['profileImageUrl'] ?? '',
      'status': userData['status'],
      'createdAt': userData['createdAt'],
      'updatedAt': userData['updatedAt'],
      'submittedAt': application['submittedAt'],
      'reviewedAt': application['reviewedAt'],
      'reviewedBy': application['reviewedBy'],
      'adminComment': application['rejectionReason'] ?? '',
      'rejectionReason': application['rejectionReason'] ?? '',
      'canAccessDashboard': permissions['canAccessDashboard'] ?? true,
      'canEditProfile': permissions['canEditProfile'] ?? false,
      'emailVerified': verification['emailVerified'] ?? false,
      'phoneVerified': verification['phoneVerified'] ?? false,
      'documentsSubmitted': verification['documentsSubmitted'] ?? false,
      'documentId': userData['uid'],
    };
  }

  // Get user data by UID
  Future<Map<String, dynamic>?> getUserData([String? uid]) async {
    try {
      // If no UID provided, get current user
      if (uid == null) {
        final currentUser = _auth.currentUser;
        if (currentUser == null) return null;
        uid = currentUser.uid;
      }

      // Check users collection first
      final userDoc = await _firestore.collection('users').doc(uid).get();
      if (userDoc.exists) {
        return userDoc.data();
      }

      // Check userstransed collection
      final trustedUserDoc =
          await _firestore.collection('userstransed').doc(uid).get();
      if (trustedUserDoc.exists) {
        return trustedUserDoc.data();
      }

      return null;
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }

  // Check if user is approved
  Future<bool> isUserApproved(String uid) async {
    try {
      final userData = await getUserData(uid);
      if (userData != null) {
        // Check different possible status fields
        final status = userData['status'];
        final isApproved = userData['isApproved'];

        if (isApproved is bool) {
          return isApproved;
        }
        if (status is String) {
          return status.toLowerCase() == 'approved';
        }
      }
      return false;
    } catch (e) {
      print('Error checking approval status: $e');
      return false;
    }
  }

  // Update user profile
  Future<void> updateUserProfile({
    required String userId,
    String? fullName,
    String? firstName,
    String? lastName,
    String? phone,
    String? additionalPhone,
    String? serviceProvider,
    String? location,
    String? telegramAccount,
    String? bio,
    String? workingHours,
    String? profileImageUrl,
  }) async {
    try {
      // Check if user exists and is approved
      final userData = await getUserData(userId);
      if (userData == null) {
        throw Exception('المستخدم غير موجود');
      }

      final status = userData['status']?.toString() ?? 'pending';
      final isApproved = userData['isApproved'] ?? false;
      final permissions =
          userData['permissions'] as Map<String, dynamic>? ?? {};
      final canEditProfile = permissions['canEditProfile'] ?? false;

      if (status.toLowerCase() != 'approved' && !isApproved) {
        throw Exception('يجب الموافقة على حسابك أولاً لتعديل البيانات');
      }

      if (!canEditProfile && !isApproved) {
        throw Exception('ليس لديك صلاحية لتعديل البيانات');
      }

      // Build update data
      final Map<String, dynamic> updateData = {
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Update based on collection type
      final isInUsersCollection = await _firestore
          .collection('users')
          .doc(userId)
          .get()
          .then((doc) => doc.exists);

      if (isInUsersCollection) {
        // Update users collection (nested profile structure)
        if (fullName != null) {
          updateData['profile.fullName'] = fullName;
          final nameParts = fullName.split(' ');
          updateData['profile.firstName'] =
              nameParts.isNotEmpty ? nameParts.first : '';
          updateData['profile.lastName'] =
              nameParts.length > 1 ? nameParts.skip(1).join(' ') : '';
        }
        if (firstName != null) updateData['profile.firstName'] = firstName;
        if (lastName != null) updateData['profile.lastName'] = lastName;
        if (phone != null) updateData['profile.phone'] = phone;
        if (additionalPhone != null)
          updateData['profile.additionalPhone'] = additionalPhone;
        if (serviceProvider != null)
          updateData['profile.serviceProvider'] = serviceProvider;
        if (location != null) updateData['profile.location'] = location;
        if (telegramAccount != null)
          updateData['profile.telegramAccount'] = telegramAccount;
        if (bio != null) updateData['profile.bio'] = bio;
        if (workingHours != null)
          updateData['profile.workingHours'] = workingHours;
        if (profileImageUrl != null)
          updateData['profile.profileImageUrl'] = profileImageUrl;

        await _firestore.collection('users').doc(userId).update(updateData);
      }

      // Also update userstransed collection if exists
      final trustedUserExists = await _firestore
          .collection('userstransed')
          .doc(userId)
          .get()
          .then((doc) => doc.exists);

      if (trustedUserExists) {
        final trustedUpdateData = <String, dynamic>{
          'updatedAt': FieldValue.serverTimestamp(),
        };

        if (fullName != null) {
          trustedUpdateData['fullName'] = fullName;
          trustedUpdateData['aliasName'] = fullName;
        }
        if (phone != null) {
          trustedUpdateData['phoneNumber'] = phone;
          trustedUpdateData['mobileNumber'] = phone;
        }
        if (additionalPhone != null)
          trustedUpdateData['additionalPhone'] = additionalPhone;
        if (serviceProvider != null) {
          trustedUpdateData['serviceProvider'] = serviceProvider;
          trustedUpdateData['servicesProvided'] = serviceProvider;
        }
        if (location != null) trustedUpdateData['location'] = location;
        if (telegramAccount != null)
          trustedUpdateData['telegramAccount'] = telegramAccount;
        if (bio != null) trustedUpdateData['description'] = bio;
        if (workingHours != null)
          trustedUpdateData['workingHours'] = workingHours;
        if (profileImageUrl != null)
          trustedUpdateData['profileImageUrl'] = profileImageUrl;

        await _firestore
            .collection('userstransed')
            .doc(userId)
            .update(trustedUpdateData);
      }

      print('✅ User profile updated successfully');
    } catch (e) {
      print('❌ Error updating user profile: $e');
      rethrow;
    }
  }

  // Update pending user application
  Future<void> updatePendingUserApplication({
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
      print('🔧 Updating pending user application for email: $email');

      final emailLower = email.toLowerCase().trim();

      // Find user in users collection first
      final usersQuery = await _firestore
          .collection('users')
          .where('email', isEqualTo: emailLower)
          .limit(1)
          .get();

      if (usersQuery.docs.isNotEmpty) {
        final userDoc = usersQuery.docs.first;
        final currentData = userDoc.data();
        final status = currentData['status']?.toString() ?? 'pending';

        if (status.toLowerCase() == 'approved') {
          throw Exception('لا يمكن تعديل البيانات للحسابات المعتمدة');
        }

        // Build update data for nested profile structure
        final Map<String, dynamic> updateData = {
          'updatedAt': FieldValue.serverTimestamp(),
        };

        if (fullName != null && fullName.isNotEmpty) {
          updateData['profile.fullName'] = fullName;
          final nameParts = fullName.split(' ');
          updateData['profile.firstName'] =
              nameParts.isNotEmpty ? nameParts.first : '';
          updateData['profile.lastName'] =
              nameParts.length > 1 ? nameParts.skip(1).join(' ') : '';
        }
        if (phoneNumber != null) updateData['profile.phone'] = phoneNumber;
        if (additionalPhone != null)
          updateData['profile.additionalPhone'] = additionalPhone;
        if (serviceProvider != null)
          updateData['profile.serviceProvider'] = serviceProvider;
        if (location != null) updateData['profile.location'] = location;
        if (telegramAccount != null)
          updateData['profile.telegramAccount'] = telegramAccount;
        if (description != null) updateData['profile.bio'] = description;
        if (workingHours != null)
          updateData['profile.workingHours'] = workingHours;

        if (updateData.length > 1) {
          // More than just updatedAt
          await userDoc.reference.update(updateData);
          print('🔧 ✅ User application updated in users collection');
        }
        return;
      }

      // Fallback: Find in old user_applications collection
      final applicationsQuery = await _firestore
          .collection('user_applications')
          .where('email', isEqualTo: emailLower)
          .limit(1)
          .get();

      if (applicationsQuery.docs.isEmpty) {
        throw Exception(
            'لا يمكن العثور على طلب التسجيل بهذا البريد الإلكتروني');
      }

      final applicationDoc = applicationsQuery.docs.first;
      final currentData = applicationDoc.data();

      // Build update data for flat structure
      final Map<String, dynamic> updateData = {
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (fullName != null &&
          fullName.isNotEmpty &&
          fullName != currentData['fullName']) {
        updateData['fullName'] = fullName;
      }
      if (phoneNumber != null && phoneNumber != currentData['phoneNumber']) {
        updateData['phoneNumber'] = phoneNumber;
      }
      if (additionalPhone != null &&
          additionalPhone != currentData['additionalPhone']) {
        updateData['additionalPhone'] = additionalPhone;
      }
      if (serviceProvider != null &&
          serviceProvider != currentData['serviceProvider']) {
        updateData['serviceProvider'] = serviceProvider;
      }
      if (location != null && location != currentData['location']) {
        updateData['location'] = location;
      }
      if (telegramAccount != null &&
          telegramAccount != currentData['telegramAccount']) {
        updateData['telegramAccount'] = telegramAccount;
      }
      if (description != null && description != currentData['description']) {
        updateData['description'] = description;
      }
      if (workingHours != null && workingHours != currentData['workingHours']) {
        updateData['workingHours'] = workingHours;
      }

      if (updateData.length > 1) {
        // More than just updatedAt
        await applicationDoc.reference.update(updateData);
        print('🔧 ✅ Application updated in user_applications collection');
      } else {
        print('🔧 No changes detected, skipping update');
      }
    } catch (e) {
      print('🔧 ❌ Error updating pending user application: $e');
      rethrow;
    }
  }

  // Refresh application data
  Future<Map<String, dynamic>?> refreshApplicationData(String email) async {
    try {
      print('🔄 Refreshing application data for: $email');

      final emailLower = email.toLowerCase().trim();

      // Check users collection first
      final usersQuery = await _firestore
          .collection('users')
          .where('email', isEqualTo: emailLower)
          .limit(1)
          .get();

      if (usersQuery.docs.isNotEmpty) {
        final userData = usersQuery.docs.first.data();
        userData['documentId'] = usersQuery.docs.first.id;
        return _convertUserDataToApplicationFormat(userData);
      }

      // Fallback to user_applications
      final applicationQuery = await _firestore
          .collection('user_applications')
          .where('email', isEqualTo: emailLower)
          .limit(1)
          .get();

      if (applicationQuery.docs.isNotEmpty) {
        final applicationData = applicationQuery.docs.first.data();
        applicationData['documentId'] = applicationQuery.docs.first.id;
        return applicationData;
      }

      return null;
    } catch (e) {
      print('🔄 Error refreshing application data: $e');
      return null;
    }
  }

  // Get trusted user statistics
  Future<Map<String, int>> getTrustedUserStatistics() async {
    try {
      print('📊 Getting trusted user statistics');

      final trustedUsers = await _firestore.collection('userstransed').get();

      final stats = <String, int>{
        'total': trustedUsers.docs.length,
        'active': 0,
        'inactive': 0,
        'verified': 0,
        'profileCompleted': 0,
      };

      for (final doc in trustedUsers.docs) {
        final data = doc.data();

        if (data['isActive'] == true) stats['active'] = stats['active']! + 1;
        if (data['isActive'] == false)
          stats['inactive'] = stats['inactive']! + 1;
        if (data['verificationStatus'] == 'verified')
          stats['verified'] = stats['verified']! + 1;
        if (data['profileCompleted'] == true)
          stats['profileCompleted'] = stats['profileCompleted']! + 1;
      }

      return stats;
    } catch (e) {
      print('📊 Error getting trusted user statistics: $e');
      return {
        'total': 0,
        'active': 0,
        'inactive': 0,
        'verified': 0,
        'profileCompleted': 0
      };
    }
  }

  // Get trusted user profile
  Future<Map<String, dynamic>?> getTrustedUserProfile(String userId) async {
    try {
      final trustedUserDoc =
          await _firestore.collection('userstransed').doc(userId).get();
      if (trustedUserDoc.exists) {
        final data = trustedUserDoc.data()!;
        data['documentId'] = trustedUserDoc.id;
        return data;
      }
      return null;
    } catch (e) {
      print('Error getting trusted user profile: $e');
      return null;
    }
  }

  // Get all trusted users
  Future<List<Map<String, dynamic>>> getAllTrustedUsers() async {
    try {
      final querySnapshot = await _firestore
          .collection('userstransed')
          .where('isActive', isEqualTo: true)
          .orderBy('joinedDate', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['documentId'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print('Error getting all trusted users: $e');
      return [];
    }
  }

  // Get trusted users by location
  Future<List<Map<String, dynamic>>> getTrustedUsersByLocation(
      String location) async {
    try {
      final querySnapshot = await _firestore
          .collection('userstransed')
          .where('location', isEqualTo: location)
          .where('isActive', isEqualTo: true)
          .orderBy('rating', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['documentId'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print('Error getting trusted users by location: $e');
      return [];
    }
  }

  // Get trusted users by service
  Future<List<Map<String, dynamic>>> getTrustedUsersByService(
      String service) async {
    try {
      final querySnapshot = await _firestore
          .collection('userstransed')
          .where('serviceProvider', isEqualTo: service)
          .where('isActive', isEqualTo: true)
          .orderBy('rating', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['documentId'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print('Error getting trusted users by service: $e');
      return [];
    }
  }

  // Get top rated trusted users
  Future<List<Map<String, dynamic>>> getTopRatedTrustedUsers(
      {int limit = 10}) async {
    try {
      final querySnapshot = await _firestore
          .collection('userstransed')
          .where('isActive', isEqualTo: true)
          .orderBy('rating', descending: true)
          .limit(limit)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['documentId'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print('Error getting top rated trusted users: $e');
      return [];
    }
  }

  // Get recently joined trusted users
  Future<List<Map<String, dynamic>>> getRecentlyJoinedTrustedUsers(
      {int limit = 10}) async {
    try {
      final querySnapshot = await _firestore
          .collection('userstransed')
          .where('isActive', isEqualTo: true)
          .orderBy('joinedDate', descending: true)
          .limit(limit)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['documentId'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print('Error getting recently joined trusted users: $e');
      return [];
    }
  }

  // Get trusted users requiring profile completion
  Future<List<Map<String, dynamic>>>
      getTrustedUsersRequiringProfileCompletion() async {
    try {
      final querySnapshot = await _firestore
          .collection('userstransed')
          .where('isActive', isEqualTo: true)
          .where('profileCompleted', isEqualTo: false)
          .orderBy('joinedDate', descending: false)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['documentId'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print('Error getting users requiring profile completion: $e');
      return [];
    }
  }

  // Get trusted user metrics for dashboard
  Future<Map<String, dynamic>> getTrustedUserMetrics() async {
    try {
      print('📊 Getting trusted user metrics');

      final allUsers = await _firestore.collection('userstransed').get();
      final now = DateTime.now();
      final weekAgo = now.subtract(const Duration(days: 7));

      // Get recently joined users (this week)
      final recentUsers = await _firestore
          .collection('userstransed')
          .where('joinedDate',
              isGreaterThanOrEqualTo: Timestamp.fromDate(weekAgo))
          .get();

      // Calculate metrics
      final stats = await getTrustedUserStatistics();

      final avgRating = allUsers.docs.isNotEmpty
          ? allUsers.docs
                  .map((doc) => (doc.data()['rating'] ?? 0.0) as double)
                  .reduce((a, b) => a + b) /
              allUsers.docs.length
          : 0.0;

      final metrics = {
        'total': stats['total'],
        'active': stats['active'],
        'inactive': stats['inactive'],
        'verified': stats['verified'],
        'profileCompleted': stats['profileCompleted'],
        'recentlyJoined': recentUsers.docs.length,
        'averageRating': avgRating.toStringAsFixed(1),
        'completionRate': stats['total']! > 0
            ? (stats['profileCompleted']! / stats['total']! * 100)
                .toStringAsFixed(1)
            : '0.0',
        'verificationRate': stats['total']! > 0
            ? (stats['verified']! / stats['total']! * 100).toStringAsFixed(1)
            : '0.0',
      };

      return metrics;
    } catch (e) {
      print('📊 Error getting trusted user metrics: $e');
      return {
        'total': 0,
        'active': 0,
        'inactive': 0,
        'verified': 0,
        'profileCompleted': 0,
        'recentlyJoined': 0,
        'averageRating': '0.0',
        'completionRate': '0.0',
        'verificationRate': '0.0',
      };
    }
  }

  // Check if user can perform actions
  bool canPerformActions(Map<String, dynamic>? userData, bool isApproved) {
    return userData != null && isApproved;
  }

  // Update last active timestamp
  Future<void> updateLastActive(String userId) async {
    try {
      await _firestore.collection('userstransed').doc(userId).update({
        'lastActive': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating last active: $e');
      // Non-critical error, don't rethrow
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('Error signing out: $e');
      rethrow;
    }
  }

  // Batch update trusted users
  Future<void> batchUpdateTrustedUsers(
    List<String> userIds,
    Map<String, dynamic> updateData,
  ) async {
    try {
      print('📝 Batch updating ${userIds.length} trusted users');

      final batch = _firestore.batch();

      for (final userId in userIds) {
        final docRef = _firestore.collection('userstransed').doc(userId);
        batch.update(docRef, {
          ...updateData,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
      print('📝 Batch update completed successfully');
    } catch (e) {
      print('📝 Error in batch update: $e');
      rethrow;
    }
  }

  // Update trusted user status
  Future<void> updateTrustedUserStatus(String userId, bool isActive) async {
    try {
      print('🔧 Updating trusted user status: $userId -> active: $isActive');

      await _firestore.collection('userstransed').doc(userId).update({
        'isActive': isActive,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print('🔧 ✅ Trusted user status updated');
    } catch (e) {
      print('🔧 Error updating trusted user status: $e');
      rethrow;
    }
  }

  // Search trusted users
  Future<List<Map<String, dynamic>>> searchTrustedUsers(
      String searchTerm) async {
    try {
      print('🔍 Searching trusted users for: $searchTerm');

      if (searchTerm.trim().isEmpty) {
        return [];
      }

      final searchTermLower = searchTerm.toLowerCase();

      // Get all trusted users (since Firestore doesn't support case-insensitive search)
      final querySnapshot = await _firestore
          .collection('userstransed')
          .where('isActive', isEqualTo: true)
          .get();

      final trustedUsers = querySnapshot.docs.where((doc) {
        final data = doc.data();
        final fullName = (data['fullName'] ?? '').toString().toLowerCase();
        final aliasName = (data['aliasName'] ?? '').toString().toLowerCase();
        final email = (data['email'] ?? '').toString().toLowerCase();
        final serviceProvider =
            (data['serviceProvider'] ?? '').toString().toLowerCase();
        final location = (data['location'] ?? '').toString().toLowerCase();

        return fullName.contains(searchTermLower) ||
            aliasName.contains(searchTermLower) ||
            email.contains(searchTermLower) ||
            serviceProvider.contains(searchTermLower) ||
            location.contains(searchTermLower);
      }).map((doc) {
        final data = doc.data();
        data['documentId'] = doc.id;
        return data;
      }).toList();

      print('🔍 Found ${trustedUsers.length} matching trusted users');
      return trustedUsers;
    } catch (e) {
      print('🔍 Error searching trusted users: $e');
      return [];
    }
  }
}

// Migration service for one-time data migration
class UserMigrationService {
  static Future<void> migrateAllUsersToNewStructure() async {
    try {
      print('🔄 Starting migration of all users...');

      final oldApps = await FirebaseFirestore.instance
          .collection('user_applications')
          .get();

      int migrated = 0;
      int skipped = 0;
      int errors = 0;

      for (final doc in oldApps.docs) {
        try {
          final data = doc.data();
          final firebaseUid = data['firebaseUid'];
          final email = data['email'];

          if (firebaseUid == null || firebaseUid.toString().isEmpty) {
            print('⚠️ Skipping $email - no Firebase UID');
            skipped++;
            continue;
          }

          // Check if already migrated
          final existingUser = await FirebaseFirestore.instance
              .collection('users')
              .doc(firebaseUid)
              .get();

          if (existingUser.exists) {
            print('ℹ️ User $email already migrated');
            skipped++;
            continue;
          }

          // Migrate user
          final fullName = data['fullName']?.toString() ?? '';
          final nameParts = fullName.split(' ');

          final userData = {
            'uid': firebaseUid,
            'email': email?.toString().toLowerCase(),
            'status': data['status'] ?? 'pending',
            'profile': {
              'fullName': fullName,
              'firstName': nameParts.isNotEmpty ? nameParts.first : '',
              'lastName':
                  nameParts.length > 1 ? nameParts.skip(1).join(' ') : '',
              'phone': data['phoneNumber']?.toString() ?? '',
              'additionalPhone': data['additionalPhone']?.toString() ?? '',
              'serviceProvider': data['serviceProvider']?.toString() ?? '',
              'location': data['location']?.toString() ?? '',
              'telegramAccount': data['telegramAccount']?.toString() ?? '',
              'bio': data['description']?.toString() ?? '',
              'workingHours': data['workingHours']?.toString() ?? '',
              'profileImageUrl': '',
            },
            'application': {
              'submittedAt': data['submittedAt'],
              'reviewedAt': data['reviewedAt'],
              'reviewedBy': data['reviewedBy'],
              'rejectionReason': data['adminComment']?.toString() ?? '',
            },
            'permissions': {
              'canEditProfile':
                  (data['status']?.toString().toLowerCase() == 'approved'),
              'canAccessDashboard': true,
            },
            'verification': {
              'emailVerified': data['emailVerified'] ?? false,
              'phoneVerified': data['phoneVerified'] ?? false,
              'documentsSubmitted': data['documentsSubmitted'] ?? false,
            },
            'createdAt': data['createdAt'] ?? FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
            'migratedFrom': 'user_applications',
            'migratedAt': FieldValue.serverTimestamp(),
          };

          await FirebaseFirestore.instance
              .collection('users')
              .doc(firebaseUid)
              .set(userData);

          // Create userstransed entry if approved
          if (data['status']?.toString().toLowerCase() == 'approved') {
            final profile = userData['profile'] as Map<String, dynamic>;

            await FirebaseFirestore.instance
                .collection('userstransed')
                .doc(firebaseUid)
                .set({
              'uid': firebaseUid,
              'email': email,
              'fullName': profile['fullName'],
              'aliasName': profile['fullName'],
              'phoneNumber': profile['phone'],
              'mobileNumber': profile['phone'],
              'additionalPhone': profile['additionalPhone'],
              'serviceProvider': profile['serviceProvider'],
              'servicesProvided': profile['serviceProvider'],
              'location': profile['location'],
              'telegramAccount': profile['telegramAccount'],
              'description': profile['bio'],
              'workingHours': profile['workingHours'],
              'profileImageUrl': '',
              'role': 1,
              'isActive': true,
              'isApproved': true,
              'verificationStatus': 'verified',
              'rating': 0.0,
              'totalReviews': 0,
              'reviews': [],
              'statusText': 'موثوق',
              'socialLinks': {},
              'joinedDate': FieldValue.serverTimestamp(),
              'lastActive': FieldValue.serverTimestamp(),
              'canUpdateProfile': true,
              'profileCompleted': false,
              'createdAt': FieldValue.serverTimestamp(),
              'updatedAt': FieldValue.serverTimestamp(),
            });
          }

          migrated++;
          print('✅ Migrated $email');
        } catch (e) {
          errors++;
          print('❌ Error migrating ${doc.data()['email']}: $e');
        }
      }

      print('🔄 Migration completed:');
      print('  - Migrated: $migrated');
      print('  - Skipped: $skipped');
      print('  - Errors: $errors');
    } catch (e) {
      print('❌ Migration failed: $e');
    }
  }
}
