import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:riverpod/riverpod.dart';
import 'package:trustedtallentsvalley/config/firebase_constant.dart';
import 'package:trustedtallentsvalley/fetures/Home/models/ActivityUpdate.dart';
import 'package:trustedtallentsvalley/fetures/services/auth_service.dart';
import 'package:trustedtallentsvalley/fetures/trusted/model/user_model.dart';

class UserData {
  final String aliasName;
  final String mobileNumber;
  final String location;
  final int role;
  final String servicesProvided;
  final String telegramAccount;
  final String otherAccounts;
  final String reviews;

  UserData({
    required this.aliasName,
    required this.mobileNumber,
    required this.location,
    required this.role,
    required this.servicesProvided,
    required this.telegramAccount,
    required this.otherAccounts,
    required this.reviews,
  });
}

// Define filter modes
enum FilterMode { all, withReviews, withoutTelegram, byLocation }

// Enhanced HomeState class with more properties
class HomeState {
  final bool showSideBar;
  final UserModel? selectedUser;
  final UserModel? userModel;
  final String searchQuery;
  final int currentPage;
  final int pageSize;
  final String sortField;
  final bool sortAscending;
  final FilterMode filterMode;
  final String? locationFilter;
  final bool isLoading;
  final String? errorMessage;

  HomeState({
    this.showSideBar = false,
    this.selectedUser,
    this.userModel,
    this.searchQuery = '',
    this.currentPage = 1,
    this.pageSize = 10,
    this.sortField = 'aliasName',
    this.sortAscending = true,
    this.filterMode = FilterMode.all,
    this.locationFilter,
    this.isLoading = false,
    this.errorMessage,
  });

