// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
//
// // Enhanced AuthState to include isTrustedUser property
// class AuthState {
//   final User? user;
//   final bool isAuthenticated;
//   final bool isAdmin;
//   final bool isTrustedUser; // ADD THIS PROPERTY
//   final bool isLoading;
//   final String? error;
//   final Map<String, dynamic>? applicationData;
//   final Map<String, dynamic>? userData;
//
//   const AuthState({
//     this.user,
//     this.isAuthenticated = false,
//     this.isAdmin = false,
//     this.isTrustedUser = false, // ADD DEFAULT VALUE
//     this.isLoading = false,
//     this.error,
//     this.applicationData,
//     this.userData,
//   });
//
//   AuthState copyWith({
//     User? user,
//     bool? isAuthenticated,
//     bool? isAdmin,
//     bool? isTrustedUser, // ADD THIS PARAMETER
//     bool? isLoading,
//     String? error,
//     Map<String, dynamic>? applicationData,
//     Map<String, dynamic>? userData,
//   }) {
//     return AuthState(
//       user: user ?? this.user,
//       isAuthenticated: isAuthenticated ?? this.isAuthenticated,
//       isAdmin: isAdmin ?? this.isAdmin,
//       isTrustedUser: isTrustedUser ?? this.isTrustedUser, // ADD THIS LINE
//       isLoading: isLoading ?? this.isLoading,
//       error: error ?? this.error,
//       applicationData: applicationData ?? this.applicationData,
//       userData: userData ?? this.userData,
//     );
//   }
// }
//
// // Enhanced AuthNotifier with separate login methods
// class AuthNotifier extends StateNotifier<AuthState> {
//   final FirebaseAuth _auth;
//   final FirebaseFirestore _firestore;
//
//   AuthNotifier(this._auth, this._firestore) : super(const AuthState()) {
//     _auth.authStateChanges().listen(_onAuthStateChanged);
//   }
//
//   final isAdminProvider = Provider<bool>((ref) {
//     return ref.watch(authProvider).isAdmin;
//   });
//
//   Future<void> _onAuthStateChanged(User? user) async {
//     if (user != null) {
//       try {
//         // Check user role in Firestore
//         final userDoc =
//             await _firestore.collection('users').doc(user.uid).get();
//
//         if (userDoc.exists) {
//           final userData = userDoc.data()!;
//           final role = userData['role'] ?? '';
//
//           final isAdmin = role == 'admin';
//           final isTrustedUser = role == 'user' || role == 'trusted_user';
//
//           state = state.copyWith(
//             user: user,
//             isAuthenticated: true,
//             isAdmin: isAdmin,
//             isTrustedUser: isTrustedUser, // SET THE TRUSTED USER STATUS
//             isLoading: false,
//             error: null,
//             userData: userData,
//           );
//         } else {
//           // User document doesn't exist, sign them out
//           await _auth.signOut();
//           state = const AuthState();
//         }
//       } catch (e) {
//         state = state.copyWith(
//           error: e.toString(),
//           isLoading: false,
//         );
//       }
//     } else {
//       state = const AuthState();
//     }
//   }
//
//   // Admin sign in method (your existing one, but enhanced)
//   Future<void> signIn(String email, String password) async {
//     try {
//       state = state.copyWith(isLoading: true, error: null);
//
//       final credential = await _auth.signInWithEmailAndPassword(
//         email: email,
//         password: password,
//       );
//
//       // Check if user is admin
//       final userDoc =
//           await _firestore.collection('users').doc(credential.user!.uid).get();
//
//       if (!userDoc.exists) {
//         await _auth.signOut();
//         throw Exception('المستخدم غير موجود');
//       }
//
//       final userData = userDoc.data()!;
//       final isAdmin = userData['role'] == 'admin';
//
//       if (!isAdmin) {
//         await _auth.signOut();
//         throw Exception('لا تملك صلاحيات الإدارة المطلوبة');
//       }
//
//       state = state.copyWith(
//         user: credential.user,
//         isAuthenticated: true,
//         isAdmin: true,
//         isTrustedUser: false, // Admin is not a trusted user
//         isLoading: false,
//         userData: userData,
//       );
//     } catch (e) {
//       state = state.copyWith(
//         error: e.toString(),
//         isLoading: false,
//       );
//       rethrow;
//     }
//   }
//
//   // Enhanced version with debug logs
//   // Enhanced debug version of signInTrustedUser
//   Future<void> signInTrustedUser(String email, String password) async {
//     try {
//       print('🔐 [signInTrustedUser] Starting login for: $email');
//       print('🔐 [signInTrustedUser] Password length: ${password.length}');
//       state = state.copyWith(isLoading: true, error: null);
//
//       print('🔐 [signInTrustedUser] Attempting Firebase Auth sign in...');
//
//       // Check if user exists in Firebase Auth first
//       try {
//         final methods = await _auth.fetchSignInMethodsForEmail(email);
//         print('🔐 [signInTrustedUser] Sign-in methods for $email: $methods');
//
//         if (methods.isEmpty) {
//           print('🔐 [signInTrustedUser] No user found with email: $email');
//           throw Exception(
//               'المستخدم غير موجود في النظام. يرجى التأكد من البريد الإلكتروني أو التسجيل أولاً.');
//         }
//       } catch (e) {
//         print('🔐 [signInTrustedUser] Error checking sign-in methods: $e');
//       }
//
//       final credential = await _auth.signInWithEmailAndPassword(
//         email: email,
//         password: password,
//       );
//
//       print(
//           '🔐 [signInTrustedUser] Firebase Auth successful! User UID: ${credential.user!.uid}');
//       print(
//           '🔐 [signInTrustedUser] User email verified: ${credential.user!.emailVerified}');
//
//       // Check if user exists and is a trusted user
//       print('🔐 [signInTrustedUser] Checking user document in Firestore...');
//       final userDoc =
//           await _firestore.collection('users').doc(credential.user!.uid).get();
//
//       print('🔐 [signInTrustedUser] User document exists: ${userDoc.exists}');
//
//       if (!userDoc.exists) {
//         print(
//             '🔐 [signInTrustedUser] User document does not exist, signing out...');
//         await _auth.signOut();
//         throw Exception(
//             'الحساب موجود لكن لم يتم تفعيله بعد. يرجى انتظار موافقة الإدارة.');
//       }
//
//       final userData = userDoc.data()!;
//       final role = userData['role'] ?? '';
//       final isTrustedUser = role == 'user' || role == 'trusted_user';
//
//       print('🔐 [signInTrustedUser] User data retrieved:');
//       print('  - Role: $role');
//       print('  - Is Trusted User: $isTrustedUser');
//       print('  - Full Name: ${userData['fullName']}');
//       print('  - Email: ${userData['email']}');
//       print('  - Is Active: ${userData['isActive']}');
//
//       if (!isTrustedUser) {
//         print(
//             '🔐 [signInTrustedUser] User is not a trusted user (role: $role), signing out...');
//         await _auth.signOut();
//         throw Exception('هذا الحساب ليس للمستخدمين الموثوقين');
//       }
//
//       // Check if account is active
//       final isActive = userData['isActive'] ?? false;
//       if (!isActive) {
//         print(
//             '🔐 [signInTrustedUser] User account is not active, signing out...');
//         await _auth.signOut();
//         throw Exception('حسابك غير نشط، يرجى التواصل مع الإدارة');
//       }
//
//       print('🔐 [signInTrustedUser] All checks passed, updating auth state...');
//       state = state.copyWith(
//         user: credential.user,
//         isAuthenticated: true,
//         isAdmin: false,
//         isTrustedUser: true,
//         isLoading: false,
//         userData: userData,
//       );
//
//       print('🔐 [signInTrustedUser] Auth state updated successfully!');
//     } catch (e) {
//       print('🔐 [signInTrustedUser] Error occurred: $e');
//       state = state.copyWith(
//         error: e.toString(),
//         isLoading: false,
//       );
//       rethrow;
//     }
//   }
//
//   // Your existing registerUser method (keep as is)
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
//       print('🔥 Registration started for email: $email'); // ADD THIS
//       state = state.copyWith(isLoading: true, error: null);
//
//       // Check if email is already registered
//       print('🔥 Checking for existing applications...'); // ADD THIS
//       final existingApplication = await _firestore
//           .collection('user_applications')
//           .where('email', isEqualTo: email.toLowerCase())
//           .get();
//
//       print(
//           '🔥 Found ${existingApplication.docs.length} existing applications'); // ADD THIS
//
//       if (existingApplication.docs.isNotEmpty) {
//         throw Exception('البريد الإلكتروني مسجل مسبقاً');
//       }
//
//       // Create application document
//       print('🔥 Creating application document...'); // ADD THIS
//       final applicationData = {
//         'fullName': fullName,
//         'email': email.toLowerCase(),
//         'password': password, // In production, hash this password
//         'phoneNumber': phoneNumber,
//         'additionalPhone': additionalPhone ?? '',
//         'serviceProvider': serviceProvider,
//         'location': location,
//         'status': 'in_progress',
//         'adminComment': '',
//         'createdAt': FieldValue.serverTimestamp(),
//         'updatedAt': FieldValue.serverTimestamp(),
//       };
//
//       print('🔥 Adding document to Firestore...'); // ADD THIS
//       final docRef =
//           await _firestore.collection('user_applications').add(applicationData);
//       print('🔥 Document created with ID: ${docRef.id}'); // ADD THIS
//
//       // Update with document ID
//       await docRef.update({'uid': docRef.id});
//       print('🔥 Document updated with UID'); // ADD THIS
//
//       state = state.copyWith(isLoading: false);
//       print('🔥 Registration completed successfully!'); // ADD THIS
//     } catch (e) {
//       print('🔥 Registration error: $e'); // ADD THIS
//       state = state.copyWith(
//         error: e.toString(),
//         isLoading: false,
//       );
//       rethrow;
//     }
//   }
//   // Your existing methods (keep them as they are)...
//
//   // Get application status by email
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
//   // Admin method: Get all user applications
//   Future<List<Map<String, dynamic>>> getAllUserApplications() async {
//     try {
//       final applications = await _firestore
//           .collection('user_applications')
//           .orderBy('createdAt', descending: true)
//           .get();
//
//       return applications.docs.map((doc) {
//         final data = doc.data();
//         // Convert Firestore timestamps to strings
//         if (data['createdAt'] != null) {
//           data['createdAt'] =
//               (data['createdAt'] as Timestamp).toDate().toIso8601String();
//         }
//         if (data['updatedAt'] != null) {
//           data['updatedAt'] =
//               (data['updatedAt'] as Timestamp).toDate().toIso8601String();
//         }
//         return data;
//       }).toList();
//     } catch (e) {
//       rethrow;
//     }
//   }
//
//   // Admin method: Update application status
//   Future<void> updateUserApplicationStatus(String applicationId, String status,
//       {String? comment}) async {
//     try {
//       final updateData = {
//         'status': status,
//         'updatedAt': FieldValue.serverTimestamp(),
//       };
//
//       if (comment != null) {
//         updateData['adminComment'] = comment;
//       }
//
//       await _firestore
//           .collection('user_applications')
//           .doc(applicationId)
//           .update(updateData);
//
//       // If approved, create Firebase Auth account and user document
//       if (status.toLowerCase() == 'approved') {
//         await _createApprovedUserAccount(applicationId);
//       }
//     } catch (e) {
//       rethrow;
//     }
//   }
//
//   // Private method: Create Firebase Auth account for approved users
//   Future<void> _createApprovedUserAccount(String applicationId) async {
//     try {
//       final applicationDoc = await _firestore
//           .collection('user_applications')
//           .doc(applicationId)
//           .get();
//
//       if (!applicationDoc.exists) return;
//
//       final applicationData = applicationDoc.data()!;
//       final email = applicationData['email'];
//       final password = applicationData['password'];
//       final fullName = applicationData['fullName'];
//
//       // Create Firebase Auth account
//       final userCredential = await _auth.createUserWithEmailAndPassword(
//         email: email,
//         password: password,
//       );
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
//       // Sign out the newly created user (since we're in admin context)
//       await _auth.signOut();
//     } catch (e) {
//       // Log error but don't throw - the status update should still succeed
//       print('Error creating user account: $e');
//     }
//   }
//
//   // Sign out
//   Future<void> signOut() async {
//     try {
//       await _auth.signOut();
//       state = const AuthState();
//     } catch (e) {
//       state = state.copyWith(error: e.toString());
//       rethrow;
//     }
//   }
//
//   // Get current user data
//   Future<Map<String, dynamic>?> getCurrentUserData() async {
//     try {
//       if (state.user == null) return null;
//
//       final userDoc =
//           await _firestore.collection('users').doc(state.user!.uid).get();
//
//       if (userDoc.exists) {
//         final data = userDoc.data()!;
//         // Convert timestamps
//         if (data['createdAt'] != null) {
//           data['createdAt'] =
//               (data['createdAt'] as Timestamp).toDate().toIso8601String();
//         }
//         return data;
//       }
//       return null;
//     } catch (e) {
//       return null;
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
//   // Check if email exists in applications
//   Future<bool> emailExistsInApplications(String email) async {
//     try {
//       final applications = await _firestore
//           .collection('user_applications')
//           .where('email', isEqualTo: email.toLowerCase())
//           .get();
//
//       return applications.docs.isNotEmpty;
//     } catch (e) {
//       return false;
//     }
//   }
//
//   // Delete application (admin only)
//   Future<void> deleteApplication(String applicationId) async {
//     try {
//       await _firestore
//           .collection('user_applications')
//           .doc(applicationId)
//           .delete();
//     } catch (e) {
//       rethrow;
//     }
//   }
// }
//
// // Providers
// final firebaseAuthProvider =
//     Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);
// final firebaseFirestoreProvider =
//     Provider<FirebaseFirestore>((ref) => FirebaseFirestore.instance);
//
// final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
//   final auth = ref.watch(firebaseAuthProvider);
//   final firestore = ref.watch(firebaseFirestoreProvider);
//   return AuthNotifier(auth, firestore);
// });
//
// // Application statistics provider
// final applicationStatsProvider = FutureProvider<Map<String, int>>((ref) async {
//   final authNotifier = ref.watch(authProvider.notifier);
//   return await authNotifier.getApplicationStatistics();
// });
