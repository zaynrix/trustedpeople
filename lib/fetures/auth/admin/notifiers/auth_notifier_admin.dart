// auth_notifier.dart
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trustedtallentsvalley/app/helpers/helper_functions.dart';
import 'package:trustedtallentsvalley/fetures/auth/admin/services/admin_service.dart';
import 'package:trustedtallentsvalley/fetures/auth/admin/services/application_service.dart';
import 'package:trustedtallentsvalley/fetures/auth/trusted_user/services/trusted_user_service.dart';

import '../states/auth_state_admin.dart';

class AuthNotifier extends StateNotifier<AuthState> {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  late final AdminService _adminService;
  late final ApplicationService _applicationService;
  late final TrustedUserService _trustedUserService;
  StreamSubscription<User?>? _authStateSubscription;
  Timer? _refreshTimer;

  AuthNotifier(this._auth, this._firestore) : super(AuthState()) {
    // Initialize services with proper parameters
    _adminService = AdminService(_auth, _firestore);
    _applicationService = ApplicationService(_firestore);
    _trustedUserService = TrustedUserService(_auth, _firestore);

    _initializeAuth();
    _setupPeriodicRefresh();
  }

  // Setup periodic refresh every 5 minutes
  void _setupPeriodicRefresh() {
    _refreshTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      if (state.isAuthenticated) {
        refreshAuthState();
      }
    });
  }

  // Initialize authentication state
  Future<void> _initializeAuth() async {
    try {
      print('🔐 Initializing auth state...');

      // Set loading state
      state = state.copyWith(isLoading: true, error: null);

      // Check if user is already signed in
      final currentUser = _auth.currentUser;
      if (currentUser != null) {
        print('🔐 Found existing user: ${currentUser.email}');
        await _fetchUserData(currentUser);
      } else {
        print('🔐 No existing user found');
        state = state.copyWith(isLoading: false);
      }

      // Listen to auth state changes
      _authStateSubscription =
          _auth.authStateChanges().listen(_onAuthStateChanged);
    } catch (e) {
      print('🔐 Error initializing auth: $e');
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // Add approved user to trusted users table
  Future<void> addToTrustedUsersTable(String applicationId) async {
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

      final trustedUserData = {
        'uid': firebaseUid,
        'fullName': applicationData['fullName'] ?? '',
        'email': applicationData['email'] ?? '',
        'phoneNumber': applicationData['phoneNumber'] ?? '',
        'additionalPhone': applicationData['additionalPhone'] ?? '',
        'serviceProvider': applicationData['serviceProvider'] ?? '',
        'location': applicationData['location'] ?? '',
        'role': 1, // Trusted user role
        'isActive': true,
        'isApproved': true,
        'applicationId': applicationId,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (existingTrustedUser.exists) {
        print('🔧 User already exists in trusted users table, updating...');
        trustedUserData['approvedAt'] = FieldValue.serverTimestamp();

        await _firestore
            .collection('userstransed')
            .doc(firebaseUid)
            .update(trustedUserData);

        print('🔧 Existing trusted user updated successfully');
      } else {
        print('🔧 Creating new trusted user entry...');

        // Add creation timestamp and additional fields for new users
        trustedUserData.addAll({
          'createdAt': FieldValue.serverTimestamp(),
          'approvedAt': FieldValue.serverTimestamp(),
          'aliasName': applicationData['fullName'] ?? '',
          'mobileNumber': applicationData['phoneNumber'] ?? '',
          'servicesProvided': applicationData['serviceProvider'] ?? '',
          'telegramAccount': applicationData['telegramAccount'] ?? '',
          'reviews': [],
          'statusText': 'موثوق',
          'profileImageUrl': '',
          'description': applicationData['description'] ?? '',
          'workingHours': applicationData['workingHours'] ?? '',
          'socialLinks': {},
          'verificationStatus': 'verified',
          'rating': 0.0,
          'totalReviews': 0,
          'lastActive': FieldValue.serverTimestamp(),
          'joinedDate': FieldValue.serverTimestamp(),
          'canUpdateProfile': true,
          'profileCompleted': false,
        });

        await _firestore
            .collection('userstransed')
            .doc(firebaseUid)
            .set(trustedUserData);

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
      rethrow; // Re-throw so caller can handle
    }
  }

  // Remove user from trusted users table
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

  // Handle auth state changes
  Future<void> _onAuthStateChanged(User? user) async {
    try {
      print('🔐 Auth state changed: ${user?.email ?? 'null'}');

      if (user == null) {
        print('🔐 User signed out');
        state = AuthState(); // Reset to default state
      } else {
        print('🔐 User signed in, fetching data...');
        await _fetchUserData(user);
      }
    } catch (e) {
      print('🔐 Error in auth state change: $e');
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  // Fetch user data from Firestore
  Future<void> _fetchUserData(User user) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      print('🔍 Fetching user data for UID: ${user.uid}');

      // First, check if user is an admin
      final adminData = await _adminService.getAdminUserData(user.uid);
      if (adminData != null) {
        print('🔍 User found in admins collection');
        final roleValue = adminData['role'] as int? ?? 0;

        state = state.copyWith(
          user: user,
          role: UserRole.fromInt(roleValue),
          isAuthenticated: true,
          isLoading: false,
          userData: adminData,
          isTrustedUser: false,
          isApproved: true, // Admins are always approved
          error: null,
        );
        return;
      }

      // Check if user exists in trusted users table
      final trustedUserData = await _trustedUserService.getUserData(user.uid);
      if (trustedUserData != null) {
        print('🔍 User found in trusted users collection');
        final userRole = trustedUserData['role'] as int? ?? 2;
        final isApproved = trustedUserData['isApproved'] as bool? ?? false;

        // Get application data if available
        Map<String, dynamic>? applicationData;
        final applicationId = trustedUserData['applicationId'];
        if (applicationId != null && applicationId.toString().isNotEmpty) {
          try {
            applicationData = await _applicationService
                .getApplicationById(applicationId.toString());
          } catch (e) {
            print('🔍 Could not fetch application data: $e');
          }
        }

        state = state.copyWith(
          user: user,
          role: UserRole.fromInt(userRole),
          isAuthenticated: true,
          isLoading: false,
          userData: trustedUserData,
          applicationData: applicationData,
          isTrustedUser: userRole == 1, // role 1 = trusted
          isApproved: isApproved,
          error: null,
        );
        return;
      }

      // Check if user exists in regular users collection
      final regularUserData = await _getUserFromUsersCollection(user.uid);
      if (regularUserData != null) {
        print('🔍 User found in users collection');
        final status = regularUserData['status'] as String? ?? 'pending';
        final isApproved = status.toLowerCase() == 'approved';

        state = state.copyWith(
          user: user,
          role: UserRole
              .trusted, // Users in users collection are applying to be trusted
          isAuthenticated: true,
          isLoading: false,
          userData: regularUserData,
          isTrustedUser:
              false, // Not trusted until approved and moved to trusted collection
          isApproved: isApproved,
          error: null,
        );
        return;
      }

      // User exists in Firebase Auth but not in any collection
      print('🔍 User not found in any collection');
      state = state.copyWith(
        user: user,
        role: UserRole.common,
        isAuthenticated: true,
        isLoading: false,
        userData: null,
        isTrustedUser: false,
        isApproved: false,
        error: null,
      );
    } catch (e) {
      print('🔍 Error fetching user data: $e');
      state = state.copyWith(
        user: user,
        role: UserRole.common,
        isAuthenticated: true,
        isLoading: false,
        error: 'Failed to fetch user data: ${e.toString()}',
        isTrustedUser: false,
        isApproved: false,
      );
    }
  }

  // Helper method to get user from users collection
  Future<Map<String, dynamic>?> _getUserFromUsersCollection(String uid) async {
    try {
      final userDoc = await _firestore.collection('users').doc(uid).get();
      return userDoc.exists ? userDoc.data() : null;
    } catch (e) {
      print('Error getting user from users collection: $e');
      return null;
    }
  }

  // Admin sign in
  Future<void> signIn(String email, String password) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      await _adminService.signInAdmin(email, password);
      // Auth state listener will update the state
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  // Get user data by UID
  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      // Check trusted users first
      final trustedUserDoc =
          await _firestore.collection('userstransed').doc(uid).get();
      if (trustedUserDoc.exists) {
        return trustedUserDoc.data();
      }

      // Check regular users
      final userDoc = await _firestore.collection('users').doc(uid).get();
      if (userDoc.exists) {
        return userDoc.data();
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
        final status =
            userData['status'] ?? userData['isApproved'] ?? 'pending';
        if (status is bool) {
          return status;
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

  // Update user profile (for approved users only)
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
      // Verify user has permission to update
      if (state.user?.uid != userId && !state.isAdmin) {
        throw Exception('لا يمكنك تعديل بيانات مستخدم آخر');
      }

      if (!state.isApproved && !state.isAdmin) {
        throw Exception('يجب الموافقة على حسابك أولاً لتعديل البيانات');
      }

      // Build update data
      final Map<String, dynamic> updateData = {
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Add non-null values to update data
      if (fullName != null) updateData['fullName'] = fullName;
      if (firstName != null) updateData['firstName'] = firstName;
      if (lastName != null) updateData['lastName'] = lastName;
      if (phone != null) updateData['phoneNumber'] = phone;
      if (additionalPhone != null)
        updateData['additionalPhone'] = additionalPhone;
      if (serviceProvider != null)
        updateData['serviceProvider'] = serviceProvider;
      if (location != null) updateData['location'] = location;
      if (telegramAccount != null)
        updateData['telegramAccount'] = telegramAccount;
      if (bio != null) updateData['description'] = bio;
      if (workingHours != null) updateData['workingHours'] = workingHours;
      if (profileImageUrl != null)
        updateData['profileImageUrl'] = profileImageUrl;

      // Update in appropriate collection
      if (state.isTrustedUser) {
        await _firestore
            .collection('userstransed')
            .doc(userId)
            .update(updateData);
      } else {
        // Update in users collection with nested profile structure
        final profileUpdateData = <String, dynamic>{};
        updateData.forEach((key, value) {
          if (key != 'updatedAt') {
            profileUpdateData['profile.$key'] = value;
          } else {
            profileUpdateData[key] = value;
          }
        });

        await _firestore
            .collection('users')
            .doc(userId)
            .update(profileUpdateData);
      }

      // Refresh user data
      if (state.user != null) {
        await _fetchUserData(state.user!);
      }

      print('✅ User profile updated successfully');
    } catch (e) {
      print('❌ Error updating user profile: $e');
      rethrow;
    }
  }

  // Sign in trusted user
  Future<void> signInTrustedUser(String email, String password) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      print('🔐 AuthNotifier: Starting signInTrustedUser');

      final result =
          await _trustedUserService.signInTrustedUser(email, password);

      print('🔐 AuthNotifier: Service returned result: ${result.keys}');

      if (result['firebaseAuth'] == true) {
        // Firebase Auth was successful - let auth state listener handle the rest
        print(
            '🔐 ✅ AuthNotifier: Firebase auth successful, waiting for state update');
      } else {
        throw Exception('Authentication failed');
      }
    } catch (e) {
      print('🔐 ❌ AuthNotifier error: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
        isAuthenticated: false,
      );
      rethrow;
    }
  }

  // Update trusted user profile
  Future<void> updateTrustedUserProfile({
    required String userId,
    String? aliasName,
    String? phoneNumber,
    String? additionalPhone,
    String? serviceProvider,
    String? location,
    String? telegramAccount,
    String? description,
    String? workingHours,
  }) async {
    try {
      print('🔄 updateTrustedUserProfile called with userId: $userId');

      // Validate inputs
      if (userId.trim().isEmpty) {
        throw Exception('معرف المستخدم مطلوب');
      }

      // Get current user to verify permission
      final currentUser = _auth.currentUser;
      if (currentUser?.uid != userId && !state.isAdmin) {
        throw Exception('لا يمكنك تعديل بيانات مستخدم آخر');
      }

      if (!state.isApproved && !state.isAdmin) {
        throw Exception('يجب الموافقة على حسابك أولاً');
      }

      // Use the service to update profile
      await _trustedUserService.updateUserProfile(
        userId: userId,
        fullName: aliasName,
        phone: phoneNumber,
        additionalPhone: additionalPhone,
        serviceProvider: serviceProvider,
        location: location,
        telegramAccount: telegramAccount,
        bio: description,
        workingHours: workingHours,
      );

      // Refresh user data
      if (currentUser != null) {
        await _fetchUserData(currentUser);
      }

      print('🔄 ✅ Profile updated successfully');
    } catch (e) {
      print('🔄 ❌ Error updating profile: $e');
      rethrow;
    }
  }

  // Check if email exists in any collection
  Future<bool> _checkEmailExists(String email) async {
    try {
      // Check users collection
      final usersQuery = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (usersQuery.docs.isNotEmpty) return true;

      // Check user_applications collection
      final appsQuery = await _firestore
          .collection('user_applications')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (appsQuery.docs.isNotEmpty) return true;

      // Check userstransed collection
      final trustedQuery = await _firestore
          .collection('userstransed')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      return trustedQuery.docs.isNotEmpty;
    } catch (e) {
      print('Error checking email existence: $e');
      return false;
    }
  }

  Future<String> registerUser({
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
    UserCredential? userCredential;

    try {
      print('📝 Creating new user registration for: $email');

      // Step 1: Check if email already exists in any collection
      final emailExists = await _checkEmailExists(email.toLowerCase());
      if (emailExists) {
        throw Exception('البريد الإلكتروني مستخدم بالفعل');
      }

      // Step 2: Create Firebase Auth user
      userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.toLowerCase(),
        password: password,
      );

      final String firebaseUid = userCredential.user!.uid;
      print('📝 Firebase user created with UID: $firebaseUid');

      // Step 3: Update user profile
      await userCredential.user!.updateDisplayName(fullName);

      // Step 4: Send email verification
      await userCredential.user!.sendEmailVerification();

      // Step 5: Create user document in 'users' collection with default states
      final userData = _createDefaultUserData(
        firebaseUid: firebaseUid,
        email: email,
        fullName: fullName,
        phoneNumber: phoneNumber,
        additionalPhone: additionalPhone,
        serviceProvider: serviceProvider,
        location: location,
        telegramAccount: telegramAccount,
        description: description,
        workingHours: workingHours,
      );

      // Create user document
      await _firestore.collection('users').doc(firebaseUid).set(userData);

      // Step 6: Also create in user_applications for admin review (backward compatibility)
      final applicationData = _createApplicationData(
        firebaseUid: firebaseUid,
        email: email,
        fullName: fullName,
        phoneNumber: phoneNumber,
        additionalPhone: additionalPhone,
        serviceProvider: serviceProvider,
        location: location,
        telegramAccount: telegramAccount,
        description: description,
        workingHours: workingHours,
      );

      await _firestore
          .collection('user_applications')
          .doc(firebaseUid)
          .set(applicationData);

      print('📝 ✅ User registration completed with default states:');
      print('  - isAuthenticated: true (has Firebase account)');
      print('  - isTrustedUser: false (not yet trusted)');
      print('  - isAdmin: false (regular user)');
      print('  - isApproved: false (pending approval)');

      return firebaseUid;
    } catch (e) {
      print('📝 ❌ Error during user registration: $e');

      // Cleanup: Delete Firebase user if created but process failed
      if (userCredential?.user != null) {
        try {
          await userCredential!.user!.delete();
          print('📝 Cleaned up Firebase user due to registration error');
        } catch (deleteError) {
          print('📝 Error cleaning up Firebase user: $deleteError');
        }
      }

      rethrow;
    }
  }

  // UPDATED: Create default user data with proper states
  Map<String, dynamic> _createDefaultUserData({
    required String firebaseUid,
    required String email,
    required String fullName,
    required String phoneNumber,
    String? additionalPhone,
    required String serviceProvider,
    required String location,
    String? telegramAccount,
    String? description,
    String? workingHours,
  }) {
    final nameParts = fullName.split(' ');

    return {
      'uid': firebaseUid,
      'email': email.toLowerCase(),
      'status': 'pending', // pending|approved|rejected|suspended

      // IMPORTANT: User role and state defaults
      'role': 2, // 0=admin, 1=trusted, 2=common (default for new users)
      'isTrustedUser': false, // Not trusted until approved
      'isApproved': false, // Not approved until admin approves
      'isActive': true, // Account is active

      'profile': {
        'firstName': nameParts.isNotEmpty ? nameParts.first : '',
        'lastName': nameParts.length > 1 ? nameParts.skip(1).join(' ') : '',
        'fullName': fullName,
        'phone': phoneNumber,
        'additionalPhone': additionalPhone ?? '',
        'serviceProvider': serviceProvider,
        'location': location,
        'telegramAccount': telegramAccount ?? '',
        'bio': description ?? '',
        'workingHours': workingHours ?? '',
        'profileImageUrl': '',
      },
      'application': {
        'submittedAt': FieldValue.serverTimestamp(),
        'reviewedAt': null,
        'reviewedBy': null,
        'rejectionReason': null,
      },
      'permissions': {
        'canEditProfile': false, // Can't edit until approved
        'canAccessDashboard': true, // Can login and see pending status
      },
      'verification': {
        'emailVerified': false, // Will be updated when user verifies email
        'phoneVerified': false,
        'documentsSubmitted': false,
      },
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  // Create application data for backward compatibility
  Map<String, dynamic> _createApplicationData({
    required String firebaseUid,
    required String email,
    required String fullName,
    required String phoneNumber,
    String? additionalPhone,
    required String serviceProvider,
    required String location,
    String? telegramAccount,
    String? description,
    String? workingHours,
  }) {
    return {
      'firebaseUid': firebaseUid,
      'email': email.toLowerCase(),
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'additionalPhone': additionalPhone ?? '',
      'serviceProvider': serviceProvider,
      'location': location,
      'telegramAccount': telegramAccount ?? '',
      'description': description ?? '',
      'workingHours': workingHours ?? '',
      'status': 'pending',
      'submittedAt': FieldValue.serverTimestamp(),
      'addedToTrustedTable': false,
      'accountCreated': true,
      'isActive': true,
    };
  }

  // Create user with Firebase Auth
  Future<String> createUserWithFirebaseAuth({
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
    UserCredential? userCredential;

    try {
      print('📝 Creating Firebase Auth user for: $email');

      // Step 1: Check if email already exists
      final emailExists =
          await _applicationService.emailExists(email.toLowerCase());
      if (emailExists) {
        throw Exception('البريد الإلكتروني مستخدم بالفعل');
      }

      // Step 2: Create Firebase Auth user
      userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.toLowerCase(),
        password: password,
      );

      final String firebaseUid = userCredential.user!.uid;
      print('📝 Firebase user created with UID: $firebaseUid');

      // Step 3: Update user profile
      await userCredential.user!.updateDisplayName(fullName);

      // Step 4: Send email verification
      await userCredential.user!.sendEmailVerification();

      // Step 5: Create user document in 'users' collection
      final userData = {
        'uid': firebaseUid,
        'email': email.toLowerCase(),
        'status': 'pending', // pending|approved|rejected|suspended
        'profile': {
          'firstName': extractFirstName(fullName),
          'lastName': extractLastName(fullName),
          'fullName': fullName,
          'phone': phoneNumber,
          'additionalPhone': additionalPhone ?? '',
          'serviceProvider': serviceProvider,
          'location': location,
          'telegramAccount': telegramAccount ?? '',
          'bio': description ?? '',
          'workingHours': workingHours ?? '',
          'profileImageUrl': '',
        },
        'application': {
          'submittedAt': FieldValue.serverTimestamp(),
          'reviewedAt': null,
          'reviewedBy': null,
          'rejectionReason': null,
        },
        'permissions': {
          'canEditProfile': false, // Only true after approval
          'canAccessDashboard': true, // Can login but can't edit
        },
        'verification': {
          'emailVerified': userCredential.user!.emailVerified,
          'phoneVerified': false,
          'documentsSubmitted': false,
        },
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Create user document
      await _firestore.collection('users').doc(firebaseUid).set(userData);

      // Also create in user_applications for admin review
      final applicationData = {
        'firebaseUid': firebaseUid,
        'email': email.toLowerCase(),
        'fullName': fullName,
        'phoneNumber': phoneNumber,
        'additionalPhone': additionalPhone ?? '',
        'serviceProvider': serviceProvider,
        'location': location,
        'telegramAccount': telegramAccount ?? '',
        'description': description ?? '',
        'workingHours': workingHours ?? '',
        'status': 'pending',
        'submittedAt': FieldValue.serverTimestamp(),
        'addedToTrustedTable': false,
      };

      await _firestore
          .collection('user_applications')
          .doc(firebaseUid)
          .set(applicationData);

      print('📝 User documents created successfully');
      print('📝 User registration completed with Firebase UID: $firebaseUid');

      return firebaseUid;
    } catch (e) {
      print('📝 Error during user registration: $e');

      // Cleanup: Delete Firebase user if created but process failed
      if (userCredential?.user != null) {
        try {
          await userCredential!.user!.delete();
          print('📝 Cleaned up Firebase user due to registration error');
        } catch (deleteError) {
          print('📝 Error cleaning up Firebase user: $deleteError');
        }
      }

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
      await _trustedUserService.updatePendingUserApplication(
        email: email,
        fullName: fullName,
        phoneNumber: phoneNumber,
        additionalPhone: additionalPhone,
        serviceProvider: serviceProvider,
        location: location,
        telegramAccount: telegramAccount,
        description: description,
        workingHours: workingHours,
      );

      // Refresh auth state
      await refreshAuthState();
    } catch (e) {
      rethrow;
    }
  }

  // Refresh auth state
  Future<void> refreshAuthState() async {
    try {
      print('🔄 Refreshing auth state...');

      final currentUser = _auth.currentUser;
      if (currentUser != null) {
        // For users with Firebase Auth, refetch their data
        await _fetchUserData(currentUser);
      } else if (state.userEmail != null && state.applicationData != null) {
        // For pending users without Firebase auth, refresh application data
        final refreshedData =
            await _trustedUserService.refreshApplicationData(state.userEmail!);
        if (refreshedData != null) {
          // Check if user was approved and now has Firebase account
          final firebaseUid = refreshedData['firebaseUid'] ?? '';
          final status = refreshedData['status'] ?? '';

          if (firebaseUid.isNotEmpty && status.toLowerCase() == 'approved') {
            // User was approved! Try to sign them in with Firebase Auth
            try {
              await _auth.signInWithEmailAndPassword(
                email: state.userEmail!,
                password: refreshedData['password'] ?? '',
              );
              print('🔄 ✅ User was approved! Signed in with Firebase Auth');
              // _onAuthStateChanged will handle the state update
              return;
            } catch (e) {
              print('🔄 Could not sign in with Firebase Auth: $e');
            }
          }

          // Update state with refreshed application data
          state = state.copyWith(
            applicationData: refreshedData,
            isApproved: status.toLowerCase() == 'approved',
          );
        }
      } else {
        // No current user, reset state
        state = AuthState();
      }

      print('🔄 Auth state refreshed successfully');
    } catch (e) {
      print('🔄 Error refreshing auth state: $e');
      state = state.copyWith(error: 'Failed to refresh: ${e.toString()}');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      // Auth state listener will update the state
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to sign out: ${e.toString()}',
      );
    }
  }

  // Get current user data (works for both approved and pending users)
  Map<String, dynamic>? getCurrentUserData() {
    return state.userData;
  }

  // Get user by Firebase UID
  Future<DocumentSnapshot?> getUserByUid(String uid) async {
    try {
      final doc =
          await _firestore.collection('user_applications').doc(uid).get();
      return doc.exists ? doc : null;
    } catch (e) {
      print('Error getting user by UID: $e');
      return null;
    }
  }

  // Check if user can perform actions (only approved users)
  bool canPerformActions() {
    return state.isAuthenticated &&
        state.isApproved &&
        (state.isTrustedUser || state.isAdmin);
  }

  // Admin methods (delegate to AdminService)
  Future<List<Map<String, dynamic>>> getAllUserApplications() async {
    try {
      return await _adminService.getAllUserApplications();
    } catch (e) {
      print('Error getting all user applications: $e');
      rethrow;
    }
  }

  Future<void> updateUserApplicationStatus(
    String applicationId,
    String status, {
    String? comment,
  }) async {
    try {
      await _adminService.updateUserApplicationStatus(
        applicationId,
        status,
        comment: comment,
      );

      // If approving, add to trusted users table
      if (status.toLowerCase() == 'approved') {
        try {
          await addToTrustedUsersTable(applicationId);
        } catch (e) {
          print('Warning: Could not add to trusted users table: $e');
          // Don't throw - approval was successful
        }
      }
      // If rejecting/suspending, remove from trusted users table
      else if (status.toLowerCase() == 'rejected' ||
          status.toLowerCase() == 'suspended') {
        await removeFromTrustedUsersTable(applicationId);
      }
    } catch (e) {
      print('Error updating application status: $e');
      rethrow;
    }
  }

  Future<Map<String, int>> getApplicationStatistics() async {
    try {
      return await _adminService.getApplicationStatistics();
    } catch (e) {
      print('Error getting application statistics: $e');
      return {};
    }
  }

  // Application methods (delegate to ApplicationService)
  Future<Map<String, dynamic>> getApplicationStatus(String email) async {
    try {
      return await _applicationService.getApplicationStatus(email);
    } catch (e) {
      print('Error getting application status: $e');
      rethrow;
    }
  }

  Future<bool> checkEmailExists(String email) async {
    try {
      return await _applicationService.emailExists(email);
    } catch (e) {
      print('Error checking email exists: $e');
      return false;
    }
  }

  // Clean up subscriptions
  @override
  void dispose() {
    _authStateSubscription?.cancel();
    _refreshTimer?.cancel();
    super.dispose();
  }

  // Debug method
  Future<void> debugListAllUsers() async {
    try {
      print('🔍 =================================');
      print('🔍 LISTING ALL USERS');
      print('🔍 =================================');

      // Check admins collection
      print('🔍 ADMINS COLLECTION:');
      final adminsSnapshot = await _firestore.collection('admins').get();
      print('🔍 Found ${adminsSnapshot.docs.length} admins');

      for (var doc in adminsSnapshot.docs) {
        final data = doc.data();
        print('🔍 Admin UID: ${doc.id}');
        print('  - Role: ${data['role']}');
        print('  - IsAdmin: ${data['isAdmin']}');
        print('  - Email: ${data['email'] ?? 'N/A'}');
        print('  ---');
      }

      // Check users collection
      print('\n🔍 USERS COLLECTION:');
      final usersSnapshot = await _firestore.collection('users').get();
      print('🔍 Found ${usersSnapshot.docs.length} users');

      for (var doc in usersSnapshot.docs) {
        final data = doc.data();
        print('🔍 User UID: ${doc.id}');
        print('  - Email: ${data['email']}');
        print('  - Status: ${data['status']}');
        print('  - Name: ${data['profile']?['fullName']}');
        print('  ---');
      }

      // Check trusted users collection
      print('\n🔍 TRUSTED USERS COLLECTION:');
      final trustedSnapshot = await _firestore.collection('userstransed').get();
      print('🔍 Found ${trustedSnapshot.docs.length} trusted users');

      for (var doc in trustedSnapshot.docs) {
        final data = doc.data();
        print('🔍 Trusted User UID: ${doc.id}');
        print('  - Email: ${data['email']}');
        print('  - Role: ${data['role']}');
        print('  - Approved: ${data['isApproved']}');
        print('  - Name: ${data['fullName']}');
        print('  ---');
      }

      // Check user applications
      print('\n🔍 USER APPLICATIONS COLLECTION:');
      final appsSnapshot =
          await _firestore.collection('user_applications').get();
      print('🔍 Found ${appsSnapshot.docs.length} applications');

      for (var doc in appsSnapshot.docs) {
        final data = doc.data();
        print('🔍 Application ID: ${doc.id}');
        print('  - Email: ${data['email']}');
        print('  - Status: ${data['status']}');
        print('  - Name: ${data['fullName']}');
        print('  - Firebase UID: ${data['firebaseUid'] ?? 'N/A'}');
        print('  ---');
      }

      print('🔍 =================================');
    } catch (e) {
      print('🔍 Error listing users: $e');
    }
  }
}
