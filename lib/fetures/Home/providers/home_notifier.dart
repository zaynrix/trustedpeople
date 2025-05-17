import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:riverpod/riverpod.dart';
import 'package:trustedtallentsvalley/app/config/firebase_constant.dart';
import 'package:trustedtallentsvalley/fetures/Home/models/user_model.dart';

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

// Enhanced HomeNotifier with additional methods
class HomeNotifier extends StateNotifier<HomeState> {
  final FirebaseFirestore _firestore;

  HomeNotifier(this._firestore) : super(HomeState());

  // Get user data from Firestore
  Future<void> getGoalData() async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      DocumentSnapshot doc = await _firestore
          .collection(FirebaseConstants.trustedUsers)
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

  // Add new user to Firestore
  Future<bool> addUser({
    required String aliasName,
    required String mobileNumber,
    required String location,
    required bool isTrusted,
    String? servicesProvided,
    String? telegramAccount,
    String? otherAccounts,
    String? reviews,
  }) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      // Generate a new document ID
      final docRef = _firestore.collection(FirebaseConstants.trustedUsers).doc();

      await docRef.set({
        'id': docRef.id,
        'aliasName': aliasName,
        'mobileNumber': mobileNumber,
        'location': location,
        'isTrusted': isTrusted,
        'servicesProvided': servicesProvided ?? '',
        'telegramAccount': telegramAccount ?? '',
        'otherAccounts': otherAccounts ?? '',
        'reviews': reviews ?? '',
        'createdAt': FieldValue.serverTimestamp(),
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

  // Update existing user in Firestore
  Future<bool> updateUser({
    required String id,
    String? aliasName,
    String? mobileNumber,
    String? location,
    bool? isTrusted,
    String? servicesProvided,
    String? telegramAccount,
    String? otherAccounts,
    String? reviews,
  }) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      final Map<String, dynamic> updateData = {};

      if (aliasName != null) updateData['aliasName'] = aliasName;
      if (mobileNumber != null) updateData['mobileNumber'] = mobileNumber;
      if (location != null) updateData['location'] = location;
      if (isTrusted != null) updateData['isTrusted'] = isTrusted;
      if (servicesProvided != null) updateData['servicesProvided'] = servicesProvided;
      if (telegramAccount != null) updateData['telegramAccount'] = telegramAccount;
      if (otherAccounts != null) updateData['otherAccounts'] = otherAccounts;
      if (reviews != null) updateData['reviews'] = reviews;

      updateData['updatedAt'] = FieldValue.serverTimestamp();

      await _firestore.collection(FirebaseConstants.trustedUsers).doc(id).update(updateData);

      // If we're updating the currently selected user, update it in the state
      if (state.selectedUser?.id == id) {
        // Fetch the updated user data
        DocumentSnapshot doc = await _firestore
            .collection(FirebaseConstants.trustedUsers)
            .doc(id)
            .get();

        state = state.copyWith(
          selectedUser: UserModel.fromFirestore(doc),
          isLoading: false,
        );
      } else {
        state = state.copyWith(isLoading: false);
      }

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

      await _firestore.collection(FirebaseConstants.trustedUsers).doc(id).delete();

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
      .collection(FirebaseConstants.trustedUsers)
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

// Stream provider for trusted users
final trustedUsersStreamProvider = StreamProvider<QuerySnapshot>((ref) {
  return FirebaseFirestore.instance
      .collection(FirebaseConstants.trustedUsers)
      .where("isTrusted", isEqualTo: true)
      .snapshots();
});

// Stream provider for untrusted users
final untrustedUsersStreamProvider = StreamProvider<QuerySnapshot>((ref) {
  return FirebaseFirestore.instance
      .collection(FirebaseConstants.trustedUsers)
      .where("isTrusted", isEqualTo: false)
      .snapshots();
});

// Stream provider for all users
final allUsersStreamProvider = StreamProvider<QuerySnapshot>((ref) {
  return FirebaseFirestore.instance
      .collection(FirebaseConstants.trustedUsers)
      .snapshots();
});