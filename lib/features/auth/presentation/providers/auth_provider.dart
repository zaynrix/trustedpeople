// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:trustedtallentsvalley/features/auth/data/datasources/auth_local_datasource.dart';
// import 'package:trustedtallentsvalley/features/auth/data/datasources/auth_remote_datasource.dart';
// import 'package:trustedtallentsvalley/features/auth/data/repositories/auth_repository_impl.dart';
// import 'package:trustedtallentsvalley/features/auth/domain/entities/user.dart';
// import 'package:trustedtallentsvalley/features/auth/domain/repositories/auth_repository.dart';
// import 'package:trustedtallentsvalley/features/auth/domain/usecases/get_current_user_usecase.dart';
// import 'package:trustedtallentsvalley/features/auth/domain/usecases/login_usecase.dart';
// import 'package:trustedtallentsvalley/features/auth/domain/usecases/logout_usecase.dart';
//
// // Firebase providers
// final firebaseAuthProvider = Provider<firebase_auth.FirebaseAuth>((ref) {
//   return firebase_auth.FirebaseAuth.instance;
// });
//
// final firebaseFirestoreProvider = Provider<FirebaseFirestore>((ref) {
//   return FirebaseFirestore.instance;
// });
//
// // Data sources providers
// final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
//   final firebaseAuth = ref.watch(firebaseAuthProvider);
//   final firestore = ref.watch(firebaseFirestoreProvider);
//   return AuthRemoteDataSource(
//     firebaseAuth: firebaseAuth,
//     firestore: firestore,
//   );
// });
//
// final authLocalDataSourceProvider = Provider<AuthLocalDataSource>((ref) {
//   return AuthLocalDataSource();
// });
//
// // Repository provider
// final authRepositoryProvider = Provider<AuthRepository>((ref) {
//   final remoteDataSource = ref.watch(authRemoteDataSourceProvider);
//   final localDataSource = ref.watch(authLocalDataSourceProvider);
//   return AuthRepositoryImpl(
//     remoteDataSource: remoteDataSource,
//     localDataSource: localDataSource,
//   );
// });
//
// // Use case providers
// final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
//   final repository = ref.watch(authRepositoryProvider);
//   return LoginUseCase(repository);
// });
//
// final logoutUseCaseProvider = Provider<LogoutUseCase>((ref) {
//   final repository = ref.watch(authRepositoryProvider);
//   return LogoutUseCase(repository);
// });
//
// final getCurrentUserUseCaseProvider = Provider<GetCurrentUserUseCase>((ref) {
//   final repository = ref.watch(authRepositoryProvider);
//   return GetCurrentUserUseCase(repository);
// });
//
// // Auth state
// class AuthState {
//   final User? user;
//   final bool isLoading;
//   final String? error;
//
//   bool get isAuthenticated => user != null;
//   bool get isAdmin => user?.isAdmin ?? false;
//
//   AuthState({
//     this.user,
//     this.isLoading = false,
//     this.error,
//   });
//
//   AuthState copyWith({
//     User? user,
//     bool? isLoading,
//     String? error,
//   }) {
//     return AuthState(
//       user: user ?? this.user,
//       isLoading: isLoading ?? this.isLoading,
//       error: error,
//     );
//   }
// }
//
// // Auth notifier
// class AuthNotifier extends StateNotifier<AuthState> {
//   final LoginUseCase _loginUseCase;
//   final LogoutUseCase _logoutUseCase;
//   final GetCurrentUserUseCase _getCurrentUserUseCase;
//
//   AuthNotifier({
//     required LoginUseCase loginUseCase,
//     required LogoutUseCase logoutUseCase,
//     required GetCurrentUserUseCase getCurrentUserUseCase,
//   })  : _loginUseCase = loginUseCase,
//         _logoutUseCase = logoutUseCase,
//         _getCurrentUserUseCase = getCurrentUserUseCase,
//         super(AuthState()) {
//     // Listen to auth state changes
//     _getCurrentUserUseCase.authStateChanges.listen((user) {
//       state = state.copyWith(user: user);
//     });
//   }
//
//   // Sign in with email and password
//   Future<void> signIn(String email, String password) async {
//     try {
//       state = state.copyWith(isLoading: true, error: null);
//       final user = await _loginUseCase(email, password);
//       state = state.copyWith(
//         user: user,
//         isLoading: false,
//       );
//     } catch (e) {
//       state = state.copyWith(
//         isLoading: false,
//         error: e.toString(),
//       );
//     }
//   }
//
//   // Sign out
//   Future<void> signOut() async {
//     try {
//       state = state.copyWith(isLoading: true, error: null);
//       await _logoutUseCase();
//       state = state.copyWith(
//         user: null,
//         isLoading: false,
//       );
//     } catch (e) {
//       state = state.copyWith(
//         isLoading: false,
//         error: e.toString(),
//       );
//     }
//   }
//
//   // Get current user
//   Future<void> checkAuthStatus() async {
//     try {
//       state = state.copyWith(isLoading: true, error: null);
//       final user = await _getCurrentUserUseCase();
//       state = state.copyWith(
//         user: user,
//         isLoading: false,
//       );
//     } catch (e) {
//       state = state.copyWith(
//         isLoading: false,
//         error: e.toString(),
//       );
//     }
//   }
// }
//
// // Auth provider
// final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
//   final loginUseCase = ref.watch(loginUseCaseProvider);
//   final logoutUseCase = ref.watch(logoutUseCaseProvider);
//   final getCurrentUserUseCase = ref.watch(getCurrentUserUseCaseProvider);
//
//   return AuthNotifier(
//     loginUseCase: loginUseCase,
//     logoutUseCase: logoutUseCase,
//     getCurrentUserUseCase: getCurrentUserUseCase,
//   );
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

  bool get isAdmin => role == UserRole.admin;
  bool get isAuthenticated => user != null;

  AuthState({
    this.user,
    this.role = UserRole.common,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    User? user,
    UserRole? role,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      user: user ?? this.user,
      role: role ?? this.role,
      isLoading: isLoading ?? this.isLoading,
      error: error,
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
        await _fetchUserRole(user);
      }
    });
  }

  Future<void> _fetchUserRole(User user) async {
    try {
      state = state.copyWith(isLoading: true);

      // Check the user's role in Firestore
      final userDoc = await _firestore.collection('admins').doc(user.uid).get();

      if (userDoc.exists) {
        final roleValue = userDoc.data()?['role'] as int? ??
            2; // Default to common (2) if role not specified
        state = state.copyWith(
          user: user,
          role: UserRole.fromInt(roleValue),
          isLoading: false,
        );
      } else {
        // If user is not in admins collection, they're not an admin
        state = state.copyWith(
          user: user,
          role: UserRole.common,
          isLoading: false,
        );
      }
    } catch (e) {
      debugPrint('Error fetching user role: $e');
      state = state.copyWith(
        user: user,
        role: UserRole.common, // Default to common on error
        isLoading: false,
        error: 'Failed to fetch user role',
      );
    }
  }

  Future<void> signIn(String email, String password) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Auth state listener will update the state
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Invalid email or password',
      );
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
