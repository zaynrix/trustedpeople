// admin_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:trustedtallentsvalley/fetures/auth/admin/models/admin_user_model.dart';
import 'package:trustedtallentsvalley/fetures/auth/admin/models/user_application_model.dart';

class AdminService {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AdminService(this._auth, this._firestore);

  // Admin sign in method
  Future<User> signInAdmin(String email, String password) async {
    try {
      print('🔐 Admin sign in attempt for: $email');

      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      print('🔐 Firebase Auth successful, checking admin status...');

      // Check if user is admin
      final adminDoc =
          await _firestore.collection('admins').doc(credential.user!.uid).get();

      if (!adminDoc.exists) {
        print('🔐 User is not an admin, signing out...');
        await _auth.signOut();
        throw Exception('لا تملك صلاحيات المشرف المطلوبة');
      }

      print('🔐 Admin login successful');
      return credential.user!;
    } catch (e) {
      print('🔐 Admin login error: $e');
      rethrow;
    }
  }

  // Get admin user data
  Future<Map<String, dynamic>?> getAdminUserData(String uid) async {
    try {
      print('🔍 Fetching admin data for UID: $uid');

      final adminDoc = await _firestore.collection('admins').doc(uid).get();

      if (adminDoc.exists) {
        print('🔍 Admin found in admins collection');
        return adminDoc.data();
      }

      return null;
    } catch (e) {
      print('🔍 Error fetching admin data: $e');
      rethrow;
    }
  }

  // Get admin user as AdminUser model (if you have a model class)
  Future<AdminUser?> getAdminUser(String uid) async {
    try {
      print('🔍 Fetching admin user for UID: $uid');

      final adminDoc = await _firestore.collection('admins').doc(uid).get();

      if (adminDoc.exists) {
        print('🔍 Admin found in admins collection');
        // Convert Firestore document to AdminUser model
        return AdminUser.fromFirestore(adminDoc);
      }

      return null;
    } catch (e) {
      print('🔍 Error fetching admin user: $e');
      rethrow;
    }
  }

  // Get all user applications as Map (original method)
  Future<List<Map<String, dynamic>>> getAllUserApplications() async {
    try {
      print('🔧 Admin: Loading all user applications');

      final querySnapshot = await _firestore
          .collection('user_applications')
          .orderBy('createdAt', descending: true)
          .get();

      final applications = querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['documentId'] = doc.id; // Add the Firestore document ID
        return data;
      }).toList();