  // Create a copy of the state with modified properties
  HomeState copyWith({
    bool? showSideBar,
    UserModel? selectedUser,
    UserModel? userModel,
    String? searchQuery,
    int? currentPage,
    int? pageSize,
    String? sortField,
    bool? sortAscending,
    FilterMode? filterMode,
    String? locationFilter,
    bool? isLoading,
    String? errorMessage,
  }) {
    return HomeState(
      showSideBar: showSideBar ?? this.showSideBar,
      selectedUser: selectedUser ?? this.selectedUser,
      userModel: userModel ?? this.userModel,
      searchQuery: searchQuery ?? this.searchQuery,
      currentPage: currentPage ?? this.currentPage,
      pageSize: pageSize ?? this.pageSize,
      sortField: sortField ?? this.sortField,
      sortAscending: sortAscending ?? this.sortAscending,
      filterMode: filterMode ?? this.filterMode,
      locationFilter: locationFilter ?? this.locationFilter,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

final firebaseFirestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

// ✅ FIXED - Move this outside the class
final visiblePhoneNumberProvider = StateProvider<String?>((ref) => null);

// Enhanced HomeNotifier with additional methods
class HomeNotifier extends StateNotifier<HomeState> {
  final FirebaseFirestore _firestore;

  HomeNotifier(this._firestore) : super(HomeState());

  // Method to toggle phone number visibility
  void togglePhoneNumberVisibility(String userId, ref) {
    final currentVisibleId = ref.read(visiblePhoneNumberProvider);

    if (currentVisibleId == userId) {
      // Hide the current visible number
      ref.read(visiblePhoneNumberProvider.notifier).state = null;
    } else {
      // Show this user's number (and hide any other)
      ref.read(visiblePhoneNumberProvider.notifier).state = userId;
    }
  }

  // Method to hide all phone numbers
  void hideAllPhoneNumbers(ref) {
    ref.read(visiblePhoneNumberProvider.notifier).state = null;
  }

  // Method to check if a specific user's phone number is visible
  bool isPhoneNumberVisible(String userId, ref) {
    final visibleId = ref.read(visiblePhoneNumberProvider);
    return visibleId == userId;
  }

  // Get user data from Firestore
  Future<void> getGoalData() async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      DocumentSnapshot doc = await _firestore
          .collection(FirebaseConstant.trustedUsers)
          .doc()
          .get();

      state = state.copyWith(
        userModel: UserModel.fromFirestore(doc),
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Error fetching data: $e',
      );
      debugPrint('Error fetching goal data: $e');
    }
  }

  // Close/toggle sidebar
  void closeBar() {
    state = state.copyWith(showSideBar: !state.showSideBar);
  }

  // Toggle sidebar visibility based on selected user
  void visibleBar({UserModel? selected}) {
    if (state.selectedUser == selected) {
      // Toggle sidebar if same user is selected
      state = state.copyWith(showSideBar: !state.showSideBar);
    } else {
      // Show sidebar and update selected user
      state = state.copyWith(
        showSideBar: true,
        selectedUser: selected,
      );
    }
  }

  // Get currently selected user
  UserModel? getUser() {
    return state.selectedUser;
  }

  // Set search query
  void setSearchQuery(String query) {
    state = state.copyWith(
      searchQuery: query,
      currentPage: 1, // Reset to first page when search changes
    );
  }

  // Set current page for pagination
  void setCurrentPage(int page) {
    state = state.copyWith(currentPage: page);
  }

  // Set page size for pagination
  void setPageSize(int size) {
    state = state.copyWith(
      pageSize: size,
      currentPage: 1, // Reset to first page when page size changes
    );
  }

  // Set sort field and direction
  void setSort(String field, {bool? ascending}) {
    // If same field, toggle direction unless specified
    if (field == state.sortField && ascending == null) {
      state = state.copyWith(sortAscending: !state.sortAscending);
    } else {
      state = state.copyWith(
        sortField: field,
        sortAscending: ascending ?? true,
      );
    }
  }

  // Set filter mode
  void setFilterMode(FilterMode mode) {
    state = state.copyWith(
      filterMode: mode,
      currentPage: 1, // Reset to first page when filter changes
    );
  }

  // Set location filter
  void setLocationFilter(String? location) {
    state = state.copyWith(
      locationFilter: location,
      filterMode: FilterMode.byLocation,
      currentPage: 1, // Reset to first page when filter changes
    );
  }

  // Add this method to your HomeNotifier class for debugging
  Future<void> debugFirestoreData() async {
    try {
      final snapshot = await _firestore
          .collection(FirebaseConstant.trustedUsers)
          .limit(5)
          .get();

      debugPrint('=== FIRESTORE DEBUG ===');
      debugPrint('Total documents: ${snapshot.docs.length}');

      for (var doc in snapshot.docs) {
        debugPrint('Document ID: ${doc.id}');
        debugPrint('Document data: ${doc.data()}');
        debugPrint('---');
      }

      // Try to convert to UserModel
      for (var doc in snapshot.docs) {
        try {
          final user = UserModel.fromFirestore(doc);
          debugPrint(
              'Successfully converted: ${user.aliasName} (role: ${user.role})');
        } catch (e) {
          debugPrint('Failed to convert document ${doc.id}: $e');
        }
      }
    } catch (e) {
      debugPrint('Error debugging Firestore: $e');
    }
  }

  // ✅ FIXED - Add new user to Firestore with CORRECT field names
  Future<bool> addUser({
    ref,
    required String aliasName,
    required String mobileNumber,
    required String location,
    required int role, // ✅ FIXED - Changed from trustLevel to role
    String? servicesProvided,
    String? telegramAccount,
    String? otherAccounts,
    String? reviews,
  }) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      final auth = ref.read(firebaseAuthProvider);
      final currentUser = auth.currentUser;
      final adminName =
          currentUser?.displayName ?? currentUser?.email ?? 'مشرف غير معروف';

      final docRef = _firestore.collection(FirebaseConstant.trustedUsers).doc();

      await docRef.set({
        'id': docRef.id,
        'aliasName': aliasName,
        'mobileNumber': mobileNumber,
        'location': location,
        'role': role, // ✅ FIXED - Use 'role' instead of 'trustLevel'
        'servicesProvided': servicesProvided ?? '',
        'telegramAccount': telegramAccount ?? '',
        'otherAccounts': otherAccounts ?? '',
        'reviews': reviews ?? '',
        'createdAt': FieldValue.serverTimestamp(),
        'addedBy': adminName,
      });

      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Error adding user: $e',
      );
      debugPrint('Error adding user: $e');
      return false;
    }
  }

  // ✅ FIXED - Update existing user in Firestore with CORRECT field names
  Future<bool> updateUser({
    required String id,
    required String aliasName,
    required String mobileNumber,
    required String location,
    required int role, // ✅ FIXED - Changed from trustLevel to role
    required String servicesProvided,
    required String telegramAccount,
    required String otherAccounts,
    required String reviews,
  }) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      await _firestore
          .collection(FirebaseConstant.trustedUsers)
          .doc(id)
          .update({
        'aliasName': aliasName,
        'mobileNumber': mobileNumber,
        'location': location,
        'role': role, // ✅ FIXED - Use 'role' instead of 'trustLevel'
        'servicesProvided': servicesProvided,
        'telegramAccount': telegramAccount,
        'otherAccounts': otherAccounts,
        'reviews': reviews,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Error updating user: $e',
      );
      debugPrint('Error updating user: $e');
      return false;
    }
  }

  // Delete user from Firestore
  Future<bool> deleteUser(String id) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      await _firestore
          .collection(FirebaseConstant.trustedUsers)
          .doc(id)
          .delete();

      // If we're deleting the currently selected user, clear it from the state
      if (state.selectedUser?.id == id) {
        state = state.copyWith(
          selectedUser: null,
          showSideBar: false,
          isLoading: false,
        );
      } else {
        state = state.copyWith(isLoading: false);
      }

      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Error deleting user: $e',
      );
      debugPrint('Error deleting user: $e');
      return false;
    }
  }

  // Export data (placeholder for actual implementation)
  Future<String?> exportData(String format) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      // This would be implemented with actual export logic
      // For now, it's just a placeholder
      await Future.delayed(const Duration(seconds: 1));

      state = state.copyWith(isLoading: false);
      return "Exported data.$format";
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Error exporting data: $e',
      );
      debugPrint('Error exporting data: $e');
      return null;
    }
  }
}

