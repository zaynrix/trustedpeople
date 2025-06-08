// import 'dart:async';
//
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
//
// // User roles
// enum UserRole {
//   admin(0),
//   trusted(1),
//   common(2),
//   betrug(3);
//
//   final int value;
//   const UserRole(this.value);
//
//   static UserRole fromInt(int value) {
//     return UserRole.values.firstWhere(
//       (role) => role.value == value,
//       orElse: () => UserRole.common,
//     );
//   }
// }
//
// // Updated AuthState with toString method for better debugging
// class AuthState {
//   final bool isLoading;
//   final bool isAuthenticated;
//   final UserRole role;
//   final User? user;
//   final Map<String, dynamic>? userData;
//   final Map<String, dynamic>? applicationData; // For pending users
//   final String? userEmail; // For pending users without Firebase auth
//   final bool isTrustedUser;
//   final bool isApproved; // Whether trusted user is approved
//   final String? error;
//
//   const AuthState({
//     this.isLoading = false,
//     this.isAuthenticated = false,
//     this.role = UserRole.common,
//     this.user,
//     this.userData,
//     this.applicationData,
//     this.userEmail,
//     this.isTrustedUser = false,
//     this.isApproved = false,
//     this.error,
//   });
//
//   // Computed getters for compatibility
//   bool get isAdmin => role == UserRole.admin;
//
//   AuthState copyWith({
//     bool? isLoading,
//     bool? isAuthenticated,
//     UserRole? role,
//     User? user,
//     Map<String, dynamic>? userData,
//     Map<String, dynamic>? applicationData,
//     String? userEmail,
//     bool? isTrustedUser,
//     bool? isApproved,
//     String? error,
//   }) {
//     return AuthState(
//       isLoading: isLoading ?? this.isLoading,
//       isAuthenticated: isAuthenticated ?? this.isAuthenticated,
//       role: role ?? this.role,
//       user: user ?? this.user,
//       userData: userData ?? this.userData,
//       applicationData: applicationData ?? this.applicationData,
//       userEmail: userEmail ?? this.userEmail,
//       isTrustedUser: isTrustedUser ?? this.isTrustedUser,
//       isApproved: isApproved ?? this.isApproved,
//       error: error ?? this.error,
//     );
//   }
//
//   @override
//   String toString() {
//     return 'AuthState('
//         'isLoading: $isLoading, '
//         'isAuthenticated: $isAuthenticated, '
//         'role: $role, '
//         'user: ${user?.email ?? 'null'}, '
//         'isTrustedUser: $isTrustedUser, '
//         'isApproved: $isApproved, '
//         'userEmail: $userEmail, '
//         'hasUserData: ${userData != null}, '
//         'hasApplicationData: ${applicationData != null}, '
//         'error: $error'
//         ')';
//   }
// }
//
// class AuthNotifier extends StateNotifier<AuthState> {
//   final FirebaseAuth _auth;
//   final FirebaseFirestore _firestore;
//   StreamSubscription<User?>? _authStateSubscription;
//
//   AuthNotifier(this._auth, this._firestore) : super(AuthState()) {
//     _initializeAuth();
//   }
//   // 🆕 ENHANCED: Better initialization with persistence
//   Future<void> _initializeAuth() async {
//     try {
//       print('🔐 Initializing auth state...');
//
//       // Set loading state
//       state = state.copyWith(isLoading: true);
//
//       // Check if user is already signed in
//       final currentUser = _auth.currentUser;
//       if (currentUser != null) {
//         print('🔐 Found existing user: ${currentUser.email}');
//         await _fetchUserData(currentUser);
//       } else {
//         print('🔐 No existing user found');
//         state = state.copyWith(isLoading: false);
//       }
//
//       // Listen to auth state changes
//       _authStateSubscription =
//           _auth.authStateChanges().listen(_onAuthStateChanged);
//     } catch (e) {
//       print('🔐 Error initializing auth: $e');
//       state = state.copyWith(isLoading: false, error: e.toString());
//     }
//   }
//
//   // 🆕 ENHANCED: Better auth state change handling
//   Future<void> _onAuthStateChanged(User? user) async {
//     try {
//       print('🔐 Auth state changed: ${user?.email ?? 'null'}');
//
//       if (user == null) {
//         print('🔐 User signed out');
//         state = AuthState(); // Reset to default state
//       } else {
//         print('🔐 User signed in, fetching data...');
//         await _fetchUserData(user);
//       }
//     } catch (e) {
//       print('🔐 Error in auth state change: $e');
//       state = state.copyWith(error: e.toString(), isLoading: false);
//     }
//   }
//   // final FirebaseAuth _auth;
//   // final FirebaseFirestore _firestore;
//   //
//   // AuthNotifier(this._auth, this._firestore) : super(AuthState()) {
//   //   // Listen to auth state changes
//   //   _auth.authStateChanges().listen((user) async {
//   //     if (user == null) {
//   //       state = AuthState();
//   //     } else {
//   //       await _fetchUserData(user);
//   //     }
//   //   });
//   // }
//
//   // 🔧 FIXED: Uncommented and enhanced _fetchUserData method
//   // Future<void> _fetchUserData(User user) async {
//   //   try {
//   //     print('🔍 Fetching user data for UID: ${user.uid}');
//   //     print('🔍 User email: ${user.email}');
//   //
//   //     // Don't set loading if we already have some data for this user
//   //     final shouldSetLoading = state.user?.uid != user.uid;
//   //     if (shouldSetLoading) {
//   //       state = state.copyWith(isLoading: true);
//   //     }
//   //
//   //     // First, check if user is an admin
//   //     final adminDoc = await _firestore.collection('admins').doc(user.uid).get();
//   //
//   //     if (adminDoc.exists) {
//   //       print('🔍 User found in admins collection');
//   //       final adminData = adminDoc.data()!;
//   //       final roleValue = adminData['role'] as int? ?? 2;
//   //
//   //       state = state.copyWith(
//   //         user: user,
//   //         role: UserRole.fromInt(roleValue),
//   //         isAuthenticated: true,
//   //         isLoading: false,
//   //         userData: adminData,
//   //         isTrustedUser: false,
//   //         isApproved: true,
//   //         error: null,
//   //       );
//   //       return;
//   //     }
//   //
//   //     // Check if user exists in trusted users table (userstransed)
//   //     final trustedUserDoc = await _firestore
//   //         .collection('userstransed')
//   //         .doc(user.uid)
//   //         .get();
//   //
//   //     if (trustedUserDoc.exists) {
//   //       print('🔍 User found in trusted users table');
//   //       final trustedUserData = trustedUserDoc.data()!;
//   //       final userRole = trustedUserData['role'] as int? ?? 2;
//   //
//   //       // Get application data if available
//   //       Map<String, dynamic>? applicationData;
//   //       final applicationId = trustedUserData['applicationId'];
//   //       if (applicationId != null && applicationId.isNotEmpty) {
//   //         try {
//   //           final appDoc = await _firestore
//   //               .collection('user_applications')
//   //               .doc(applicationId)
//   //               .get();
//   //           if (appDoc.exists) {
//   //             applicationData = appDoc.data();
//   //             applicationData!['documentId'] = appDoc.id;
//   //           }
//   //         } catch (e) {
//   //           print('🔍 Could not fetch application data: $e');
//   //         }
//   //       }
//   //
//   //       state = state.copyWith(
//   //         user: user,
//   //         role: UserRole.fromInt(userRole),
//   //         isAuthenticated: true,
//   //         isLoading: false,
//   //         userData: trustedUserData,
//   //         applicationData: applicationData,
//   //         isTrustedUser: userRole == 1,
//   //         isApproved: trustedUserData['isApproved'] ?? true,
//   //         error: null,
//   //       );
//   //       return;
//   //     }
//   //
//   //     // Check regular users collection
//   //     final userDoc = await _firestore.collection('users').doc(user.uid).get();
//   //
//   //     if (userDoc.exists) {
//   //       print('🔍 User found in users collection');
//   //       final userData = userDoc.data()!;
//   //       final userRole = userData['role'] ?? '';
//   //       final isTrustedUser = userRole == 'user';
//   //
//   //       // Get application data if available
//   //       Map<String, dynamic>? applicationData;
//   //       if (isTrustedUser && userData['applicationId'] != null) {
//   //         try {
//   //           final appDoc = await _firestore
//   //               .collection('user_applications')
//   //               .doc(userData['applicationId'])
//   //               .get();
//   //           if (appDoc.exists) {
//   //             applicationData = appDoc.data();
//   //             applicationData!['documentId'] = appDoc.id;
//   //           }
//   //         } catch (e) {
//   //           print('🔍 Could not fetch application data: $e');
//   //         }
//   //       }
//   //
//   //       state = state.copyWith(
//   //         user: user,
//   //         role: isTrustedUser ? UserRole.trusted : UserRole.common,
//   //         isAuthenticated: true,
//   //         isLoading: false,
//   //         userData: userData,
//   //         applicationData: applicationData,
//   //         isTrustedUser: isTrustedUser,
//   //         isApproved: isTrustedUser,
//   //         error: null,
//   //       );
//   //       return;
//   //     }
//   //
//   //     // User exists in Firebase Auth but not in any collection
//   //     print('🔍 User not found in any collection');
//   //     state = state.copyWith(
//   //       user: user,
//   //       role: UserRole.common,
//   //       isAuthenticated: true,
//   //       isLoading: false,
//   //       userData: null,
//   //       isTrustedUser: false,
//   //       isApproved: false,
//   //       error: null,
//   //     );
//   //
//   //   } catch (e) {
//   //     print('🔍 Error fetching user data: $e');
//   //     state = state.copyWith(
//   //       user: user,
//   //       role: UserRole.common,
//   //       isAuthenticated: true,
//   //       isLoading: false,
//   //       error: 'Failed to fetch user data: ${e.toString()}',
//   //       isTrustedUser: false,
//   //       isApproved: false,
//   //     );
//   //   }
//   // }
//
//   // 🆕 ENHANCED: Better trusted user sign in with state persistence
//   Future<void> signInTrustedUser(String email, String password) async {
//     try {
//       print('🔐 =================================');
//       print('🔐 STARTING TRUSTED USER SIGN IN');
//       print('🔐 =================================');
//
//       state = state.copyWith(isLoading: true, error: null);
//       print('🔐 Email: $email');
//
//       // First, check if there's an application for this email
//       print('🔍 Searching for application...');
//       final applicationQuery = await _firestore
//           .collection('user_applications')
//           .where('email', isEqualTo: email.toLowerCase())
//           .get();
//
//       if (applicationQuery.docs.isEmpty) {
//         print('🔐 No application found for email: $email');
//         throw Exception('لم يتم العثور على طلب تسجيل بهذا البريد الإلكتروني');
//       }
//
//       final applicationDoc = applicationQuery.docs.first;
//       final applicationData = applicationDoc.data();
//       applicationData['documentId'] = applicationDoc.id;
//       final applicationStatus = applicationData['status'] ?? '';
//
//       print('🔍 Application found:');
//       print('  - Status: "$applicationStatus"');
//       print('  - Email: ${applicationData['email']}');
//       print('  - Firebase UID: ${applicationData['firebaseUid']}');
//
//       // Verify password
//       if (applicationData['password'] != password) {
//         print('🔐 PASSWORD MISMATCH!');
//         throw Exception('كلمة المرور غير صحيحة');
//       }
//
//       print('🔐 Password verification PASSED');
//
//       // Check if user has Firebase account (approved users should have one)
//       final firebaseUid = applicationData['firebaseUid'] ?? '';
//
//       if (firebaseUid.isNotEmpty &&
//           applicationStatus.toLowerCase() == 'approved') {
//         print(
//             '🔐 User is approved and has Firebase UID, attempting Firebase Auth...');
//
//         try {
//           final credential = await _auth.signInWithEmailAndPassword(
//             email: email,
//             password: password,
//           );
//
//           print('🔐 ✅ Firebase Auth successful for approved user');
//           // _onAuthStateChanged will handle the rest automatically
//           return;
//         } catch (firebaseError) {
//           print('🔐 ❌ Firebase Auth failed: $firebaseError');
//
//           if (firebaseError is FirebaseAuthException &&
//               firebaseError.code == 'user-not-found') {
//             print('🔐 Creating Firebase account for approved user...');
//             await _createFirebaseAccountForApprovedUser(
//                 applicationDoc.id, applicationData);
//
//             // Try login again
//             final credential = await _auth.signInWithEmailAndPassword(
//               email: email,
//               password: password,
//             );
//             print('🔐 ✅ Second login attempt successful');
//             return;
//           }
//
//           throw firebaseError;
//         }
//       }
//
//       // Handle non-approved users (pending, rejected, etc.)
//       print('🔐 User is not approved, setting up limited access...');
//
//       // For pending users, we set up a special auth state without Firebase user
//       state = state.copyWith(
//         isLoading: false,
//         isAuthenticated: true, // Allow authentication
//         role: UserRole.trusted,
//         isTrustedUser: true,
//         isApproved: applicationStatus.toLowerCase() == 'approved',
//         userData: null, // No Firebase user data yet
//         applicationData: applicationData,
//         userEmail: email,
//         user: null, // No Firebase user object
//         error: null,
//       );
//
//       print('🔐 ✅ Non-approved user authenticated with limited access');
//       print('🔐 Status: $applicationStatus');
//     } catch (e, stackTrace) {
//       print('🔐 ❌ ERROR in signInTrustedUser: $e');
//       state = state.copyWith(
//         isLoading: false,
//         error: e.toString(),
//       );
//       rethrow;
//     }
//   }
//
//   // 🆕 NEW: Method to refresh auth state without losing current state
//   Future<void> refreshAuthState() async {
//     try {
//       print('🔄 Refreshing auth state...');
//
//       final currentUser = _auth.currentUser;
//       if (currentUser != null) {
//         // For users with Firebase Auth, refetch their data
//         await _fetchUserData(currentUser);
//       } else if (state.userEmail != null && state.applicationData != null) {
//         // For pending users without Firebase auth, refresh application data
//         await _refreshApplicationData(state.userEmail!);
//       } else {
//         // No current user, reset state
//         state = AuthState();
//       }
//
//       print('🔄 Auth state refreshed successfully');
//     } catch (e) {
//       print('🔄 Error refreshing auth state: $e');
//     }
//   }
//
//   // 🆕 NEW: Refresh application data for pending users
//   Future<void> _refreshApplicationData(String email) async {
//     try {
//       print('🔄 Refreshing application data for: $email');
//
//       final applicationQuery = await _firestore
//           .collection('user_applications')
//           .where('email', isEqualTo: email.toLowerCase())
//           .get();
//
//       if (applicationQuery.docs.isNotEmpty) {
//         final applicationData = applicationQuery.docs.first.data();
//         applicationData['documentId'] = applicationQuery.docs.first.id;
//
//         // Check if user was approved and now has Firebase account
//         final firebaseUid = applicationData['firebaseUid'] ?? '';
//         final status = applicationData['status'] ?? '';
//
//         if (firebaseUid.isNotEmpty && status.toLowerCase() == 'approved') {
//           // User was approved! Try to sign them in with Firebase Auth
//           try {
//             final credential = await _auth.signInWithEmailAndPassword(
//               email: email,
//               password: applicationData['password'],
//             );
//             print('🔄 ✅ User was approved! Signed in with Firebase Auth');
//             // _onAuthStateChanged will handle the state update
//             return;
//           } catch (e) {
//             print('🔄 Could not sign in with Firebase Auth: $e');
//           }
//         }
//
//         // Update state with refreshed application data
//         state = state.copyWith(
//           applicationData: applicationData,
//           isApproved: status.toLowerCase() == 'approved',
//         );
//
//         print('🔄 Application data refreshed');
//       }
//     } catch (e) {
//       print('🔄 Error refreshing application data: $e');
//     }
//   }
//
//   Future<void> fixAndCreateTrustedUser() async {
//     try {
//       print('🔧 =================================');
//       print('🔧 FIXING TRUSTED USER CREATION');
//       print('🔧 =================================');
//
//       final email = 'trusteduser@example.com';
//       final password = '123456';
//
//       // Step 1: Clean up existing broken user
//       print('🔧 Step 1: Cleaning up existing user...');
//
//       // Find the existing user document in Firestore
//       final usersQuery = await _firestore
//           .collection('users')
//           .where('email', isEqualTo: email)
//           .get();
//
//       if (usersQuery.docs.isNotEmpty) {
//         print('🔧 Found existing Firestore user document, deleting...');
//         for (var doc in usersQuery.docs) {
//           await doc.reference.delete();
//           print('🔧 Deleted Firestore document: ${doc.id}');
//         }
//       }
//
//       // Check if Firebase Auth user exists (it shouldn't based on debug)
//       try {
//         final methods = await _auth.fetchSignInMethodsForEmail(email);
//         //fetchSignInMethodsForEmail
//         if (methods.isNotEmpty) {
//           print('🔧 Firebase Auth user exists, need to handle...');
//           // This case shouldn't happen based on your debug, but just in case
//         } else {
//           print('🔧 No Firebase Auth user found (as expected)');
//         }
//       } catch (e) {
//         print('🔧 Error checking Firebase Auth: $e');
//       }
//
//       // Step 2: Create complete user (both Firebase Auth and Firestore)
//       print('🔧 Step 2: Creating complete user...');
//
//       // Create Firebase Auth account
//       final userCredential = await _auth.createUserWithEmailAndPassword(
//         email: email,
//         password: password,
//       );
//
//       final uid = userCredential.user!.uid;
//       print('🔧 ✅ Firebase Auth user created with UID: $uid');
//
//       // Set display name
//       await userCredential.user!.updateDisplayName('Test Trusted User');
//
//       // Create Firestore document with the correct UID
//       await _firestore.collection('users').doc(uid).set({
//         'uid': uid,
//         'email': email,
//         'fullName': 'Test Trusted User',
//         'role': 'user', // This makes them a trusted user
//         'isActive': true,
//         'phoneNumber': '+966123456789',
//         'serviceProvider': 'Test Company',
//         'location': 'Test City',
//         'createdAt': FieldValue.serverTimestamp(),
//       });
//
//       print('🔧 ✅ Firestore user document created with correct UID!');
//
//       // Step 3: Verify the fix
//       print('🔧 Step 3: Verifying the fix...');
//
//       // Check Firebase Auth
//       final authMethods = await _auth.fetchSignInMethodsForEmail(email);
//       print('🔧 Firebase Auth methods: $authMethods');
//
//       // Check Firestore
//       final userDoc = await _firestore.collection('users').doc(uid).get();
//       print('🔧 Firestore document exists: ${userDoc.exists}');
//       if (userDoc.exists) {
//         print('🔧 User data: ${userDoc.data()}');
//       }
//
//       // Step 4: Test login
//       print('🔧 Step 4: Testing login...');
//
//       try {
//         final testCredential = await _auth.signInWithEmailAndPassword(
//           email: email,
//           password: password,
//         );
//         print('🔧 ✅ Login test successful! UID: ${testCredential.user!.uid}');
//
//         // Sign out immediately
//         await _auth.signOut();
//         print('🔧 Signed out test user');
//       } catch (loginError) {
//         print('🔧 ❌ Login test failed: $loginError');
//       }
//
//       // Reset auth state
//       state = AuthState();
//
//       print('🔧 =================================');
//       print('🔧 USER FIXED AND CREATED SUCCESSFULLY!');
//       print('🔧 Email: $email');
//       print('🔧 Password: $password');
//       print('🔧 You can now login with these credentials');
//       print('🔧 =================================');
//     } catch (e) {
//       print('🔧 ❌ Error fixing user: $e');
//       rethrow;
//     }
//   }
//
//   Future<void> createFreshTrustedUser() async {
//     try {
//       print('🆕 =================================');
//       print('🆕 CREATING FRESH TRUSTED USER');
//       print('🆕 =================================');
//
//       final email = 'newtrusteduser@example.com'; // Different email
//       final password = '123456';
//
//       // Step 1: Create Firebase Auth account
//       print('🆕 Step 1: Creating Firebase Auth user...');
//       final userCredential = await _auth.createUserWithEmailAndPassword(
//         email: email,
//         password: password,
//       );
//
//       final uid = userCredential.user!.uid;
//       print('🆕 ✅ Firebase Auth user created with UID: $uid');
//
//       // Step 2: Create Firestore document
//       print('🆕 Step 2: Creating Firestore user document...');
//       await _firestore.collection('users').doc(uid).set({
//         'uid': uid,
//         'email': email,
//         'fullName': 'New Trusted User',
//         'role': 'user',
//         'isActive': true,
//         'phoneNumber': '+966987654321',
//         'serviceProvider': 'New Test Company',
//         'location': 'New Test City',
//         'createdAt': FieldValue.serverTimestamp(),
//       });
//
//       print('🆕 ✅ Firestore user document created!');
//
//       // Step 3: Test login immediately
//       print('🆕 Step 3: Testing login...');
//       try {
//         await _auth.signOut(); // Make sure we're signed out first
//
//         final testCredential = await _auth.signInWithEmailAndPassword(
//           email: email,
//           password: password,
//         );
//         print('🆕 ✅ Login test successful! UID: ${testCredential.user!.uid}');
//
//         // Sign out
//         await _auth.signOut();
//       } catch (loginError) {
//         print('🆕 ❌ Login test failed: $loginError');
//       }
//
//       // Reset auth state
//       state = AuthState();
//
//       print('🆕 =================================');
//       print('🆕 FRESH USER CREATED SUCCESSFULLY!');
//       print('🆕 Email: $email');
//       print('🆕 Password: $password');
//       print('🆕 =================================');
//     } catch (e) {
//       print('🆕 ❌ Error creating fresh user: $e');
//       rethrow;
//     }
//   }
//
// // Method to create a complete test trusted user
//   Future<void> createCompleteTrustedUser() async {
//     try {
//       print('🧪 =================================');
//       print('🧪 CREATING COMPLETE TRUSTED USER');
//       print('🧪 =================================');
//
//       final email = 'trusteduser@example.com';
//       final password = '123456';
//
//       // Step 1: Check if user already exists
//       try {
//         final methods = await _auth.fetchSignInMethodsForEmail(email);
//         if (methods.isNotEmpty) {
//           print('🧪 User already exists in Firebase Auth, deleting first...');
//           // Sign in to get the user
//           final credential = await _auth.signInWithEmailAndPassword(
//             email: email,
//             password: password,
//           );
//           // Delete the user
//           await credential.user!.delete();
//           await _auth.signOut();
//           print('🧪 Existing user deleted');
//         }
//       } catch (e) {
//         print('🧪 No existing user found or error checking: $e');
//       }
//
//       // Step 2: Create Firebase Auth user
//       print('🧪 Step 1: Creating Firebase Auth user...');
//       final userCredential = await _auth.createUserWithEmailAndPassword(
//         email: email,
//         password: password,
//       );
//
//       final uid = userCredential.user!.uid;
//       print('🧪 ✅ Firebase Auth user created with UID: $uid');
//
//       // Step 3: Create Firestore users document
//       print('🧪 Step 2: Creating Firestore user document...');
//       await _firestore.collection('users').doc(uid).set({
//         'uid': uid,
//         'email': email,
//         'fullName': 'Test Trusted User',
//         'role': 'user', // This makes them a trusted user
//         'isActive': true,
//         'phoneNumber': '+966123456789',
//         'serviceProvider': 'Test Company',
//         'location': 'Test City',
//         'createdAt': FieldValue.serverTimestamp(),
//       });
//
//       print('🧪 ✅ Firestore user document created!');
//
//       // Step 4: Verify creation
//       print('🧪 Step 3: Verifying user creation...');
//
//       // Check Firebase Auth
//       final authMethods = await _auth.fetchSignInMethodsForEmail(email);
//       print('🧪 Firebase Auth methods: $authMethods');
//
//       // Check Firestore
//       final userDoc = await _firestore.collection('users').doc(uid).get();
//       print('🧪 Firestore document exists: ${userDoc.exists}');
//       if (userDoc.exists) {
//         print('🧪 User data: ${userDoc.data()}');
//       }
//
//       // Step 5: Sign out the test user
//       await _auth.signOut();
//       state = AuthState();
//
//       print('🧪 =================================');
//       print('🧪 TRUSTED USER CREATED SUCCESSFULLY!');
//       print('🧪 Email: $email');
//       print('🧪 Password: $password');
//       print('🧪 UID: $uid');
//       print('🧪 =================================');
//     } catch (e) {
//       print('🧪 ❌ Error creating trusted user: $e');
//       rethrow;
//     }
//   }
//
// // Method to test login with specific credentials
//   Future<void> testLoginWithCredentials(String email, String password) async {
//     try {
//       print('🧪 =================================');
//       print('🧪 TESTING LOGIN WITH CREDENTIALS');
//       print('🧪 Email: $email');
//       print('🧪 =================================');
//
//       // Step 1: Check if email exists in Firebase Auth
//       print('🧪 Step 1: Checking if email exists in Firebase Auth...');
//       final methods = await _auth.fetchSignInMethodsForEmail(email);
//       print('🧪 Sign-in methods for $email: $methods');
//
//       if (methods.isEmpty) {
//         print('🧪 ❌ Email does not exist in Firebase Auth!');
//         throw Exception('البريد الإلكتروني غير موجود في النظام');
//       }
//
//       // Step 2: Try Firebase Auth sign in
//       print('🧪 Step 2: Attempting Firebase Auth sign in...');
//       final credential = await _auth.signInWithEmailAndPassword(
//         email: email,
//         password: password,
//       );
//
//       print('🧪 ✅ Firebase Auth successful!');
//       print('🧪 User UID: ${credential.user!.uid}');
//       print('🧪 User email: ${credential.user!.email}');
//       print('🧪 Email verified: ${credential.user!.emailVerified}');
//
//       // Step 3: Check Firestore document
//       print('🧪 Step 3: Checking Firestore user document...');
//       final userDoc =
//           await _firestore.collection('users').doc(credential.user!.uid).get();
//
//       print('🧪 User document exists: ${userDoc.exists}');
//
//       if (userDoc.exists) {
//         final userData = userDoc.data()!;
//         print('🧪 User data: $userData');
//         print('🧪 Role: ${userData['role']}');
//         print('🧪 Is Active: ${userData['isActive']}');
//       } else {
//         print('🧪 ❌ User document does not exist in Firestore!');
//       }
//
//       // Step 4: Sign out
//       // await _auth.signOut();
//       // state = AuthState();
//
//       print('🧪 =================================');
//       print('🧪 LOGIN TEST COMPLETED');
//       print('🧪 =================================');
//     } catch (e) {
//       print('🧪 ❌ Login test error: $e');
//
//       // Try to sign out in case of partial success
//       try {
//         // await _auth.signOut();
//         // state = AuthState();
//       } catch (signOutError) {
//         print('🧪 Error during sign out: $signOutError');
//       }
//
//       rethrow;
//     }
//   }
//
// // Method to list all users in both collections
//   Future<void> debugListAllUsers() async {
//     try {
//       print('🔍 =================================');
//       print('🔍 LISTING ALL USERS');
//       print('🔍 =================================');
//
//       // Check admins collection
//       print('🔍 ADMINS COLLECTION:');
//       final adminsSnapshot = await _firestore.collection('admins').get();
//       print('🔍 Found ${adminsSnapshot.docs.length} admins');
//
//       for (var doc in adminsSnapshot.docs) {
//         final data = doc.data();
//         print('🔍 Admin UID: ${doc.id}');
//         print('  - Role: ${data['role']}');
//         print('  - IsAdmin: ${data['isAdmin']}');
//         print('  - Email: ${data['email'] ?? 'N/A'}');
//         print('  ---');
//       }
//
//       // Check users collection
//       print('\n🔍 USERS COLLECTION:');
//       final usersSnapshot = await _firestore.collection('users').get();
//       print('🔍 Found ${usersSnapshot.docs.length} users');
//
//       for (var doc in usersSnapshot.docs) {
//         final data = doc.data();
//         print('🔍 User UID: ${doc.id}');
//         print('  - Email: ${data['email']}');
//         print('  - Role: ${data['role']}');
//         print('  - Active: ${data['isActive']}');
//         print('  - Name: ${data['fullName']}');
//         print('  ---');
//       }
//
//       // Check user applications
//       print('\n🔍 USER APPLICATIONS COLLECTION:');
//       final appsSnapshot =
//           await _firestore.collection('user_applications').get();
//       print('🔍 Found ${appsSnapshot.docs.length} applications');
//
//       for (var doc in appsSnapshot.docs) {
//         final data = doc.data();
//         print('🔍 Application ID: ${doc.id}');
//         print('  - Email: ${data['email']}');
//         print('  - Status: ${data['status']}');
//         print('  - Name: ${data['fullName']}');
//         print('  - Firebase UID: ${data['firebaseUid'] ?? 'N/A'}');
//         print('  ---');
//       }
//
//       print('🔍 =================================');
//     } catch (e) {
//       print('🔍 Error listing users: $e');
//     }
//   }
//
// // Method to check specific email across all systems
//   Future<Map<String, bool>> checkEmailEverywhere(String email) async {
//     final results = <String, bool>{};
//
//     try {
//       // Check Firebase Auth
//       final methods = await _auth.fetchSignInMethodsForEmail(email);
//       results['firebase_auth'] = methods.isNotEmpty;
//       print('🔍 Firebase Auth: ${results['firebase_auth']}');
//
//       // Check admins collection
//       final adminsQuery = await _firestore
//           .collection('admins')
//           .where('email', isEqualTo: email)
//           .get();
//       results['admins_collection'] = adminsQuery.docs.isNotEmpty;
//       print('🔍 Admins collection: ${results['admins_collection']}');
//
//       // Check users collection
//       final usersQuery = await _firestore
//           .collection('users')
//           .where('email', isEqualTo: email)
//           .get();
//       results['users_collection'] = usersQuery.docs.isNotEmpty;
//       print('🔍 Users collection: ${results['users_collection']}');
//
//       // Check user applications
//       final appsQuery = await _firestore
//           .collection('user_applications')
//           .where('email', isEqualTo: email)
//           .get();
//       results['user_applications'] = appsQuery.docs.isNotEmpty;
//       print('🔍 User applications: ${results['user_applications']}');
//     } catch (e) {
//       print('🔍 Error checking email: $e');
//     }
//
//     return results;
//   }
//
// // Updated _fetchUserData method
// //   Future<void> _fetchUserData(User user) async {
// //     try {
// //       state = state.copyWith(isLoading: true);
// //       print('🔍 Fetching user data for UID: ${user.uid}');
// //
// //       // First, check if user is an admin
// //       final adminDoc =
// //           await _firestore.collection('admins').doc(user.uid).get();
// //
// //       if (adminDoc.exists) {
// //         print('🔍 User found in admins collection');
// //         final adminData = adminDoc.data()!;
// //         final roleValue = adminData['role'] as int? ?? 2;
// //
// //         state = state.copyWith(
// //           user: user,
// //           role: UserRole.fromInt(roleValue),
// //           isAuthenticated: true,
// //           isLoading: false,
// //           userData: adminData,
// //           isTrustedUser: false,
// //           isApproved: true, // Admins are always approved
// //         );
// //         return;
// //       }
// //
// //       // If not an admin, check if user is a trusted user
// //       final userDoc =
// //           await _firestore.collection('user_applications').doc(user.uid).get();
// //
// //       if (userDoc.exists) {
// //         print('🔍 User found in users collection');
// //         final userData = userDoc.data()!;
// //         final userRole = userData['role'] ?? '';
// //
// //         // Check if it's a trusted user
// //         final isTrustedUser = userRole == 'trusted';
// //
// //         // Get application data if available
// //         Map<String, dynamic>? applicationData;
// //         if (isTrustedUser && userData['applicationId'] != null) {
// //           try {
// //             final appDoc = await _firestore
// //                 .collection('user_applications')
// //                 .doc(userData['applicationId'])
// //                 .get();
// //             if (appDoc.exists) {
// //               applicationData = appDoc.data();
// //             }
// //           } catch (e) {
// //             print('🔍 Could not fetch application data: $e');
// //           }
// //         }
// //
// //         state = state.copyWith(
// //           user: user,
// //           role: isTrustedUser ? UserRole.trusted : UserRole.common,
// //           isAuthenticated: true,
// //           isLoading: false,
// //           userData: userData,
// //           applicationData: applicationData,
// //           isTrustedUser: isTrustedUser,
// //           isApproved:
// //               isTrustedUser, // If they have a Firebase account, they're approved
// //         );
// //         return;
// //       }
// //
// //       // User exists in Firebase Auth but not in either collection
// //       print('🔍 User not found in any collection');
// //       state = state.copyWith(
// //         user: user,
// //         role: UserRole.common,
// //         isAuthenticated: true,
// //         isLoading: false,
// //         userData: null,
// //         isTrustedUser: false,
// //         isApproved: false,
// //       );
// //     } catch (e) {
// //       debugPrint('Error fetching user data: $e');
// //       state = state.copyWith(
// //         user: user,
// //         role: UserRole.common,
// //         isAuthenticated: true,
// //         isLoading: false,
// //         error: 'Failed to fetch user data',
// //         isTrustedUser: false,
// //         isApproved: false,
// //       );
// //     }
// //   }
//
//   // Admin sign in method
//   Future<void> signIn(String email, String password) async {
//     try {
//       state = state.copyWith(isLoading: true, error: null);
//       print('🔐 Admin sign in attempt for: $email');
//
//       final credential = await _auth.signInWithEmailAndPassword(
//         email: email,
//         password: password,
//       );
//
//       print('🔐 Firebase Auth successful, checking admin status...');
//
//       // Check if user is admin
//       final adminDoc =
//           await _firestore.collection('admins').doc(credential.user!.uid).get();
//
//       if (!adminDoc.exists) {
//         print('🔐 User is not an admin, signing out...');
//         await _auth.signOut();
//         throw Exception('لا تملك صلاحيات المشرف المطلوبة');
//       }
//
//       // Auth state listener will update the state
//       print('🔐 Admin login successful');
//     } catch (e) {
//       print('🔐 Admin login error: $e');
//       state = state.copyWith(
//         isLoading: false,
//         error: e.toString(),
//       );
//       rethrow;
//     }
//   }
//
// // FIXED: Updated signInTrustedUser method
// //   Future<void> signInTrustedUser(String email, String password) async {
// //     try {
// //       print('🔐 =================================');
// //       print('🔐 STARTING TRUSTED USER SIGN IN');
// //       print('🔐 =================================');
// //
// //       state = state.copyWith(isLoading: true, error: null);
// //       print('🔐 Email: $email');
// //
// //       // First, check if there's an application for this email
// //       print('🔍 Searching for application...');
// //       final applicationQuery = await _firestore
// //           .collection('user_applications')
// //           .where('email', isEqualTo: email.toLowerCase())
// //           .get();
// //
// //       if (applicationQuery.docs.isEmpty) {
// //         print('🔐 No application found for email: $email');
// //         throw Exception('لم يتم العثور على طلب تسجيل بهذا البريد الإلكتروني');
// //       }
// //
// //       final applicationDoc = applicationQuery.docs.first;
// //       final applicationData = applicationDoc.data();
// //       final applicationStatus = applicationData['status'] ?? '';
// //
// //       print('🔍 Application found:');
// //       print('  - Status: "$applicationStatus"');
// //       print('  - Email: ${applicationData['email']}');
// //       print('  - Firebase UID: ${applicationData['firebaseUid']}');
// //
// //       // Verify password matches the one in application
// //       if (applicationData['password'] != password) {
// //         print('🔐 PASSWORD MISMATCH!');
// //         throw Exception('كلمة المرور غير صحيحة');
// //       }
// //
// //       print('🔐 Password verification PASSED');
// //
// //       // FIXED: Check if user has Firebase account (approved users should have one)
// //       final firebaseUid = applicationData['firebaseUid'] ?? '';
// //
// //       if (firebaseUid.isNotEmpty &&
// //           applicationStatus.toLowerCase() == 'approved') {
// //         print(
// //             '🔐 User is approved and has Firebase UID, attempting Firebase Auth...');
// //
// //         try {
// //           final credential = await _auth.signInWithEmailAndPassword(
// //             email: email,
// //             password: password,
// //           );
// //
// //           print('🔐 ✅ Firebase Auth successful for approved user');
// //           print('🔐 User UID: ${credential.user?.uid}');
// //
// //           // The _fetchUserData method (via auth state listener) will handle the rest
// //           return;
// //         } catch (firebaseError) {
// //           print('🔐 ❌ Firebase Auth failed: $firebaseError');
// //
// //           if (firebaseError is FirebaseAuthException) {
// //             switch (firebaseError.code) {
// //               case 'user-not-found':
// //                 print(
// //                     '🔐 User not found in Firebase Auth, but should exist. Creating account...');
// //                 await _createFirebaseAccountForApprovedUser(
// //                     applicationDoc.id, applicationData);
// //
// //                 // Try login again
// //                 final credential = await _auth.signInWithEmailAndPassword(
// //                   email: email,
// //                   password: password,
// //                 );
// //                 print('🔐 ✅ Second login attempt successful');
// //                 return;
// //
// //               case 'wrong-password':
// //                 throw Exception('كلمة المرور غير صحيحة');
// //               case 'invalid-email':
// //                 throw Exception('البريد الإلكتروني غير صحيح');
// //               default:
// //                 throw Exception(
// //                     'خطأ في تسجيل الدخول: ${firebaseError.message}');
// //             }
// //           }
// //           throw firebaseError;
// //         }
// //       }
// //
// //       // Handle non-approved users (pending, rejected, etc.)
// //       print('🔐 User is not approved or has no Firebase account');
// //       print('🔐 Status: $applicationStatus');
// //       print('🔐 Allowing dashboard access with limited permissions...');
// //
// //       // Create user data from application
// //       final userData = {
// //         'fullName': applicationData['fullName'],
// //         'email': applicationData['email'],
// //         'phoneNumber': applicationData['phoneNumber'],
// //         'additionalPhone': applicationData['additionalPhone'] ?? '',
// //         'serviceProvider': applicationData['serviceProvider'],
// //         'location': applicationData['location'],
// //         'role': 'trusted',
// //         'status': applicationStatus,
// //         'adminComment': applicationData['adminComment'] ?? '',
// //       };
// //
// //       // Update state for non-approved users
// //       state = state.copyWith(
// //         isLoading: false,
// //         isAuthenticated: true, // Allow authentication
// //         role: UserRole.trusted,
// //         isTrustedUser: true,
// //         isApproved: applicationStatus.toLowerCase() == 'approved',
// //         userData: userData,
// //         applicationData: applicationData,
// //         userEmail: email,
// //         error: null,
// //       );
// //
// //       print('🔐 ✅ Non-approved user authenticated with limited access');
// //       print('🔐 Status: $applicationStatus');
// //     } catch (e, stackTrace) {
// //       print('🔐 ❌ ERROR in signInTrustedUser: $e');
// //       state = state.copyWith(
// //         isLoading: false,
// //         error: e.toString(),
// //       );
// //       rethrow;
// //     }
// //   }
//
// // Helper method to get role from status
//   UserRole _getRoleFromStatus(String status) {
//     switch (status.toLowerCase()) {
//       case 'approved':
//         return UserRole.trusted;
//       case 'pending':
//       case 'in_progress':
//         return UserRole.trusted; // Still trusted, just not approved
//       case 'rejected':
//         return UserRole.common;
//       default:
//         return UserRole.common;
//     }
//   }
//
// // Helper method to create Firebase account for approved users
//   Future<void> _createFirebaseAccountForApprovedUser(
//       String applicationId, Map<String, dynamic> applicationData) async {
//     try {
//       print('🔧 Creating Firebase account for approved user...');
//
//       final email = applicationData['email'];
//       final password = applicationData['password'];
//       final fullName = applicationData['fullName'];
//
//       print('🔧 Creating auth account for: $email');
//
//       // Create Firebase Auth account
//       final userCredential = await _auth.createUserWithEmailAndPassword(
//         email: email,
//         password: password,
//       );
//
//       print(
//           '🔧 Firebase Auth account created, UID: ${userCredential.user?.uid}');
//
//       // Update display name
//       await userCredential.user?.updateDisplayName(fullName);
//
//       // Create user document in Firestore
//       await _firestore.collection('users').doc(userCredential.user!.uid).set({
//         'uid': userCredential.user!.uid,
//         'email': email,
//         'fullName': fullName,
//         'phoneNumber': applicationData['phoneNumber'],
//         'additionalPhone': applicationData['additionalPhone'] ?? '',
//         'serviceProvider': applicationData['serviceProvider'],
//         'location': applicationData['location'],
//         'role': 'user', // Trusted user role
//         'applicationId': applicationId,
//         'createdAt': FieldValue.serverTimestamp(),
//         'isActive': true,
//       });
//
//       print('🔧 User document created in Firestore');
//
//       // Update application with user ID
//       await _firestore
//           .collection('user_applications')
//           .doc(applicationId)
//           .update({
//         'firebaseUid': userCredential.user!.uid,
//         'accountCreated': true,
//         'accountCreatedAt': FieldValue.serverTimestamp(),
//       });
//
//       print('🔧 Application updated with Firebase UID');
//       print('🔧 Firebase account creation completed successfully');
//     } catch (e) {
//       print('🔧 Error creating Firebase account: $e');
//       rethrow;
//     }
//   }
//
// // UPDATED: Registration method - Remove context parameter
//   Future<void> registerUser({
//     required String fullName,
//     required String email,
//     required String password,
//     required String phoneNumber,
//     String? additionalPhone,
//     required String serviceProvider,
//     required String location,
//   }) async {
//     try {
//       print('📝 ========================================');
//       print('📝 STARTING USER REGISTRATION');
//       print('📝 ========================================');
//
//       state = state.copyWith(isLoading: true, error: null);
//
//       print('📝 Email: $email');
//       print('📝 Full Name: $fullName');
//
//       // Check if email is already registered
//       final existingApplication = await _firestore
//           .collection('user_applications')
//           .where('email', isEqualTo: email.toLowerCase())
//           .get();
//
//       if (existingApplication.docs.isNotEmpty) {
//         print('📝 ❌ Email already exists');
//         throw Exception('البريد الإلكتروني مسجل مسبقاً');
//       }
//
//       // Create application document with ALL required fields
//       final applicationData = {
//         'fullName': fullName,
//         'email': email.toLowerCase(),
//         'password': password, // In production, hash this password
//         'phoneNumber': phoneNumber,
//         'additionalPhone': additionalPhone ?? '',
//         'serviceProvider': serviceProvider,
//         'location': location,
//         'status': 'pending', // Initial status for new registrations
//         'adminComment': '', // Empty initially, admin can add comments later
//         'isApproved': false, // Not approved initially
//         'isActive': true, // Account is active for login
//         'role': 'trusted', // Default role for trusted users
//         'applicationId': '', // Will be updated with document ID
//         'firebaseUid':
//             '', // Empty until admin approves and Firebase account is created
//         'accountCreated': false, // Firebase account not created yet
//         'createdAt': FieldValue.serverTimestamp(),
//         'updatedAt': FieldValue.serverTimestamp(),
//         'submittedAt':
//             FieldValue.serverTimestamp(), // When user submitted the application
//         'reviewedAt': null, // When admin reviewed (null initially)
//         'reviewedBy': '', // Admin who reviewed (empty initially)
//         'lastLoginAt': null, // Track last login time
//         'profileCompleted':
//             true, // All required fields filled during registration
//         'emailVerified': false, // Email verification status
//         'phoneVerified': false, // Phone verification status
//         'documentsSubmitted': false, // If any documents were required/submitted
//         'applicationNotes': '', // Internal notes for the application
//         'rejectionReason': '', // Reason if application gets rejected
//         'approvalDate': null, // Date when approved
//         'version': '1.0', // Version of the application structure
//       };
//
//       print('📝 Creating application document...');
//       final docRef =
//           await _firestore.collection('user_applications').add(applicationData);
//
//       // Update with document ID in the applicationId field
//       await docRef.update({
//         'uid': docRef.id, // Keep existing uid field for compatibility
//         'applicationId': docRef.id, // Add proper applicationId field
//       });
//
//       print('📝 ✅ Application created successfully');
//       print('📝 Document ID: ${docRef.id}');
//
//       state = state.copyWith(isLoading: false);
//
//       print('📝 ========================================');
//       print('📝 USER REGISTRATION COMPLETED');
//       print('📝 ========================================');
//     } catch (e) {
//       print('📝 ❌ REGISTRATION ERROR: $e');
//       state = state.copyWith(
//         error: e.toString(),
//         isLoading: false,
//       );
//       rethrow;
//     }
//   }
//
//   Future<List<Map<String, dynamic>>> getAllUserApplications() async {
//     try {
//       print('🔧 Admin: Loading all user applications');
//
//       final querySnapshot = await _firestore
//           .collection('user_applications')
//           .orderBy('createdAt', descending: true)
//           .get();
//
//       final applications = querySnapshot.docs.map((doc) {
//         final data = doc.data();
//         data['documentId'] = doc.id; // Add the Firestore document ID
//         return data;
//       }).toList();
//
//       print('🔧 Admin: Loaded ${applications.length} applications');
//       return applications;
//     } catch (e) {
//       print('🔧 Admin: Error loading applications: $e');
//       throw e;
//     }
//   }
//
// // Enhanced version of your updateUserApplicationStatus method
// //   Future<void> updateUserApplicationStatus(String applicationId, String status,
// //       {String? comment}) async {
// //     try {
// //       print('🔧 Admin: Starting status update');
// //       print('  - Application ID: $applicationId');
// //       print('  - New Status: $status');
// //       print('  - Comment: $comment');
// //
// //       // Check if document exists first
// //       final docRef =
// //           _firestore.collection('user_applications').doc(applicationId);
// //       final docSnapshot = await docRef.get();
// //
// //       if (!docSnapshot.exists) {
// //         throw Exception(
// //             'Application document not found with ID: $applicationId');
// //       }
// //
// //       print('🔧 Admin: Document exists, proceeding with update');
// //
// //       // Prepare update data
// //       final updateData = {
// //         'status': status,
// //         'updatedAt': FieldValue.serverTimestamp(),
// //       };
// //
// //       if (comment != null && comment.isNotEmpty) {
// //         updateData['adminComment'] = comment;
// //       }
// //
// //       // Add reviewer info if available
// //       final currentUser = _auth.currentUser;
// //       if (currentUser != null) {
// //         updateData['reviewedBy'] = currentUser.uid;
// //         updateData['reviewedAt'] = FieldValue.serverTimestamp();
// //       }
// //
// //       print('🔧 Admin: Update data: $updateData');
// //
// //       // Perform the update
// //       await docRef.update(updateData);
// //
// //       print('🔧 Admin: Application status updated successfully');
// //
// //       // If approved, create Firebase Auth account and user document
// //       if (status.toLowerCase() == 'approved') {
// //         print('🔧 Admin: Status is approved, creating Firebase account...');
// //         await _createApprovedUserAccount(applicationId);
// //       }
// //
// //       print('🔧 Admin: Status update completed successfully');
// //     } catch (e, stackTrace) {
// //       print('🔧 Admin: Error in updateUserApplicationStatus: $e');
// //       print('🔧 Admin: Stack trace: $stackTrace');
// //       rethrow;
// //     }
// //   }
//
// // Improved method to create Firebase Auth account for approved users
//   Future<void> _createApprovedUserAccount(String applicationId) async {
//     try {
//       print('🔧 Creating Firebase account for application: $applicationId');
//
//       // Get the application data
//       final applicationDoc = await _firestore
//           .collection('user_applications')
//           .doc(applicationId)
//           .get();
//
//       if (!applicationDoc.exists) {
//         print('🔧 Application document not found: $applicationId');
//         throw Exception('طلب التسجيل غير موجود');
//       }
//
//       final applicationData = applicationDoc.data()!;
//       final email = applicationData['email'];
//       final password = applicationData['password'];
//       final fullName = applicationData['fullName'];
//
//       print('🔧 Application data retrieved:');
//       print('  - Email: $email');
//       print('  - Full Name: $fullName');
//
//       // Check if Firebase account already exists
//       bool accountExists = false;
//       try {
//         final existingUserMethods =
//             await _auth.fetchSignInMethodsForEmail(email);
//         accountExists = existingUserMethods.isNotEmpty;
//         print('🔧 Firebase account exists: $accountExists');
//       } catch (e) {
//         print('🔧 Error checking existing account: $e');
//       }
//
//       UserCredential? userCredential;
//
//       if (accountExists) {
//         print('🔧 Firebase account already exists, skipping creation');
//         // Try to get the existing user
//         try {
//           final existingUsers = await _auth.signInWithEmailAndPassword(
//             email: email,
//             password: password,
//           );
//           userCredential = existingUsers;
//           print('🔧 Successfully signed in existing user');
//         } catch (e) {
//           print('🔧 Could not sign in existing user: $e');
//           throw Exception(
//               'حساب Firebase موجود بالفعل ولكن كلمة المرور غير صحيحة');
//         }
//       } else {
//         // Create new Firebase Auth account
//         print('🔧 Creating new Firebase Auth account...');
//         try {
//           userCredential = await _auth.createUserWithEmailAndPassword(
//             email: email,
//             password: password,
//           );
//           print('🔧 Firebase Auth account created successfully');
//           print('🔧 User UID: ${userCredential.user?.uid}');
//         } catch (e) {
//           print('🔧 Error creating Firebase Auth account: $e');
//           if (e is FirebaseAuthException) {
//             switch (e.code) {
//               case 'email-already-in-use':
//                 throw Exception('البريد الإلكتروني مستخدم بالفعل');
//               case 'weak-password':
//                 throw Exception('كلمة المرور ضعيفة');
//               case 'invalid-email':
//                 throw Exception('البريد الإلكتروني غير صحيح');
//               default:
//                 throw Exception('خطأ في إنشاء الحساب: ${e.message}');
//             }
//           }
//           rethrow;
//         }
//       }
//
//       if (userCredential.user == null) {
//         throw Exception('فشل في إنشاء أو الوصول للحساب');
//       }
//
//       final user = userCredential.user!;
//
//       // Update display name
//       try {
//         await user.updateDisplayName(fullName);
//         print('🔧 Display name updated');
//       } catch (e) {
//         print('🔧 Error updating display name: $e');
//         // Non-critical error, continue
//       }
//
//       // Check if user document already exists
//       final existingUserDoc =
//           await _firestore.collection('users').doc(user.uid).get();
//
//       if (existingUserDoc.exists) {
//         print('🔧 User document already exists, updating...');
//         // Update existing document
//         await _firestore.collection('users').doc(user.uid).update({
//           'applicationId': applicationId,
//           'updatedAt': FieldValue.serverTimestamp(),
//           'isActive': true,
//         });
//       } else {
//         print('🔧 Creating new user document...');
//         // Create new user document
//         await _firestore.collection('users').doc(user.uid).set({
//           'uid': user.uid,
//           'email': email,
//           'fullName': fullName,
//           'phoneNumber': applicationData['phoneNumber'],
//           'additionalPhone': applicationData['additionalPhone'] ?? '',
//           'serviceProvider': applicationData['serviceProvider'],
//           'location': applicationData['location'],
//           'role': 'user', // Trusted user role
//           'applicationId': applicationId,
//           'createdAt': FieldValue.serverTimestamp(),
//           'isActive': true,
//         });
//       }
//
//       print('🔧 User document created/updated successfully');
//
//       // Update application with user ID
//       await _firestore
//           .collection('user_applications')
//           .doc(applicationId)
//           .update({
//         'firebaseUid': user.uid,
//         'accountCreated': true,
//         'accountCreatedAt': FieldValue.serverTimestamp(),
//       });
//
//       print('🔧 Application updated with Firebase UID');
//
//       // Sign out the newly created/signed in user (since we're in admin context)
//       try {
//         await _auth.signOut();
//         print('🔧 Signed out the user (admin context)');
//       } catch (e) {
//         print('🔧 Error signing out: $e');
//         // Non-critical error
//       }
//
//       print('🔧 ✅ Account creation/update completed successfully');
//     } catch (e, stackTrace) {
//       print('🔧 ❌ Error creating user account: $e');
//       print('🔧 Stack trace: $stackTrace');
//
//       // Don't rethrow - let the status update succeed even if account creation fails
//       // The admin can try to create the account again later
//       print('🔧 Account creation failed, but status was updated successfully');
//     }
//   }
//
//   // Debug methods
//   Future<void> debugCheckAllCollections() async {
//     try {
//       print('🔍 =================================');
//       print('🔍 CHECKING ALL COLLECTIONS');
//       print('🔍 =================================');
//
//       // Check admins collection
//       print('🔍 Checking admins collection...');
//       final adminsSnapshot = await _firestore.collection('admins').get();
//       print('🔍 Found ${adminsSnapshot.docs.length} admins');
//
//       for (var doc in adminsSnapshot.docs) {
//         final data = doc.data();
//         print('🔍 Admin ${doc.id}:');
//         print('  - Role: ${data['role']}');
//         print('  - IsAdmin: ${data['isAdmin']}');
//       }
//
//       // Check users collection
//       print('\n🔍 Checking users collection...');
//       final usersSnapshot = await _firestore.collection('users').get();
//       print('🔍 Found ${usersSnapshot.docs.length} users');
//
//       for (var doc in usersSnapshot.docs) {
//         final data = doc.data();
//         print('🔍 User ${doc.id}:');
//         print('  - Email: ${data['email']}');
//         print('  - Role: ${data['role']}');
//         print('  - Active: ${data['isActive']}');
//       }
//
//       // Check user_applications collection
//       print('\n🔍 Checking user_applications collection...');
//       final applicationsSnapshot =
//           await _firestore.collection('user_applications').get();
//       print('🔍 Found ${applicationsSnapshot.docs.length} applications');
//
//       for (var doc in applicationsSnapshot.docs) {
//         final data = doc.data();
//         print('🔍 Application ${doc.id}:');
//         print('  - Email: ${data['email']}');
//         print('  - Status: ${data['status']}');
//       }
//
//       print('🔍 =================================');
//     } catch (e) {
//       print('🔍 Error checking collections: $e');
//     }
//   }
//
//   Future<void> createTestUserDirectly() async {
//     try {
//       print('🧪 Creating test trusted user...');
//
//       // Create Firebase Auth user
//       final userCredential = await _auth.createUserWithEmailAndPassword(
//         email: 'test@example.com',
//         password: '123456',
//       );
//
//       final uid = userCredential.user!.uid;
//
//       // Create Firestore users document
//       await _firestore.collection('users').doc(uid).set({
//         'uid': uid,
//         'email': 'test@example.com',
//         'fullName': 'Test Trusted User',
//         'role': 'user',
//         'isActive': true,
//         'phoneNumber': '+966123456789',
//         'serviceProvider': 'Test Company',
//         'location': 'Test City',
//         'createdAt': FieldValue.serverTimestamp(),
//       });
//
//       // Sign out the test user
//       await _auth.signOut();
//       state = AuthState();
//
//       print('🧪 Test trusted user created successfully!');
//     } catch (e) {
//       print('🧪 Error creating test user: $e');
//       rethrow;
//     }
//   }
//
//   Future<bool> checkEmailExists(String email) async {
//     try {
//       final methods = await _auth.fetchSignInMethodsForEmail(email);
//       return methods.isNotEmpty;
//     } catch (e) {
//       return false;
//     }
//   }
//
//   Future<void> signOut() async {
//     try {
//       await _auth.signOut();
//       // Auth state listener will update the state
//     } catch (e) {
//       state = state.copyWith(
//         error: 'Failed to sign out',
//       );
//     }
//   }
//
// // Method to get current user data (works for both approved and pending users)
//   Map<String, dynamic>? getCurrentUserData() {
//     final currentState = state;
//
//     if (currentState.isApproved && currentState.userData != null) {
//       // Approved user - return Firebase user data
//       return currentState.userData;
//     } else if (!currentState.isApproved &&
//         currentState.applicationData != null) {
//       // Pending user - return application data formatted like user data
//       final appData = currentState.applicationData!;
//       return {
//         'fullName': appData['fullName'],
//         'email': appData['email'],
//         'phoneNumber': appData['phoneNumber'],
//         'additionalPhone': appData['additionalPhone'] ?? '',
//         'serviceProvider': appData['serviceProvider'],
//         'location': appData['location'],
//         'role': 'pending',
//         'status': appData['status'],
//       };
//     }
//
//     return null;
//   }
//
// // Method to check if user can perform actions (only approved users)
//   bool canPerformActions() {
//     return state.isAuthenticated && state.isApproved;
//   }
//
// // Method to get application status
//   Future<Map<String, dynamic>> getApplicationStatus(String email) async {
//     try {
//       final applications = await _firestore
//           .collection('user_applications')
//           .where('email', isEqualTo: email.toLowerCase())
//           .get();
//
//       if (applications.docs.isEmpty) {
//         throw Exception('لم يتم العثور على طلب بهذا البريد الإلكتروني');
//       }
//
//       final applicationData = applications.docs.first.data();
//
//       // Convert Firestore timestamps to strings
//       if (applicationData['createdAt'] != null) {
//         applicationData['createdAt'] =
//             (applicationData['createdAt'] as Timestamp)
//                 .toDate()
//                 .toIso8601String();
//       }
//       if (applicationData['updatedAt'] != null) {
//         applicationData['updatedAt'] =
//             (applicationData['updatedAt'] as Timestamp)
//                 .toDate()
//                 .toIso8601String();
//       }
//
//       return applicationData;
//     } catch (e) {
//       rethrow;
//     }
//   }
//
//   // Get application statistics for admin dashboard
//   Future<Map<String, int>> getApplicationStatistics() async {
//     try {
//       final applications =
//           await _firestore.collection('user_applications').get();
//
//       final stats = <String, int>{
//         'total': applications.docs.length,
//         'in_progress': 0,
//         'approved': 0,
//         'rejected': 0,
//         'needs_review': 0,
//       };
//
//       for (final doc in applications.docs) {
//         final status = doc.data()['status'] ?? 'in_progress';
//         stats[status] = (stats[status] ?? 0) + 1;
//       }
//
//       return stats;
//     } catch (e) {
//       return {
//         'total': 0,
//         'in_progress': 0,
//         'approved': 0,
//         'rejected': 0,
//         'needs_review': 0,
//       };
//     }
//   }
//
//   // Enhanced version of your updateUserApplicationStatus method
//   Future<void> updateUserApplicationStatus(String applicationId, String status,
//       {String? comment}) async {
//     try {
//       print('🔧 Admin: Starting status update');
//       print('  - Application ID: $applicationId');
//       print('  - New Status: $status');
//       print('  - Comment: $comment');
//
//       // Check if document exists first
//       final docRef =
//           _firestore.collection('user_applications').doc(applicationId);
//       final docSnapshot = await docRef.get();
//
//       if (!docSnapshot.exists) {
//         throw Exception(
//             'Application document not found with ID: $applicationId');
//       }
//
//       print('🔧 Admin: Document exists, proceeding with update');
//
//       // Prepare update data
//       final updateData = {
//         'status': status,
//         'updatedAt': FieldValue.serverTimestamp(),
//       };
//
//       if (comment != null && comment.isNotEmpty) {
//         updateData['adminComment'] = comment;
//       }
//
//       // Add reviewer info if available
//       final currentUser = _auth.currentUser;
//       if (currentUser != null) {
//         updateData['reviewedBy'] = currentUser.uid;
//         updateData['reviewedAt'] = FieldValue.serverTimestamp();
//       }
//
//       print('🔧 Admin: Update data: $updateData');
//
//       // Perform the update
//       await docRef.update(updateData);
//
//       print('🔧 Admin: Application status updated successfully');
//
//       // If approved, create Firebase Auth account and add to trusted users
//       if (status.toLowerCase() == 'approved') {
//         print('🔧 Admin: Status is approved, creating accounts...');
//         await _createApprovedUserAccount(applicationId);
//         // 🆕 NEW: Add to trusted users table
//         await addToTrustedUsersTable(applicationId);
//       }
//
//       print('🔧 Admin: Status update completed successfully');
//     } catch (e, stackTrace) {
//       print('🔧 Admin: Error in updateUserApplicationStatus: $e');
//       print('🔧 Admin: Stack trace: $stackTrace');
//       rethrow;
//     }
//   }
//
// // 🆕 NEW METHOD: Add approved user to trusted users table
//   Future<void> addToTrustedUsersTable(String applicationId) async {
//     try {
//       print('🔧 Adding approved user to trusted users table...');
//
//       // Get the application data
//       final applicationDoc = await _firestore
//           .collection('user_applications')
//           .doc(applicationId)
//           .get();
//
//       if (!applicationDoc.exists) {
//         print('🔧 Application document not found: $applicationId');
//         throw Exception('طلب التسجيل غير موجود');
//       }
//
//       final applicationData = applicationDoc.data()!;
//       final firebaseUid = applicationData['firebaseUid'];
//
//       if (firebaseUid == null || firebaseUid.isEmpty) {
//         print('🔧 No Firebase UID found, cannot add to trusted users');
//         throw Exception('لم يتم العثور على معرف المستخدم');
//       }
//
//       // Check if user already exists in trusted users table
//       final existingTrustedUser =
//           await _firestore.collection('userstransed').doc(firebaseUid).get();
//
//       if (existingTrustedUser.exists) {
//         print('🔧 User already exists in trusted users table, updating...');
//
//         // Update existing trusted user
//         await _firestore.collection('userstransed').doc(firebaseUid).update({
//           'fullName': applicationData['fullName'],
//           'email': applicationData['email'],
//           'phoneNumber': applicationData['phoneNumber'],
//           'additionalPhone': applicationData['additionalPhone'] ?? '',
//           'serviceProvider': applicationData['serviceProvider'],
//           'location': applicationData['location'],
//           'role':
//               1, // Trusted user role (based on your enum: 0=admin, 1=trusted, 2=common)
//           'isActive': true,
//           'isApproved': true,
//           'applicationId': applicationId,
//           'approvedAt': FieldValue.serverTimestamp(),
//           'updatedAt': FieldValue.serverTimestamp(),
//         });
//
//         print('🔧 Existing trusted user updated successfully');
//       } else {
//         print('🔧 Creating new trusted user entry...');
//
//         // Create new trusted user document
//         await _firestore.collection('userstransed').doc(firebaseUid).set({
//           'uid': firebaseUid,
//           'fullName': applicationData['fullName'],
//           'email': applicationData['email'],
//           'phoneNumber': applicationData['phoneNumber'],
//           'additionalPhone': applicationData['additionalPhone'] ?? '',
//           'serviceProvider': applicationData['serviceProvider'],
//           'location': applicationData['location'],
//           'role': 1, // Trusted user role
//           'isActive': true,
//           'isApproved': true,
//           'applicationId': applicationId,
//           'approvedAt': FieldValue.serverTimestamp(),
//           'createdAt': FieldValue.serverTimestamp(),
//           'updatedAt': FieldValue.serverTimestamp(),
//
//           // Additional trusted user fields (customize based on your UserModel)
//           'aliasName':
//               applicationData['fullName'], // Use full name as alias initially
//           'mobileNumber': applicationData['phoneNumber'],
//           'servicesProvided': applicationData['serviceProvider'],
//           'telegramAccount': '', // Empty initially, user can update later
//           'reviews': [], // Empty reviews array
//           'statusText': 'موثوق', // Default status text
//           'profileImageUrl': '', // Empty initially
//           'description': '', // Empty initially, user can add later
//           'workingHours': '', // Empty initially
//           'socialLinks': {}, // Empty social links
//           'verificationStatus':
//               'verified', // Automatically verified when approved
//           'rating': 0.0, // Initial rating
//           'totalReviews': 0, // Initial review count
//           'lastActive': FieldValue.serverTimestamp(),
//           'joinedDate': FieldValue.serverTimestamp(),
//           'canUpdateProfile': true, // Allow profile updates
//           'profileCompleted':
//               false, // User needs to complete additional details
//         });
//
//         print('🔧 New trusted user created successfully');
//       }
//
//       // Update the application to mark that user was added to trusted table
//       await _firestore
//           .collection('user_applications')
//           .doc(applicationId)
//           .update({
//         'addedToTrustedTable': true,
//         'addedToTrustedAt': FieldValue.serverTimestamp(),
//       });
//
//       print('🔧 ✅ User successfully added to trusted users table');
//     } catch (e, stackTrace) {
//       print('🔧 ❌ Error adding user to trusted users table: $e');
//       print('🔧 Stack trace: $stackTrace');
//
//       // Don't rethrow - let the approval succeed even if adding to trusted table fails
//       // The admin can manually add them later
//       print('🔧 Adding to trusted table failed, but approval was successful');
//     }
//   }
//
// // Add this method to your AuthNotifier class in auth_service.dart
//
// // Update trusted user profile (for approved users)
//   Future<void> updateTrustedUserProfile({
//     required String userId,
//     String? aliasName,
//     String? phoneNumber,
//     String? additionalPhone,
//     String? serviceProvider,
//     String? location,
//     String? telegramAccount,
//     String? description,
//     String? workingHours,
//     Map<String, String>? socialLinks,
//   }) async {
//     try {
//       print('🔧 Updating trusted user profile for: $userId');
//
//       // Verify user is authenticated and approved
//       if (!state.isAuthenticated) {
//         throw Exception('غير مصرح بتحديث البيانات - المستخدم غير مصادق عليه');
//       }
//
//       // Allow user to update their own profile or admin to update any profile
//       if (state.user?.uid != userId && !state.isAdmin) {
//         print('🔧 Permission check:');
//         print('  - Current user UID: ${state.user?.uid}');
//         print('  - Target user UID: $userId');
//         print('  - Is admin: ${state.isAdmin}');
//         throw Exception('لا يمكنك تعديل بيانات مستخدم آخر');
//       }
//
//       // Check if user exists in trusted users table
//       final trustedUserDoc =
//           await _firestore.collection('userstransed').doc(userId).get();
//
//       if (!trustedUserDoc.exists) {
//         print(
//             '🔧 User not found in trusted users table, checking users collection...');
//
//         // Check regular users collection
//         final userDoc = await _firestore.collection('users').doc(userId).get();
//
//         if (!userDoc.exists) {
//           throw Exception('المستخدم غير موجود في النظام');
//         }
//
//         // If user exists in regular users but not in trusted, create trusted entry
//         print('🔧 Creating trusted user entry for existing user...');
//         final userData = userDoc.data()!;
//
//         await _firestore.collection('userstransed').doc(userId).set({
//           'uid': userId,
//           'fullName': userData['fullName'] ?? 'مستخدم',
//           'aliasName': userData['fullName'] ?? 'مستخدم',
//           'email': userData['email'] ?? '',
//           'phoneNumber': userData['phoneNumber'] ?? '',
//           'mobileNumber': userData['phoneNumber'] ?? '',
//           'additionalPhone': userData['additionalPhone'] ?? '',
//           'serviceProvider': userData['serviceProvider'] ?? '',
//           'servicesProvided': userData['serviceProvider'] ?? '',
//           'location': userData['location'] ?? '',
//           'role': 1, // Trusted user role
//           'isActive': true,
//           'isApproved': true,
//           'applicationId': userData['applicationId'] ?? '',
//           'telegramAccount': '',
//           'description': '',
//           'workingHours': '',
//           'reviews': [],
//           'statusText': 'موثوق',
//           'profileImageUrl': '',
//           'socialLinks': {},
//           'verificationStatus': 'verified',
//           'rating': 0.0,
//           'totalReviews': 0,
//           'canUpdateProfile': true,
//           'profileCompleted': false,
//           'createdAt': FieldValue.serverTimestamp(),
//           'updatedAt': FieldValue.serverTimestamp(),
//           'lastActive': FieldValue.serverTimestamp(),
//           'joinedDate': FieldValue.serverTimestamp(),
//         });
//
//         print('🔧 ✅ Trusted user entry created');
//       }
//
//       // Prepare update data (only update non-null values)
//       final Map<String, dynamic> updateData = {
//         'updatedAt': FieldValue.serverTimestamp(),
//         'lastActive': FieldValue.serverTimestamp(),
//       };
//
//       if (aliasName != null && aliasName.isNotEmpty) {
//         updateData['aliasName'] = aliasName;
//         updateData['fullName'] = aliasName; // Keep both fields in sync
//       }
//
//       if (phoneNumber != null && phoneNumber.isNotEmpty) {
//         updateData['phoneNumber'] = phoneNumber;
//         updateData['mobileNumber'] = phoneNumber; // Keep both fields in sync
//       }
//
//       if (additionalPhone != null) {
//         updateData['additionalPhone'] = additionalPhone;
//       }
//
//       if (serviceProvider != null && serviceProvider.isNotEmpty) {
//         updateData['serviceProvider'] = serviceProvider;
//         updateData['servicesProvided'] =
//             serviceProvider; // Keep both fields in sync
//       }
//
//       if (location != null && location.isNotEmpty) {
//         updateData['location'] = location;
//       }
//
//       if (telegramAccount != null) {
//         updateData['telegramAccount'] = telegramAccount;
//       }
//
//       if (description != null) {
//         updateData['description'] = description;
//       }
//
//       if (workingHours != null) {
//         updateData['workingHours'] = workingHours;
//       }
//
//       if (socialLinks != null) {
//         updateData['socialLinks'] = socialLinks;
//       }
//
//       // Mark profile as more complete if key fields are filled
//       if (aliasName != null || description != null || telegramAccount != null) {
//         updateData['profileCompleted'] = true;
//       }
//
//       print('🔧 Update data: $updateData');
//
//       // Perform the update on trusted users table
//       await _firestore
//           .collection('userstransed')
//           .doc(userId)
//           .update(updateData);
//
//       print('🔧 ✅ Trusted users table updated');
//
//       // Also update the regular users collection if it exists
//       try {
//         final userDoc = await _firestore.collection('users').doc(userId).get();
//         if (userDoc.exists) {
//           final userUpdateData = <String, dynamic>{
//             'updatedAt': FieldValue.serverTimestamp(),
//           };
//
//           if (aliasName != null && aliasName.isNotEmpty)
//             userUpdateData['fullName'] = aliasName;
//           if (phoneNumber != null && phoneNumber.isNotEmpty)
//             userUpdateData['phoneNumber'] = phoneNumber;
//           if (additionalPhone != null)
//             userUpdateData['additionalPhone'] = additionalPhone;
//           if (serviceProvider != null && serviceProvider.isNotEmpty)
//             userUpdateData['serviceProvider'] = serviceProvider;
//           if (location != null && location.isNotEmpty)
//             userUpdateData['location'] = location;
//
//           await _firestore
//               .collection('users')
//               .doc(userId)
//               .update(userUpdateData);
//           print('🔧 ✅ Regular users collection also updated');
//         }
//       } catch (e) {
//         print('🔧 Could not update regular users collection: $e');
//         // Non-critical error, continue
//       }
//
//       // Update application data if it exists and user has applicationId
//       try {
//         final trustedUserData =
//             await _firestore.collection('userstransed').doc(userId).get();
//         final applicationId = trustedUserData.data()?['applicationId'];
//
//         if (applicationId != null && applicationId.isNotEmpty) {
//           final appUpdateData = <String, dynamic>{
//             'updatedAt': FieldValue.serverTimestamp(),
//           };
//
//           if (aliasName != null && aliasName.isNotEmpty)
//             appUpdateData['fullName'] = aliasName;
//           if (phoneNumber != null && phoneNumber.isNotEmpty)
//             appUpdateData['phoneNumber'] = phoneNumber;
//           if (additionalPhone != null)
//             appUpdateData['additionalPhone'] = additionalPhone;
//           if (serviceProvider != null && serviceProvider.isNotEmpty)
//             appUpdateData['serviceProvider'] = serviceProvider;
//           if (location != null && location.isNotEmpty)
//             appUpdateData['location'] = location;
//           if (telegramAccount != null)
//             appUpdateData['telegramAccount'] = telegramAccount;
//           if (description != null) appUpdateData['description'] = description;
//           if (workingHours != null)
//             appUpdateData['workingHours'] = workingHours;
//
//           await _firestore
//               .collection('user_applications')
//               .doc(applicationId)
//               .update(appUpdateData);
//           print('🔧 ✅ Application data also updated');
//         }
//       } catch (e) {
//         print('🔧 Could not update application data: $e');
//         // Non-critical error, continue
//       }
//
//       print('🔧 ✅ Trusted user profile updated successfully');
//
//       // Refresh the current user's state if they updated their own profile
//       if (state.user?.uid == userId) {
//         await _fetchUserData(state.user!);
//       }
//     } catch (e, stackTrace) {
//       print('🔧 ❌ Error updating trusted user profile: $e');
//       print('🔧 Stack trace: $stackTrace');
//       rethrow;
//     }
//   }
//
// // 🆕 NEW METHOD: Get trusted user profile data
//   Future<Map<String, dynamic>?> getTrustedUserProfile(String userId) async {
//     try {
//       final trustedUserDoc =
//           await _firestore.collection('userstransed').doc(userId).get();
//
//       if (trustedUserDoc.exists) {
//         return trustedUserDoc.data();
//       }
//       return null;
//     } catch (e) {
//       print('🔧 Error getting trusted user profile: $e');
//       return null;
//     }
//   }
//
// // 🆕 NEW METHOD: Remove user from trusted users table (for rejected/revoked users)
//   Future<void> removeFromTrustedUsersTable(String applicationId) async {
//     try {
//       print('🔧 Removing user from trusted users table...');
//
//       // Get the application data to find the Firebase UID
//       final applicationDoc = await _firestore
//           .collection('user_applications')
//           .doc(applicationId)
//           .get();
//
//       if (!applicationDoc.exists) {
//         print('🔧 Application document not found: $applicationId');
//         return;
//       }
//
//       final applicationData = applicationDoc.data()!;
//       final firebaseUid = applicationData['firebaseUid'];
//
//       if (firebaseUid != null && firebaseUid.isNotEmpty) {
//         // Remove from trusted users table
//         await _firestore.collection('userstransed').doc(firebaseUid).delete();
//
//         // Update application status
//         await _firestore
//             .collection('user_applications')
//             .doc(applicationId)
//             .update({
//           'addedToTrustedTable': false,
//           'removedFromTrustedAt': FieldValue.serverTimestamp(),
//         });
//
//         print('🔧 ✅ User removed from trusted users table');
//       }
//     } catch (e) {
//       print('🔧 ❌ Error removing user from trusted users table: $e');
//       // Don't rethrow - this is not critical
//     }
//   }
//
// // 🆕 ENHANCED: Updated _fetchUserData to check trusted users table
//   Future<void> _fetchUserData(User user) async {
//     try {
//       state = state.copyWith(isLoading: true);
//       print('🔍 Fetching user data for UID: ${user.uid}');
//
//       // First, check if user is an admin
//       final adminDoc =
//           await _firestore.collection('admins').doc(user.uid).get();
//
//       if (adminDoc.exists) {
//         print('🔍 User found in admins collection');
//         final adminData = adminDoc.data()!;
//         final roleValue = adminData['role'] as int? ?? 2;
//
//         state = state.copyWith(
//           user: user,
//           role: UserRole.fromInt(roleValue),
//           isAuthenticated: true,
//           isLoading: false,
//           userData: adminData,
//           isTrustedUser: false,
//           isApproved: true, // Admins are always approved
//         );
//         return;
//       }
//
//       // Check if user exists in trusted users table (userstransed)
//       final trustedUserDoc =
//           await _firestore.collection('userstransed').doc(user.uid).get();
//
//       if (trustedUserDoc.exists) {
//         print('🔍 User found in trusted users table');
//         final trustedUserData = trustedUserDoc.data()!;
//         final userRole = trustedUserData['role'] as int? ?? 2;
//
//         // Get application data if available
//         Map<String, dynamic>? applicationData;
//         final applicationId = trustedUserData['applicationId'];
//         if (applicationId != null && applicationId.isNotEmpty) {
//           try {
//             final appDoc = await _firestore
//                 .collection('user_applications')
//                 .doc(applicationId)
//                 .get();
//             if (appDoc.exists) {
//               applicationData = appDoc.data();
//             }
//           } catch (e) {
//             print('🔍 Could not fetch application data: $e');
//           }
//         }
//
//         state = state.copyWith(
//           user: user,
//           role: UserRole.fromInt(userRole),
//           isAuthenticated: true,
//           isLoading: false,
//           userData: trustedUserData,
//           applicationData: applicationData,
//           isTrustedUser: userRole == 1, // role 1 = trusted
//           isApproved: trustedUserData['isApproved'] ?? true,
//         );
//         return;
//       }
//
//       // If not in trusted users, check regular users collection
//       final userDoc = await _firestore.collection('users').doc(user.uid).get();
//
//       if (userDoc.exists) {
//         print('🔍 User found in users collection');
//         final userData = userDoc.data()!;
//         final userRole = userData['role'] ?? '';
//
//         // Check if it's a trusted user
//         final isTrustedUser = userRole == 'user'; // Your current logic
//
//         // Get application data if available
//         Map<String, dynamic>? applicationData;
//         if (isTrustedUser && userData['applicationId'] != null) {
//           try {
//             final appDoc = await _firestore
//                 .collection('user_applications')
//                 .doc(userData['applicationId'])
//                 .get();
//             if (appDoc.exists) {
//               applicationData = appDoc.data();
//             }
//           } catch (e) {
//             print('🔍 Could not fetch application data: $e');
//           }
//         }
//
//         state = state.copyWith(
//           user: user,
//           role: isTrustedUser ? UserRole.trusted : UserRole.common,
//           isAuthenticated: true,
//           isLoading: false,
//           userData: userData,
//           applicationData: applicationData,
//           isTrustedUser: isTrustedUser,
//           isApproved:
//               isTrustedUser, // If they have a Firebase account, they're approved
//         );
//         return;
//       }
//
//       // User exists in Firebase Auth but not in any collection
//       print('🔍 User not found in any collection');
//       state = state.copyWith(
//         user: user,
//         role: UserRole.common,
//         isAuthenticated: true,
//         isLoading: false,
//         userData: null,
//         isTrustedUser: false,
//         isApproved: false,
//       );
//     } catch (e) {
//       debugPrint('Error fetching user data: $e');
//       state = state.copyWith(
//         user: user,
//         role: UserRole.common,
//         isAuthenticated: true,
//         isLoading: false,
//         error: 'Failed to fetch user data',
//         isTrustedUser: false,
//         isApproved: false,
//       );
//     }
//   }
// }
//
// // Providers
// final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
//   return FirebaseAuth.instance;
// });
//
// final firebaseFirestoreProvider = Provider<FirebaseFirestore>((ref) {
//   return FirebaseFirestore.instance;
// });
//
// final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
//   final auth = ref.watch(firebaseAuthProvider);
//   final firestore = ref.watch(firebaseFirestoreProvider);
//   return AuthNotifier(auth, firestore);
// });
//
// // Helper providers
// final isAdminProvider = Provider<bool>((ref) {
//   return ref.watch(authProvider).isAdmin;
// });
//
// final isAuthenticatedProvider = Provider<bool>((ref) {
//   return ref.watch(authProvider).isAuthenticated;
// });
//
// final isTrustedUserProvider = Provider<bool>((ref) {
//   return ref.watch(authProvider).isTrustedUser;
// });
//
// // Application statistics provider
// final applicationStatsProvider = FutureProvider<Map<String, int>>((ref) async {
//   final authNotifier = ref.watch(authProvider.notifier);
//   return await authNotifier.getApplicationStatistics();
// });
