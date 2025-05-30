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

class AuthState {
  final User? user;
  final UserRole role;
  final bool isLoading;
  final String? error;
  final Map<String, dynamic>? userData;
  final bool isTrustedUser; // Add this for trusted users

  bool get isAdmin => role == UserRole.admin;
  bool get isAuthenticated => user != null;

  AuthState({
    this.user,
    this.role = UserRole.common,
    this.isLoading = false,
    this.error,
    this.userData,
    this.isTrustedUser = false,
  });

  AuthState copyWith({
    User? user,
    UserRole? role,
    bool? isLoading,
    String? error,
    Map<String, dynamic>? userData,
    bool? isTrustedUser,
  }) {
    return AuthState(
      user: user ?? this.user,
      role: role ?? this.role,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      userData: userData ?? this.userData,
      isTrustedUser: isTrustedUser ?? this.isTrustedUser,
    );
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
          isLoading: false,
          userData: adminData,
          isTrustedUser: false, // Admin is not a trusted user
        );
        return;
      }

      // If not an admin, check if user is a trusted user
      final userDoc = await _firestore.collection('users').doc(user.uid).get();

      if (userDoc.exists) {
        print('🔍 User found in users collection');
        final userData = userDoc.data()!;
        final userRole = userData['role'] ?? '';

        // Check if it's a trusted user
        final isTrustedUser = userRole == 'user' || userRole == 'trusted_user';

        state = state.copyWith(
          user: user,
          role: isTrustedUser ? UserRole.trusted : UserRole.common,
          isLoading: false,
          userData: userData,
          isTrustedUser: isTrustedUser,
        );
        return;
      }

      // User exists in Firebase Auth but not in either collection
      print('🔍 User not found in any collection');
      state = state.copyWith(
        user: user,
        role: UserRole.common,
        isLoading: false,
        userData: null,
        isTrustedUser: false,
      );
    } catch (e) {
      debugPrint('Error fetching user data: $e');
      state = state.copyWith(
        user: user,
        role: UserRole.common,
        isLoading: false,
        error: 'Failed to fetch user data',
        isTrustedUser: false,
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

  // Trusted user sign in method
  Future<void> signInTrustedUser(String email, String password) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      print('🔐 Trusted user sign in attempt for: $email');

      // Add debugging
      print('🔐 Email length: ${email.length}');
      print('🔐 Password length: ${password.length}');
      print('🔐 Email trimmed: "${email.trim()}"');

      state = state.copyWith(isLoading: true, error: null);
      print('🔐 Trusted user sign in attempt for: $email');

      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      print('🔐 Firebase Auth successful, checking trusted user status...');

      // Check if user is a trusted user
      final userDoc =
          await _firestore.collection('users').doc(credential.user!.uid).get();

      if (!userDoc.exists) {
        print('🔐 User document does not exist, signing out...');
        await _auth.signOut();
        throw Exception('المستخدم غير موجود أو لم يتم تفعيل الحساب بعد');
      }

      final userData = userDoc.data()!;
      final role = userData['role'] ?? '';
      final isTrustedUser = role == 'user' || role == 'trusted_user';

      if (!isTrustedUser) {
        print('🔐 User is not a trusted user, signing out...');
        await _auth.signOut();
        throw Exception('لا تملك صلاحيات المستخدم الموثوق');
      }

      // Check if account is active
      final isActive = userData['isActive'] ?? false;
      if (!isActive) {
        print('🔐 User account is not active, signing out...');
        await _auth.signOut();
        throw Exception('حسابك غير نشط، يرجى التواصل مع الإدارة');
      }

      // Auth state listener will update the state
      print('🔐 Trusted user login successful');
    } catch (e) {
      print('🔐 Detailed error: ${e.runtimeType} - $e');
      if (e is FirebaseAuthException) {
        print('🔐 Firebase error code: ${e.code}');
        print('🔐 Firebase error message: ${e.message}');
      }
      print('🔐 Trusted user login error: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  // Registration method for trusted users
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

  // Get application status by email
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

  // Admin method: Get all user applications
  Future<List<Map<String, dynamic>>> getAllUserApplications() async {
    try {
      final applications = await _firestore
          .collection('user_applications')
          .orderBy('createdAt', descending: true)
          .get();

      return applications.docs.map((doc) {
        final data = doc.data();
        // Convert Firestore timestamps to strings
        if (data['createdAt'] != null) {
          data['createdAt'] =
              (data['createdAt'] as Timestamp).toDate().toIso8601String();
        }
        if (data['updatedAt'] != null) {
          data['updatedAt'] =
              (data['updatedAt'] as Timestamp).toDate().toIso8601String();
        }
        return data;
      }).toList();
    } catch (e) {
      rethrow;
    }
  }

  // Admin method: Update application status
  Future<void> updateUserApplicationStatus(String applicationId, String status,
      {String? comment}) async {
    try {
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

      // If approved, create Firebase Auth account and user document
      if (status.toLowerCase() == 'approved') {
        await _createApprovedUserAccount(applicationId);
      }
    } catch (e) {
      rethrow;
    }
  }

  // Private method: Create Firebase Auth account for approved users
  Future<void> _createApprovedUserAccount(String applicationId) async {
    try {
      final applicationDoc = await _firestore
          .collection('user_applications')
          .doc(applicationId)
          .get();

      if (!applicationDoc.exists) return;

      final applicationData = applicationDoc.data()!;
      final email = applicationData['email'];
      final password = applicationData['password'];
      final fullName = applicationData['fullName'];

      // Create Firebase Auth account
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

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

      // Update application with user ID
      await _firestore
          .collection('user_applications')
          .doc(applicationId)
          .update({
        'firebaseUid': userCredential.user!.uid,
        'accountCreated': true,
        'accountCreatedAt': FieldValue.serverTimestamp(),
      });

      // Sign out the newly created user (since we're in admin context)
      await _auth.signOut();
    } catch (e) {
      // Log error but don't throw - the status update should still succeed
      print('Error creating user account: $e');
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

  // Get current user data
  Future<Map<String, dynamic>?> getCurrentUserData() async {
    try {
      if (state.user == null) return null;
      return state.userData;
    } catch (e) {
      return null;
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