// Main provider for HomeState using StateNotifierProvider
final homeProvider = StateNotifierProvider<HomeNotifier, HomeState>((ref) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  return HomeNotifier(firestore);
});

// Individual providers for specific parts of the state
final showSideBarProvider = Provider<bool>((ref) {
  return ref.watch(homeProvider).showSideBar;
});

final selectedUserProvider = Provider<UserModel?>((ref) {
  return ref.watch(homeProvider).selectedUser;
});

final searchQueryProvider = StateProvider<String>((ref) {
  return ref.watch(homeProvider).searchQuery;
});

final currentPageProvider = StateProvider<int>((ref) {
  return ref.watch(homeProvider).currentPage;
});

final pageSizeProvider = StateProvider<int>((ref) {
  return ref.watch(homeProvider).pageSize;
});

final sortFieldProvider = StateProvider<String>((ref) {
  return ref.watch(homeProvider).sortField;
});

final sortDirectionProvider = StateProvider<bool>((ref) {
  return ref.watch(homeProvider).sortAscending;
});

final filterModeProvider = StateProvider<FilterMode>((ref) {
  return ref.watch(homeProvider).filterMode;
});

final locationFilterProvider = StateProvider<String?>((ref) {
  return ref.watch(homeProvider).locationFilter;
});

final isLoadingProvider = Provider<bool>((ref) {
  return ref.watch(homeProvider).isLoading;
});

final errorMessageProvider = Provider<String?>((ref) {
  return ref.watch(homeProvider).errorMessage;
});

// A provider to get all unique locations for filtering
final locationsProvider = StreamProvider<List<String>>((ref) {
  return FirebaseFirestore.instance
      .collection(FirebaseConstant.trustedUsers)
      .snapshots()
      .map((snapshot) {
    final locations = snapshot.docs
        .map((doc) => doc['location'] as String? ?? '')
        .where((location) => location.isNotEmpty)
        .toSet()
        .toList();
    locations.sort();
    return locations;
  });
});

// Stream provider for trusted users (role = 1)
final trustedUsersStreamProvider = StreamProvider<QuerySnapshot>((ref) {
  return FirebaseFirestore.instance
      .collection(FirebaseConstant.trustedUsers)
      .where("role", isEqualTo: 1) // 1 = موثوق (Trusted)
      .snapshots();
});

// Stream provider for untrusted users (role = 3)
final untrustedUsersStreamProvider = StreamProvider<QuerySnapshot>((ref) {
  return FirebaseFirestore.instance
      .collection(FirebaseConstant.trustedUsers)
      .where("role", isEqualTo: 3) // 3 = نصاب (Fraud/Untrusted)
      .snapshots();
});

// Stream provider for admin users (role = 0)
final adminUsersStreamProvider = StreamProvider<QuerySnapshot>((ref) {
  return FirebaseFirestore.instance
      .collection(FirebaseConstant.trustedUsers)
      .where("role", isEqualTo: 0) // 0 = مشرف (Admin)
      .snapshots();
});

