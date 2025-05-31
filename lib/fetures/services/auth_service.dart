import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// User roles
enum UserRole {
  admin(0),
  trusted(1),
  common(2),
  betrug(3);

  final int value;
  const UserRole(this.value);

  static UserRole fromInt(int value) {
    return UserRole.values.firstWhere(
      (role) => role.value == value,
      orElse: () => UserRole.common,
    );
  }
}

// Updated AuthState with toString method for better debugging
class AuthState {
  final bool isLoading;
  final bool isAuthenticated;
  final UserRole role;
  final User? user;
  final Map<String, dynamic>? userData;
  final Map<String, dynamic>? applicationData; // For pending users
  final String? userEmail; // For pending users without Firebase auth
  final bool isTrustedUser;
  final bool isApproved; // Whether trusted user is approved
  final String? error;

  const AuthState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.role = UserRole.common,
    this.user,
    this.userData,
    this.applicationData,
    this.userEmail,
    this.isTrustedUser = false,
    this.isApproved = false,
    this.error,
  });

  // Computed getters for compatibility
  bool get isAdmin => role == UserRole.admin;

  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    UserRole? role,
    User? user,
    Map<String, dynamic>? userData,
    Map<String, dynamic>? applicationData,
    String? userEmail,
    bool? isTrustedUser,
    bool? isApproved,
    String? error,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      role: role ?? this.role,
      user: user ?? this.user,
      userData: userData ?? this.userData,
      applicationData: applicationData ?? this.applicationData,
      userEmail: userEmail ?? this.userEmail,
      isTrustedUser: isTrustedUser ?? this.isTrustedUser,
      isApproved: isApproved ?? this.isApproved,
      error: error ?? this.error,
    );
  }

  @override
  String toString() {
    return 'AuthState('
        'isLoading: $isLoading, '
        'isAuthenticated: $isAuthenticated, '
        'role: $role, '
        'user: ${user?.email ?? 'null'}, '
        'isTrustedUser: $isTrustedUser, '
        'isApproved: $isApproved, '
        'userEmail: $userEmail, '
        'hasUserData: ${userData != null}, '
        'hasApplicationData: ${applicationData != null}, '
        'error: $error'
        ')';
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthNotifier(this._auth, this._firestore) : super(AuthState()) {
    // Listen to auth state changes
    _auth.authStateChanges().listen((user) async {
      if (user == null) {
        state = AuthState();
      } else {
        await _fetchUserData(user);
      }
    });
  }
// Add these enhanced debug methods to your AuthNotifier class
// Add this improved method to your AuthNotifier class
// This will fix the existing broken user and create a proper one

  Future<void> fixAndCreateTrustedUser() async {
    try {
      print('🔧 =================================');
      print('🔧 FIXING TRUSTED USER CREATION');
      print('🔧 =================================');

      final email = 'trusteduser@example.com';
      final password = '123456';

      // Step 1: Clean up existing broken user
      print('🔧 Step 1: Cleaning up existing user...');

      // Find the existing user document in Firestore
      final usersQuery = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      if (usersQuery.docs.isNotEmpty) {
        print('🔧 Found existing Firestore user document, deleting...');
        for (var doc in usersQuery.docs) {
          await doc.reference.delete();
          print('🔧 Deleted Firestore document: ${doc.id}');
        }
      }

      // Check if Firebase Auth user exists (it shouldn't based on debug)
      try {
        final methods = await _auth.fetchSignInMethodsForEmail(email);
        //fetchSignInMethodsForEmail
        if (methods.isNotEmpty) {
          print('🔧 Firebase Auth user exists, need to handle...');
          // This case shouldn't happen based on your debug, but just in case
        } else {
          print('🔧 No Firebase Auth user found (as expected)');
        }
      } catch (e) {
        print('🔧 Error checking Firebase Auth: $e');
      }

      // Step 2: Create complete user (both Firebase Auth and Firestore)
      print('🔧 Step 2: Creating complete user...');

      // Create Firebase Auth account
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = userCredential.user!.uid;
      print('🔧 ✅ Firebase Auth user created with UID: $uid');

      // Set display name
      await userCredential.user!.updateDisplayName('Test Trusted User');

      // Create Firestore document with the correct UID
      await _firestore.collection('users').doc(uid).set({
        'uid': uid,
        'email': email,
        'fullName': 'Test Trusted User',
        'role': 'user', // This makes them a trusted user
        'isActive': true,
        'phoneNumber': '+966123456789',
        'serviceProvider': 'Test Company',
        'location': 'Test City',
        'createdAt': FieldValue.serverTimestamp(),
      });

      print('🔧 ✅ Firestore user document created with correct UID!');

      // Step 3: Verify the fix
      print('🔧 Step 3: Verifying the fix...');

      // Check Firebase Auth
      final authMethods = await _auth.fetchSignInMethodsForEmail(email);
      print('🔧 Firebase Auth methods: $authMethods');

      // Check Firestore
      final userDoc = await _firestore.collection('users').doc(uid).get();
      print('🔧 Firestore document exists: ${userDoc.exists}');
      if (userDoc.exists) {
        print('🔧 User data: ${userDoc.data()}');
      }

      // Step 4: Test login
      print('🔧 Step 4: Testing login...');

      try {
        final testCredential = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        print('🔧 ✅ Login test successful! UID: ${testCredential.user!.uid}');

        // Sign out immediately
        await _auth.signOut();
        print('🔧 Signed out test user');
      } catch (loginError) {
        print('🔧 ❌ Login test failed: $loginError');
      }

      // Reset auth state
      state = AuthState();

      print('🔧 =================================');
      print('🔧 USER FIXED AND CREATED SUCCESSFULLY!');
      print('🔧 Email: $email');
      print('🔧 Password: $password');
      print('🔧 You can now login with these credentials');
      print('🔧 =================================');
    } catch (e) {
      print('🔧 ❌ Error fixing user: $e');
      rethrow;
    }
  }

// Alternative: Create user with different email if the above doesn't work
  Future<void> createFreshTrustedUser() async {
    try {
      print('🆕 =================================');
      print('🆕 CREATING FRESH TRUSTED USER');
      print('🆕 =================================');

      final email = 'newtrusteduser@example.com'; // Different email
      final password = '123456';

      // Step 1: Create Firebase Auth account
      print('🆕 Step 1: Creating Firebase Auth user...');
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = userCredential.user!.uid;
      print('🆕 ✅ Firebase Auth user created with UID: $uid');

      // Step 2: Create Firestore document
      print('🆕 Step 2: Creating Firestore user document...');
      await _firestore.collection('users').doc(uid).set({
        'uid': uid,
        'email': email,
        'fullName': 'New Trusted User',
        'role': 'user',
        'isActive': true,
        'phoneNumber': '+966987654321',
        'serviceProvider': 'New Test Company',
        'location': 'New Test City',
        'createdAt': FieldValue.serverTimestamp(),
      });

      print('🆕 ✅ Firestore user document created!');

      // Step 3: Test login immediately
      print('🆕 Step 3: Testing login...');
      try {
        await _auth.signOut(); // Make sure we're signed out first

        final testCredential = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        print('🆕 ✅ Login test successful! UID: ${testCredential.user!.uid}');

        // Sign out
        await _auth.signOut();
      } catch (loginError) {
        print('🆕 ❌ Login test failed: $loginError');
      }

      // Reset auth state
      state = AuthState();

      print('🆕 =================================');
      print('🆕 FRESH USER CREATED SUCCESSFULLY!');
      print('🆕 Email: $email');
      print('🆕 Password: $password');
      print('🆕 =================================');
    } catch (e) {
      print('🆕 ❌ Error creating fresh user: $e');
      rethrow;
    }
  }

// Method to create a complete test trusted user
  Future<void> createCompleteTrustedUser() async {
    try {
      print('🧪 =================================');
      print('🧪 CREATING COMPLETE TRUSTED USER');
      print('🧪 =================================');

      final email = 'trusteduser@example.com';
      final password = '123456';

      // Step 1: Check if user already exists
      try {
        final methods = await _auth.fetchSignInMethodsForEmail(email);
        if (methods.isNotEmpty) {
          print('🧪 User already exists in Firebase Auth, deleting first...');
          // Sign in to get the user
          final credential = await _auth.signInWithEmailAndPassword(
            email: email,
            password: password,
          );
          // Delete the user
          await credential.user!.delete();
          await _auth.signOut();
          print('🧪 Existing user deleted');
        }
      } catch (e) {
        print('🧪 No existing user found or error checking: $e');
      }

      // Step 2: Create Firebase Auth user
      print('🧪 Step 1: Creating Firebase Auth user...');
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = userCredential.user!.uid;
      print('🧪 ✅ Firebase Auth user created with UID: $uid');

      // Step 3: Create Firestore users document
      print('🧪 Step 2: Creating Firestore user document...');
      await _firestore.collection('users').doc(uid).set({
        'uid': uid,
        'email': email,
        'fullName': 'Test Trusted User',
        'role': 'user', // This makes them a trusted user
        'isActive': true,
        'phoneNumber': '+966123456789',
        'serviceProvider': 'Test Company',
        'location': 'Test City',
        'createdAt': FieldValue.serverTimestamp(),
      });

      print('🧪 ✅ Firestore user document created!');

      // Step 4: Verify creation
      print('🧪 Step 3: Verifying user creation...');

      // Check Firebase Auth
      final authMethods = await _auth.fetchSignInMethodsForEmail(email);
      print('🧪 Firebase Auth methods: $authMethods');

      // Check Firestore
      final userDoc = await _firestore.collection('users').doc(uid).get();
      print('🧪 Firestore document exists: ${userDoc.exists}');
      if (userDoc.exists) {
        print('🧪 User data: ${userDoc.data()}');
      }

      // Step 5: Sign out the test user
      await _auth.signOut();
      state = AuthState();

      print('🧪 =================================');
      print('🧪 TRUSTED USER CREATED SUCCESSFULLY!');
      print('🧪 Email: $email');
      print('🧪 Password: $password');
      print('🧪 UID: $uid');
      print('🧪 =================================');
    } catch (e) {
      print('🧪 ❌ Error creating trusted user: $e');
      rethrow;
    }
  }

// Method to test login with specific credentials
  Future<void> testLoginWithCredentials(String email, String password) async {
    try {
      print('🧪 =================================');
      print('🧪 TESTING LOGIN WITH CREDENTIALS');
      print('🧪 Email: $email');
      print('🧪 =================================');

      // Step 1: Check if email exists in Firebase Auth
      print('🧪 Step 1: Checking if email exists in Firebase Auth...');
      final methods = await _auth.fetchSignInMethodsForEmail(email);
      print('🧪 Sign-in methods for $email: $methods');

      if (methods.isEmpty) {
        print('🧪 ❌ Email does not exist in Firebase Auth!');
        throw Exception('البريد الإلكتروني غير موجود في النظام');
      }

      // Step 2: Try Firebase Auth sign in
      print('🧪 Step 2: Attempting Firebase Auth sign in...');
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      print('🧪 ✅ Firebase Auth successful!');
      print('🧪 User UID: ${credential.user!.uid}');
      print('🧪 User email: ${credential.user!.email}');
      print('🧪 Email verified: ${credential.user!.emailVerified}');

      // Step 3: Check Firestore document
      print('🧪 Step 3: Checking Firestore user document...');
      final userDoc =
          await _firestore.collection('users').doc(credential.user!.uid).get();

      print('🧪 User document exists: ${userDoc.exists}');

      if (userDoc.exists) {
        final userData = userDoc.data()!;
        print('🧪 User data: $userData');
        print('🧪 Role: ${userData['role']}');
        print('🧪 Is Active: ${userData['isActive']}');
      } else {
        print('🧪 ❌ User document does not exist in Firestore!');
      }

      // Step 4: Sign out
      await _auth.signOut();
      state = AuthState();

      print('🧪 =================================');
      print('🧪 LOGIN TEST COMPLETED');
      print('🧪 =================================');
    } catch (e) {
      print('🧪 ❌ Login test error: $e');

      // Try to sign out in case of partial success
      try {
        await _auth.signOut();
        state = AuthState();
      } catch (signOutError) {
        print('🧪 Error during sign out: $signOutError');
      }

      rethrow;
    }
  }

// Method to list all users in both collections
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
        print('  - Role: ${data['role']}');
        print('  - Active: ${data['isActive']}');
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

// Method to check specific email across all systems
  Future<Map<String, bool>> checkEmailEverywhere(String email) async {
    final results = <String, bool>{};

    try {
      // Check Firebase Auth
      final methods = await _auth.fetchSignInMethodsForEmail(email);
      results['firebase_auth'] = methods.isNotEmpty;
      print('🔍 Firebase Auth: ${results['firebase_auth']}');

      // Check admins collection
      final adminsQuery = await _firestore
          .collection('admins')
          .where('email', isEqualTo: email)
          .get();
      results['admins_collection'] = adminsQuery.docs.isNotEmpty;
      print('🔍 Admins collection: ${results['admins_collection']}');

      // Check users collection
      final usersQuery = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .get();
      results['users_collection'] = usersQuery.docs.isNotEmpty;
      print('🔍 Users collection: ${results['users_collection']}');

      // Check user applications
      final appsQuery = await _firestore
          .collection('user_applications')
          .where('email', isEqualTo: email)
          .get();
      results['user_applications'] = appsQuery.docs.isNotEmpty;
      print('🔍 User applications: ${results['user_applications']}');
    } catch (e) {
      print('🔍 Error checking email: $e');
    }

    return results;
  }

// Updated _fetchUserData method
  Future<void> _fetchUserData(User user) async {
    try {
      state = state.copyWith(isLoading: true);
      print('🔍 Fetching user data for UID: ${user.uid}');

      // First, check if user is an admin
      final adminDoc =
          await _firestore.collection('admins').doc(user.uid).get();

      if (adminDoc.exists) {
        print('🔍 User found in admins collection');
        final adminData = adminDoc.data()!;
        final roleValue = adminData['role'] as int? ?? 2;

        state = state.copyWith(
          user: user,
          role: UserRole.fromInt(roleValue),
          isAuthenticated: true,
          isLoading: false,
          userData: adminData,
          isTrustedUser: false,
          isApproved: true, // Admins are always approved
        );
        return;
      }

      // If not an admin, check if user is a trusted user
      final userDoc =
          await _firestore.collection('user_applications').doc(user.uid).get();

      if (userDoc.exists) {
        print('🔍 User found in users collection');
        final userData = userDoc.data()!;
        final userRole = userData['role'] ?? '';

        // Check if it's a trusted user
        final isTrustedUser = userRole == 'user' || userRole == 'trusted_user';

        // Get application data if available
        Map<String, dynamic>? applicationData;
        if (isTrustedUser && userData['applicationId'] != null) {
          try {
            final appDoc = await _firestore
                .collection('user_applications')
                .doc(userData['applicationId'])
                .get();
            if (appDoc.exists) {
              applicationData = appDoc.data();
            }
          } catch (e) {
            print('🔍 Could not fetch application data: $e');
          }
        }

        state = state.copyWith(
          user: user,
          role: isTrustedUser ? UserRole.trusted : UserRole.common,
          isAuthenticated: true,
          isLoading: false,
          userData: userData,
          applicationData: applicationData,
          isTrustedUser: isTrustedUser,
          isApproved:
              isTrustedUser, // If they have a Firebase account, they're approved
        );
        return;
      }

      // User exists in Firebase Auth but not in either collection
      print('🔍 User not found in any collection');
      state = state.copyWith(
        user: user,
        role: UserRole.common,
        isAuthenticated: true,
        isLoading: false,
        userData: null,
        isTrustedUser: false,
        isApproved: false,
      );
    } catch (e) {
      debugPrint('Error fetching user data: $e');
      state = state.copyWith(
        user: user,
        role: UserRole.common,
        isAuthenticated: true,
        isLoading: false,
        error: 'Failed to fetch user data',
        isTrustedUser: false,
        isApproved: false,
      );
    }
  }

  // Admin sign in method
  Future<void> signIn(String email, String password) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
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

      // Auth state listener will update the state
      print('🔐 Admin login successful');
    } catch (e) {
      print('🔐 Admin login error: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

// Corrected signInTrustedUser method using your UserRole enum
  Future<void> signInTrustedUser(String email, String password) async {
    try {
      print('🔐 =================================');
      print('🔐 STARTING TRUSTED USER SIGN IN');
      print('🔐 =================================');

      state = state.copyWith(isLoading: true, error: null);
      print('🔐 Initial state set to loading');
      print('🔐 Email: $email');
      print('🔐 Password length: ${password.length}');

      // First, check if there's an application for this email
      print('🔍 Searching for application...');
      final applicationQuery = await _firestore
          .collection('user_applications')
          .where('email', isEqualTo: email.toLowerCase())
          .get();

      print(
          '🔍 Query completed. Found ${applicationQuery.docs.length} applications');

      if (applicationQuery.docs.isEmpty) {
        print('🔐 No application found for email: $email');
        throw Exception('لم يتم العثور على طلب تسجيل بهذا البريد الإلكتروني');
      }

      final applicationDoc = applicationQuery.docs.first;
      final applicationData = applicationDoc.data();
      final applicationStatus = applicationData['status'] ?? '';

      print('🔍 Application found:');
      print('  - Document ID: ${applicationDoc.id}');
      print('  - Status: "$applicationStatus"');
      print('  - Email: ${applicationData['email']}');
      print('  - Full Name: ${applicationData['fullName']}');

      // Verify password matches the one in application
      if (applicationData['password'] != password) {
        print('🔐 PASSWORD MISMATCH!');
        print('🔐 Stored: "${applicationData['password']}"');
        print('🔐 Provided: "$password"');
        throw Exception('كلمة المرور غير صحيحة');
      }

      print('🔐 Password verification PASSED');
      print('🔐 Application status: "$applicationStatus"');

      // Handle APPROVED users with Firebase Auth
      if (applicationStatus.toLowerCase() == 'approved') {
        print('🔐 Status is APPROVED - attempting Firebase Auth');
        try {
          final credential = await _auth.signInWithEmailAndPassword(
            email: email,
            password: password,
          );

          print('🔐 Firebase Auth successful for approved user');
          print('🔐 User UID: ${credential.user?.uid}');

          // Let the auth state listener handle the rest via _fetchUserData
          return; // _fetchUserData will be called by the auth listener
        } catch (e) {
          print('🔐 Firebase Auth failed: $e');
          if (e is FirebaseAuthException && e.code == 'user-not-found') {
            print('🔐 User not found in Firebase Auth, creating account...');
            // Approved but Firebase account not created yet - create it
            await _createFirebaseAccountForApprovedUser(
                applicationDoc.id, applicationData);

            // Try login again
            print('🔐 Attempting login again after account creation...');
            final credential = await _auth.signInWithEmailAndPassword(
              email: email,
              password: password,
            );

            print('🔐 Second login attempt successful');
            return; // _fetchUserData will be called by the auth listener
          }
          throw Exception('حدث خطأ في النظام، يرجى التواصل مع الإدارة');
        }
      }

      // Handle ALL OTHER STATUSES (pending, rejected, etc.) - Allow access
      print(
          '🔐 Status is NOT approved - allowing dashboard access with status: $applicationStatus');
      print('🔐 Preparing user state...');

      // Create user data from application - works for any status
      final userData = {
        'fullName': applicationData['fullName'],
        'email': applicationData['email'],
        'phoneNumber': applicationData['phoneNumber'],
        'additionalPhone': applicationData['additionalPhone'] ?? '',
        'serviceProvider': applicationData['serviceProvider'],
        'location': applicationData['location'],
        'role': _getRoleFromStatus(applicationStatus),
        'status': applicationStatus,
        'adminComment': applicationData['adminComment'] ?? '',
      };

      print('🔐 User data created:');
      print('  - Full Name: ${userData['fullName']}');
      print('  - Email: ${userData['email']}');
      print('  - Status: ${userData['status']}');
      print('  - Role: ${userData['role']}');

      // Update state - ALL users get authenticated
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true, // ✅ ALWAYS authenticate if password is correct
        role: UserRole.trusted,
        isTrustedUser: true, // ✅ ALWAYS mark as trusted user
        isApproved: applicationStatus.toLowerCase() ==
            'approved', // Only approved users get full access
        userData: userData,
        applicationData: applicationData,
        userEmail: email,
        error: null,
      );

      print('🔐 State AFTER update:');
      print('  - isAuthenticated: ${state.isAuthenticated}'); // Should be true
      print('  - isTrustedUser: ${state.isTrustedUser}'); // Should be true
      print('  - isApproved: ${state.isApproved}'); // True only for approved
      print('  - User status: ${userData['status']}');

      print('🔐 =================================');
      print('🔐 TRUSTED USER SIGN IN COMPLETED');
      print('🔐 ✅ USER AUTHENTICATED - Dashboard access granted');
      print('🔐 =================================');
    } catch (e, stackTrace) {
      print('🔐 ❌ ERROR in signInTrustedUser:');
      print('🔐 Error type: ${e.runtimeType}');
      print('🔐 Error message: $e');

      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

// Helper method to determine role based on status
  String _getRoleFromStatus(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return 'approved';
      case 'rejected':
        return 'rejected';
      case 'in_progress':
        return 'pending';
      case 'needs_review':
        return 'under_review';
      default:
        return 'pending';
    }
  }

// Helper method to create Firebase account for approved users
  Future<void> _createFirebaseAccountForApprovedUser(
      String applicationId, Map<String, dynamic> applicationData) async {
    try {
      print('🔧 Creating Firebase account for approved user...');

      final email = applicationData['email'];
      final password = applicationData['password'];
      final fullName = applicationData['fullName'];

      print('🔧 Creating auth account for: $email');

      // Create Firebase Auth account
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      print(
          '🔧 Firebase Auth account created, UID: ${userCredential.user?.uid}');

      // Update display name
      await userCredential.user?.updateDisplayName(fullName);

      // Create user document in Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
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

      print('🔧 User document created in Firestore');

      // Update application with user ID
      await _firestore
          .collection('user_applications')
          .doc(applicationId)
          .update({
        'firebaseUid': userCredential.user!.uid,
        'accountCreated': true,
        'accountCreatedAt': FieldValue.serverTimestamp(),
      });

      print('🔧 Application updated with Firebase UID');
      print('🔧 Firebase account creation completed successfully');
    } catch (e) {
      print('🔧 Error creating Firebase account: $e');
      rethrow;
    }
  }

  // Registration method for trusted users
// Updated registration method - no changes needed, but shown for completeness
  Future<void> registerUser({
    required String fullName,
    required String email,
    required String password,
    required String phoneNumber,
    String? additionalPhone,
    required String serviceProvider,
    required String location,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      // Check if email is already registered
      final existingApplication = await _firestore
          .collection('user_applications')
          .where('email', isEqualTo: email.toLowerCase())
          .get();

      if (existingApplication.docs.isNotEmpty) {
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
        'status': 'in_progress',
        'adminComment': '',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      final docRef =
          await _firestore.collection('user_applications').add(applicationData);

      // Update with document ID
      await docRef.update({'uid': docRef.id});

      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
      rethrow;
    }
  }

// Enhanced method to get all applications with better error handling
  Future<List<Map<String, dynamic>>> getAllUserApplications() async {
    try {
      print('🔧 Admin: Fetching all user applications...');

      final applications = await _firestore
          .collection('user_applications')
          .orderBy('createdAt', descending: true)
          .get();

      print('🔧 Admin: Found ${applications.docs.length} applications');

      final result = applications.docs.map((doc) {
        final data = doc.data();

        // Add document ID to the data
        data['id'] = doc.id;

        // Convert Firestore timestamps to strings
        if (data['createdAt'] != null) {
          try {
            data['createdAt'] =
                (data['createdAt'] as Timestamp).toDate().toIso8601String();
          } catch (e) {
            print('🔧 Error converting createdAt timestamp: $e');
            data['createdAt'] = 'غير محدد';
          }
        }
        if (data['updatedAt'] != null) {
          try {
            data['updatedAt'] =
                (data['updatedAt'] as Timestamp).toDate().toIso8601String();
          } catch (e) {
            print('🔧 Error converting updatedAt timestamp: $e');
            data['updatedAt'] = 'غير محدد';
          }
        }

        return data;
      }).toList();

      print('🔧 Admin: Applications processed successfully');
      return result;
    } catch (e, stackTrace) {
      print('🔧 Admin: Error fetching applications: $e');
      print('🔧 Stack trace: $stackTrace');
      rethrow;
    }
  }

// Admin method: Update application status with better error handling
  Future<void> updateUserApplicationStatus(String applicationId, String status,
      {String? comment}) async {
    try {
      print('🔧 Admin: Starting status update');
      print('  - Application ID: $applicationId');
      print('  - New Status: $status');
      print('  - Comment: $comment');

      // First, update the application status
      final updateData = {
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (comment != null) {
        updateData['adminComment'] = comment;
      }

      await _firestore
          .collection('user_applications')
          .doc(applicationId)
          .update(updateData);

      print('🔧 Admin: Application status updated successfully');

      // If approved, create Firebase Auth account and user document
      if (status.toLowerCase() == 'approved') {
        print('🔧 Admin: Status is approved, creating Firebase account...');
        await _createApprovedUserAccount(applicationId);
      }

      print('🔧 Admin: Status update completed successfully');
    } catch (e, stackTrace) {
      print('🔧 Admin: Error in updateUserApplicationStatus: $e');
      print('🔧 Admin: Stack trace: $stackTrace');
      rethrow;
    }
  }

// Improved method to create Firebase Auth account for approved users
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

      if (userCredential?.user == null) {
        throw Exception('فشل في إنشاء أو الوصول للحساب');
      }

      final user = userCredential!.user!;

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

  // Debug methods
  Future<void> debugCheckAllCollections() async {
    try {
      print('🔍 =================================');
      print('🔍 CHECKING ALL COLLECTIONS');
      print('🔍 =================================');

      // Check admins collection
      print('🔍 Checking admins collection...');
      final adminsSnapshot = await _firestore.collection('admins').get();
      print('🔍 Found ${adminsSnapshot.docs.length} admins');

      for (var doc in adminsSnapshot.docs) {
        final data = doc.data();
        print('🔍 Admin ${doc.id}:');
        print('  - Role: ${data['role']}');
        print('  - IsAdmin: ${data['isAdmin']}');
      }

      // Check users collection
      print('\n🔍 Checking users collection...');
      final usersSnapshot = await _firestore.collection('users').get();
      print('🔍 Found ${usersSnapshot.docs.length} users');

      for (var doc in usersSnapshot.docs) {
        final data = doc.data();
        print('🔍 User ${doc.id}:');
        print('  - Email: ${data['email']}');
        print('  - Role: ${data['role']}');
        print('  - Active: ${data['isActive']}');
      }

      // Check user_applications collection
      print('\n🔍 Checking user_applications collection...');
      final applicationsSnapshot =
          await _firestore.collection('user_applications').get();
      print('🔍 Found ${applicationsSnapshot.docs.length} applications');

      for (var doc in applicationsSnapshot.docs) {
        final data = doc.data();
        print('🔍 Application ${doc.id}:');
        print('  - Email: ${data['email']}');
        print('  - Status: ${data['status']}');
      }

      print('🔍 =================================');
    } catch (e) {
      print('🔍 Error checking collections: $e');
    }
  }

  Future<void> createTestUserDirectly() async {
    try {
      print('🧪 Creating test trusted user...');

      // Create Firebase Auth user
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: 'test@example.com',
        password: '123456',
      );

      final uid = userCredential.user!.uid;

      // Create Firestore users document
      await _firestore.collection('users').doc(uid).set({
        'uid': uid,
        'email': 'test@example.com',
        'fullName': 'Test Trusted User',
        'role': 'user',
        'isActive': true,
        'phoneNumber': '+966123456789',
        'serviceProvider': 'Test Company',
        'location': 'Test City',
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Sign out the test user
      await _auth.signOut();
      state = AuthState();

      print('🧪 Test trusted user created successfully!');
    } catch (e) {
      print('🧪 Error creating test user: $e');
      rethrow;
    }
  }

  Future<bool> checkEmailExists(String email) async {
    try {
      final methods = await _auth.fetchSignInMethodsForEmail(email);
      return methods.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      // Auth state listener will update the state
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to sign out',
      );
    }
  }

// Method to get current user data (works for both approved and pending users)
  Map<String, dynamic>? getCurrentUserData() {
    final currentState = state;

    if (currentState.isApproved && currentState.userData != null) {
      // Approved user - return Firebase user data
      return currentState.userData;
    } else if (!currentState.isApproved &&
        currentState.applicationData != null) {
      // Pending user - return application data formatted like user data
      final appData = currentState.applicationData!;
      return {
        'fullName': appData['fullName'],
        'email': appData['email'],
        'phoneNumber': appData['phoneNumber'],
        'additionalPhone': appData['additionalPhone'] ?? '',
        'serviceProvider': appData['serviceProvider'],
        'location': appData['location'],
        'role': 'pending',
        'status': appData['status'],
      };
    }

    return null;
  }

// Method to check if user can perform actions (only approved users)
  bool canPerformActions() {
    return state.isAuthenticated && state.isApproved;
  }

// Method to get application status
  Future<Map<String, dynamic>> getApplicationStatus(String email) async {
    try {
      final applications = await _firestore
          .collection('user_applications')
          .where('email', isEqualTo: email.toLowerCase())
          .get();

      if (applications.docs.isEmpty) {
        throw Exception('لم يتم العثور على طلب بهذا البريد الإلكتروني');
      }

      final applicationData = applications.docs.first.data();

      // Convert Firestore timestamps to strings
      if (applicationData['createdAt'] != null) {
        applicationData['createdAt'] =
            (applicationData['createdAt'] as Timestamp)
                .toDate()
                .toIso8601String();
      }
      if (applicationData['updatedAt'] != null) {
        applicationData['updatedAt'] =
            (applicationData['updatedAt'] as Timestamp)
                .toDate()
                .toIso8601String();
      }

      return applicationData;
    } catch (e) {
      rethrow;
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

// Providers
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final firebaseFirestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final auth = ref.watch(firebaseAuthProvider);
  final firestore = ref.watch(firebaseFirestoreProvider);
  return AuthNotifier(auth, firestore);
});

// Helper providers
final isAdminProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isAdmin;
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isAuthenticated;
});

final isTrustedUserProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isTrustedUser;
});

// Application statistics provider
final applicationStatsProvider = FutureProvider<Map<String, int>>((ref) async {
  final authNotifier = ref.watch(authProvider.notifier);
  return await authNotifier.getApplicationStatistics();
});