      print('🔧 Admin: Loaded ${applications.length} applications');
      return applications;
    } catch (e) {
      print('🔧 Admin: Error loading applications: $e');
      rethrow;
    }
  }

  // Get all user applications as UserApplication objects
  Future<List<UserApplication>> getAllUserApplicationsAsModels() async {
    try {
      print('🔧 Admin: Loading all user applications as models');

      final querySnapshot = await _firestore
          .collection('user_applications')
          .orderBy('createdAt', descending: true)
          .get();

      final applications = querySnapshot.docs.map((doc) {
        return UserApplication.fromFirestore(doc);
      }).toList();

      print('🔧 Admin: Loaded ${applications.length} application models');
      return applications;
    } catch (e) {
      print('🔧 Admin: Error loading application models: $e');
      rethrow;
    }
  }

  // Update user application status
  Future<void> updateUserApplicationStatus(
    String applicationId,
    String status, {
    String? comment,
  }) async {
    try {
      print('🔧 Admin: Starting status update');
      print('  - Application ID: $applicationId');
      print('  - New Status: $status');
      print('  - Comment: $comment');

      // Check if document exists first
      final docRef =
          _firestore.collection('user_applications').doc(applicationId);
      final docSnapshot = await docRef.get();

      if (!docSnapshot.exists) {
        throw Exception(
            'Application document not found with ID: $applicationId');
      }

      print('🔧 Admin: Document exists, proceeding with update');

      // Prepare update data
      final updateData = {
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (comment != null && comment.isNotEmpty) {
        updateData['adminComment'] = comment;
      }

      // Add reviewer info if available
      final currentUser = _auth.currentUser;
      if (currentUser != null) {
        updateData['reviewedBy'] = currentUser.uid;
        updateData['reviewedAt'] = FieldValue.serverTimestamp();
      }

      print('🔧 Admin: Update data: $updateData');

      // Perform the update
      await docRef.update(updateData);

      print('🔧 Admin: Application status updated successfully');

      // If approved, create Firebase Auth account and add to trusted users
      if (status.toLowerCase() == 'approved') {
        print('🔧 Admin: Status is approved, creating accounts...');
        await _createApprovedUserAccount(applicationId);
        await _addToTrustedUsersTable(applicationId);
      }

      // If rejected, remove from trusted users table
      if (status.toLowerCase() == 'rejected') {
        print('🔧 Admin: Status is rejected, removing from trusted users...');
        await removeFromTrustedUsersTable(applicationId);
      }

      print('🔧 Admin: Status update completed successfully');
    } catch (e, stackTrace) {
      print('🔧 Admin: Error in updateUserApplicationStatus: $e');
      print('🔧 Admin: Stack trace: $stackTrace');
      rethrow;
    }
  }

  // Create Firebase account for approved users
  Future<void> _createApprovedUserAccount(String applicationId) async {
    try {
      print('🔧 Creating Firebase account for application: $applicationId');

      // Get the application data
      final applicationDoc = await _firestore
          .collection('user_applications')
          .doc(applicationId)
          .get();

      if (!applicationDoc.exists) {
        print('🔧 Application document not found: $applicationId');
        throw Exception('طلب التسجيل غير موجود');
      }

      final applicationData = applicationDoc.data()!;
      final email = applicationData['email'];
      final password = applicationData['password'];
      final fullName = applicationData['fullName'];

      print('🔧 Application data retrieved:');
      print('  - Email: $email');
      print('  - Full Name: $fullName');

      // Check if Firebase account already exists
      bool accountExists = false;
      try {
        final existingUserMethods =
            await _auth.fetchSignInMethodsForEmail(email);
        accountExists = existingUserMethods.isNotEmpty;
        print('🔧 Firebase account exists: $accountExists');
      } catch (e) {
        print('🔧 Error checking existing account: $e');
      }

      UserCredential? userCredential;

      if (accountExists) {
        print('🔧 Firebase account already exists, skipping creation');
        // Try to get the existing user
        try {
          final existingUsers = await _auth.signInWithEmailAndPassword(
            email: email,
            password: password,
          );
          userCredential = existingUsers;
          print('🔧 Successfully signed in existing user');
        } catch (e) {
          print('🔧 Could not sign in existing user: $e');
          throw Exception(
              'حساب Firebase موجود بالفعل ولكن كلمة المرور غير صحيحة');
        }
      } else {
        // Create new Firebase Auth account
        print('🔧 Creating new Firebase Auth account...');
        try {
          userCredential = await _auth.createUserWithEmailAndPassword(
            email: email,
            password: password,
          );
          print('🔧 Firebase Auth account created successfully');
          print('🔧 User UID: ${userCredential.user?.uid}');
        } catch (e) {
          print('🔧 Error creating Firebase Auth account: $e');
          if (e is FirebaseAuthException) {
            switch (e.code) {
              case 'email-already-in-use':
                throw Exception('البريد الإلكتروني مستخدم بالفعل');
              case 'weak-password':
                throw Exception('كلمة المرور ضعيفة');
              case 'invalid-email':
                throw Exception('البريد الإلكتروني غير صحيح');
              default:
                throw Exception('خطأ في إنشاء الحساب: ${e.message}');
            }
          }
          rethrow;
        }
      }

      if (userCredential.user == null) {
        throw Exception('فشل في إنشاء أو الوصول للحساب');
      }

      final user = userCredential.user!;

      // Update display name
      try {
        await user.updateDisplayName(fullName);
        print('🔧 Display name updated');
      } catch (e) {
        print('🔧 Error updating display name: $e');
        // Non-critical error, continue
      }

      // Check if user document already exists
      final existingUserDoc =
          await _firestore.collection('users').doc(user.uid).get();

      if (existingUserDoc.exists) {
        print('🔧 User document already exists, updating...');
        // Update existing document
        await _firestore.collection('users').doc(user.uid).update({
          'applicationId': applicationId,
          'updatedAt': FieldValue.serverTimestamp(),
          'isActive': true,
        });
      } else {
        print('🔧 Creating new user document...');
        // Create new user document
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'email': email,
          'fullName': fullName,
          'phoneNumber': applicationData['phoneNumber'],
          'additionalPhone': applicationData['additionalPhone'] ?? '',
          'serviceProvider': applicationData['serviceProvider'],
          'location': applicationData['location'],
          'role': 'user', // Trusted user role
          'applicationId': applicationId,
          'createdAt': FieldValue.serverTimestamp(),
          'isActive': true,
        });
      }

      print('🔧 User document created/updated successfully');

      // Update application with user ID
      await _firestore
          .collection('user_applications')
          .doc(applicationId)
          .update({
        'firebaseUid': user.uid,
        'accountCreated': true,
        'accountCreatedAt': FieldValue.serverTimestamp(),
      });

      print('🔧 Application updated with Firebase UID');

      // Sign out the newly created/signed in user (since we're in admin context)
      try {
        await _auth.signOut();
        print('🔧 Signed out the user (admin context)');
      } catch (e) {
        print('🔧 Error signing out: $e');
        // Non-critical error
      }

      print('🔧 ✅ Account creation/update completed successfully');
    } catch (e, stackTrace) {
      print('🔧 ❌ Error creating user account: $e');
      print('🔧 Stack trace: $stackTrace');

      // Don't rethrow - let the status update succeed even if account creation fails
      // The admin can try to create the account again later
      print('🔧 Account creation failed, but status was updated successfully');
    }
  }

  // Add approved user to trusted users table
  Future<void> _addToTrustedUsersTable(String applicationId) async {
    try {
      print('🔧 Adding approved user to trusted users table...');

      // Get the application data
      final applicationDoc = await _firestore
          .collection('user_applications')
          .doc(applicationId)
          .get();

      if (!applicationDoc.exists) {
        print('🔧 Application document not found: $applicationId');
        throw Exception('طلب التسجيل غير موجود');
      }

      final applicationData = applicationDoc.data()!;
      final firebaseUid = applicationData['firebaseUid'];

      if (firebaseUid == null || firebaseUid.isEmpty) {
        print('🔧 No Firebase UID found, cannot add to trusted users');
        throw Exception('لم يتم العثور على معرف المستخدم');
      }

      // Check if user already exists in trusted users table
      final existingTrustedUser =
          await _firestore.collection('userstransed').doc(firebaseUid).get();

      if (existingTrustedUser.exists) {
        print('🔧 User already exists in trusted users table, updating...');

        // Update existing trusted user
        await _firestore.collection('userstransed').doc(firebaseUid).update({
          'fullName': applicationData['fullName'],
          'email': applicationData['email'],
          'phoneNumber': applicationData['phoneNumber'],
          'additionalPhone': applicationData['additionalPhone'] ?? '',
          'serviceProvider': applicationData['serviceProvider'],
          'location': applicationData['location'],
          'role': 1, // Trusted user role
          'isActive': true,
          'isApproved': true,
          'applicationId': applicationId,
          'approvedAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        print('🔧 Existing trusted user updated successfully');
      } else {
        print('🔧 Creating new trusted user entry...');

        // Create new trusted user document
        await _firestore.collection('userstransed').doc(firebaseUid).set({
          'uid': firebaseUid,
          'fullName': applicationData['fullName'],
          'email': applicationData['email'],
          'phoneNumber': applicationData['phoneNumber'],
          'additionalPhone': applicationData['additionalPhone'] ?? '',
          'serviceProvider': applicationData['serviceProvider'],
          'location': applicationData['location'],
          'role': 1, // Trusted user role
          'isActive': true,
          'isApproved': true,
          'applicationId': applicationId,
          'approvedAt': FieldValue.serverTimestamp(),
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),

          // Additional trusted user fields
          'aliasName': applicationData['fullName'],
          'mobileNumber': applicationData['phoneNumber'],
          'servicesProvided': applicationData['serviceProvider'],
          'telegramAccount': '',
          'reviews': [],
          'statusText': 'موثوق',
          'profileImageUrl': '',
          'description': '',
          'workingHours': '',
          'socialLinks': {},
          'verificationStatus': 'verified',
          'rating': 0.0,
          'totalReviews': 0,
          'lastActive': FieldValue.serverTimestamp(),
          'joinedDate': FieldValue.serverTimestamp(),
          'canUpdateProfile': true,
          'profileCompleted': false,
        });

        print('🔧 New trusted user created successfully');
      }

      // Update the application to mark that user was added to trusted table
      await _firestore
          .collection('user_applications')
          .doc(applicationId)
          .update({
        'addedToTrustedTable': true,
        'addedToTrustedAt': FieldValue.serverTimestamp(),
      });

      print('🔧 ✅ User successfully added to trusted users table');
    } catch (e, stackTrace) {
      print('🔧 ❌ Error adding user to trusted users table: $e');
      print('🔧 Stack trace: $stackTrace');

      // Don't rethrow - let the approval succeed even if adding to trusted table fails
      print('🔧 Adding to trusted table failed, but approval was successful');
    }
  }

  // Remove user from trusted users table (for rejected/revoked users) - Make this public
  Future<void> removeFromTrustedUsersTable(String applicationId) async {
    try {
      print('🔧 Removing user from trusted users table...');

      // Get the application data to find the Firebase UID
      final applicationDoc = await _firestore
          .collection('user_applications')
          .doc(applicationId)
          .get();

      if (!applicationDoc.exists) {
        print('🔧 Application document not found: $applicationId');
        return;
      }

      final applicationData = applicationDoc.data()!;
      final firebaseUid = applicationData['firebaseUid'];

      if (firebaseUid != null && firebaseUid.isNotEmpty) {
        // Remove from trusted users table
        await _firestore.collection('userstransed').doc(firebaseUid).delete();

        // Update application status
        await _firestore
            .collection('user_applications')
            .doc(applicationId)
            .update({
          'addedToTrustedTable': false,
          'removedFromTrustedAt': FieldValue.serverTimestamp(),
        });

        print('🔧 ✅ User removed from trusted users table');
      }
    } catch (e) {
      print('🔧 ❌ Error removing user from trusted users table: $e');
      // Don't rethrow - this is not critical
    }
  }

  // Get application statistics for admin dashboard
  Future<Map<String, int>> getApplicationStatistics() async {
    try {
      final applications =
          await _firestore.collection('user_applications').get();

      final stats = <String, int>{
        'total': applications.docs.length,
        'in_progress': 0,
        'approved': 0,
        'rejected': 0,
        'needs_review': 0,
      };

      for (final doc in applications.docs) {
        final status = doc.data()['status'] ?? 'in_progress';
        stats[status] = (stats[status] ?? 0) + 1;
      }

      return stats;
    } catch (e) {
      return {
        'total': 0,
        'in_progress': 0,
        'approved': 0,
        'rejected': 0,
        'needs_review': 0,
      };
    }
  }
}