// Stream provider for known users (role = 2)
final knownUsersStreamProvider = StreamProvider<QuerySnapshot>((ref) {
  return FirebaseFirestore.instance
      .collection(FirebaseConstant.trustedUsers)
      .where("role", isEqualTo: 2) // 2 = معروف (Known)
      .snapshots();
});

// Stream provider for all users (no filtering)
final allUsersStreamProvider = StreamProvider<QuerySnapshot>((ref) {
  return FirebaseFirestore.instance
      .collection(FirebaseConstant.trustedUsers)
      .snapshots();
});

// Stream provider for non-admin users (roles 1, 2, 3)
final nonAdminUsersStreamProvider = StreamProvider<QuerySnapshot>((ref) {
  return FirebaseFirestore.instance
      .collection(FirebaseConstant.trustedUsers)
      .where("role", whereIn: [1, 2, 3]) // All non-admin roles
      .snapshots();
});

// Provider for all activities (admin view)
final allActivitiesProvider = StreamProvider<List<Activity>>((ref) {
  return FirebaseFirestore.instance
      .collection('activities')
      .orderBy('date', descending: true)
      .snapshots()
      .map((snapshot) =>
          snapshot.docs.map((doc) => Activity.fromFirestore(doc)).toList());
});

// Provider for public activities only (user view)
final publicActivitiesProvider = StreamProvider<List<Activity>>((ref) {
  try {
    // First, check if the collection exists
    return FirebaseFirestore.instance
        .collection('activities')
        .where('isPublic', isEqualTo: true)
        .orderBy('date', descending: true)
        .limit(5)
        .snapshots()
        .map((snapshot) {
      // Debug information
      print('Activities snapshot: ${snapshot.docs.length} documents');

      // Map documents to Activity objects with error handling
      final activities = <Activity>[];

      for (final doc in snapshot.docs) {
        try {
          final data = doc.data();

          // Verify required fields exist
          if (!data.containsKey('title') ||
              !data.containsKey('description') ||
              !data.containsKey('date')) {
            print('Document ${doc.id} missing required fields');
            continue;
          }

          // Convert to Activity object
          activities.add(Activity.fromFirestore(doc));
        } catch (e) {
          print('Error parsing document ${doc.id}: $e');
          // Skip this document but continue processing others
        }
      }

      return activities;
    });
  } catch (e) {
    // Fallback to an empty list if collection doesn't exist
    print('Error setting up activities stream: $e');
    return Stream.value([]);
  }
});

// Activity service for CRUD operations
class ActivityService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add a new activity
  Future<String> addActivity(Activity activity) async {
    try {
      final docRef =
          await _firestore.collection('activities').add(activity.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to add activity: $e');
    }
  }

  // Update an existing activity
  Future<void> updateActivity(Activity activity) async {
    try {
      await _firestore
          .collection('activities')
          .doc(activity.id)
          .update(activity.toMap());
    } catch (e) {
      throw Exception('Failed to update activity: $e');
    }
  }

  // Delete an activity
  Future<void> deleteActivity(String id) async {
    try {
      await _firestore.collection('activities').doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete activity: $e');
    }
  }

  // Toggle activity visibility
  Future<void> toggleActivityVisibility(String id, bool isPublic) async {
    try {
      await _firestore
          .collection('activities')
          .doc(id)
          .update({'isPublic': isPublic});
    } catch (e) {
      throw Exception('Failed to toggle activity visibility: $e');
    }
  }
}

// Provider for the activity service
final activityServiceProvider = Provider<ActivityService>((ref) {
  return ActivityService();
});

// Call this at app initialization
Future<void> ensureActivitiesCollectionExists() async {
  try {
    final snapshot = await FirebaseFirestore.instance
        .collection('activities')
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      // Create an initial activity
      await FirebaseFirestore.instance.collection('activities').add({
        'title': 'مرحباً بكم',
        'description': 'أهلاً بكم في موقعنا. سنقوم بنشر آخر التحديثات هنا.',
        'date': Timestamp.now(),
        'type': 'announcement',
        'createdBy': 'النظام',
        'isPublic': true,
      });

      print('Created initial activity');
    }
  } catch (e) {
    print('Error ensuring activities collection exists: $e');
  }
}
