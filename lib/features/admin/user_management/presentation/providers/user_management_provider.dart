// lib/features/admin/user_management/presentation/providers/user_management_provider.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trustedtallentsvalley/features/admin/dashboard/domain/entities/managed_user.dart';
import 'package:trustedtallentsvalley/features/admin/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:trustedtallentsvalley/features/admin/user_management/data/datasources/user_management_remote_datasource.dart';
import 'package:trustedtallentsvalley/features/admin/user_management/data/repositories/user_management_repository_impl.dart';
import 'package:trustedtallentsvalley/features/admin/user_management/domain/repositories/user_management_repository.dart';
import 'package:trustedtallentsvalley/features/admin/user_management/domain/usecases/crud_user_usecase.dart';
import 'package:trustedtallentsvalley/features/admin/user_management/domain/usecases/get_trusted_users_usecase.dart';
import 'package:trustedtallentsvalley/features/admin/user_management/domain/usecases/get_untrusted_users_usecase.dart';

// Define filter modes
enum FilterMode { all, withReviews, withoutTelegram, byLocation }

// Enhanced UserManagementState class with more properties
class UserManagementState {
  final bool showSideBar;
  final ManagedUser? selectedUser;
  final String searchQuery;
  final int currentPage;
  final int pageSize;
  final String sortField;
  final bool sortAscending;
  final FilterMode filterMode;
  final String? locationFilter;
  final bool isLoading;
  final String? errorMessage;

  UserManagementState({
    this.showSideBar = false,
    this.selectedUser,
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
  UserManagementState copyWith({
    bool? showSideBar,
    ManagedUser? selectedUser,
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
    return UserManagementState(
      showSideBar: showSideBar ?? this.showSideBar,
      selectedUser: selectedUser ?? this.selectedUser,
      searchQuery: searchQuery ?? this.searchQuery,
      currentPage: currentPage ?? this.currentPage,
      pageSize: pageSize ?? this.pageSize,
      sortField: sortField ?? this.sortField,
      sortAscending: sortAscending ?? this.sortAscending,
      filterMode: filterMode ?? this.filterMode,
      locationFilter: locationFilter ?? this.locationFilter,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

// Datasource provider
final userManagementDatasourceProvider =
    Provider<UserManagementRemoteDatasource>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return UserManagementRemoteDatasource(firestore: firestore);
});

// Repository provider
final userManagementRepositoryProvider =
    Provider<UserManagementRepository>((ref) {
  final datasource = ref.watch(userManagementDatasourceProvider);
  return UserManagementRepositoryImpl(remoteDatasource: datasource);
});

// Use cases providers
final getTrustedUsersUseCaseProvider = Provider<GetTrustedUsersUseCase>((ref) {
  final repository = ref.watch(userManagementRepositoryProvider);
  return GetTrustedUsersUseCase(repository);
});

final getUntrustedUsersUseCaseProvider =
    Provider<GetUntrustedUsersUseCase>((ref) {
  final repository = ref.watch(userManagementRepositoryProvider);
  return GetUntrustedUsersUseCase(repository);
});

final addUserUseCaseProvider = Provider<AddUserUseCase>((ref) {
  final repository = ref.watch(userManagementRepositoryProvider);
  return AddUserUseCase(repository);
});

final updateUserUseCaseProvider = Provider<UpdateUserUseCase>((ref) {
  final repository = ref.watch(userManagementRepositoryProvider);
  return UpdateUserUseCase(repository);
});

final deleteUserUseCaseProvider = Provider<DeleteUserUseCase>((ref) {
  final repository = ref.watch(userManagementRepositoryProvider);
  return DeleteUserUseCase(repository);
});

final getUserByIdUseCaseProvider = Provider<GetUserByIdUseCase>((ref) {
  final repository = ref.watch(userManagementRepositoryProvider);
  return GetUserByIdUseCase(repository);
});

// Stream providers
final trustedUsersStreamProvider = StreamProvider<List<ManagedUser>>((ref) {
  final useCase = ref.watch(getTrustedUsersUseCaseProvider);
  return useCase.execute();
});

final untrustedUsersStreamProvider = StreamProvider<List<ManagedUser>>((ref) {
  final useCase = ref.watch(getUntrustedUsersUseCaseProvider);
  return useCase.execute();
});

// Main state provider
class UserManagementNotifier extends StateNotifier<UserManagementState> {
  final UserManagementRepository _repository;

  UserManagementNotifier(this._repository) : super(UserManagementState());

  // Close/toggle sidebar
  void closeBar() {
    state = state.copyWith(showSideBar: !state.showSideBar);
  }

  // Toggle sidebar visibility based on selected user
  void visibleBar({ManagedUser? selected}) {
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
  ManagedUser? getUser() {
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

      final newUser = ManagedUser(
        id: '',
        aliasName: aliasName,
        mobileNumber: mobileNumber,
        location: location,
        isTrusted: isTrusted,
        servicesProvided: servicesProvided ?? '',
        telegramAccount: telegramAccount ?? '',
        otherAccounts: otherAccounts ?? '',
        reviews: reviews ?? '',
      );

      final success = await _repository.addUser(newUser);
      state = state.copyWith(isLoading: false);
      return success;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Error adding user: $e',
      );
      debugPrint('Error adding user: $e');
      return false;
    }
  }

  // Update existing user
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

      // Get current user if available
      final currentUser =
          state.selectedUser ?? await _repository.getUserById(id);

      if (currentUser == null) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'User not found: $id',
        );
        return false;
      }

      // Create updated user
      final updatedUser = currentUser.copyWith(
        aliasName: aliasName,
        mobileNumber: mobileNumber,
        location: location,
        isTrusted: isTrusted,
        servicesProvided: servicesProvided,
        telegramAccount: telegramAccount,
        otherAccounts: otherAccounts,
        reviews: reviews,
      );

      final success = await _repository.updateUser(updatedUser);

      // Update selected user in state if it was updated
      if (success && state.selectedUser?.id == id) {
        state = state.copyWith(
          selectedUser: updatedUser,
          isLoading: false,
        );
      } else {
        state = state.copyWith(isLoading: false);
      }

      return success;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Error updating user: $e',
      );
      debugPrint('Error updating user: $e');
      return false;
    }
  }

  // Delete user
  Future<bool> deleteUser(String id) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      final success = await _repository.deleteUser(id);

      // If we're deleting the currently selected user, clear it from the state
      if (success && state.selectedUser?.id == id) {
        state = state.copyWith(
          selectedUser: null,
          showSideBar: false,
          isLoading: false,
        );
      } else {
        state = state.copyWith(isLoading: false);
      }

      return success;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Error deleting user: $e',
      );
      debugPrint('Error deleting user: $e');
      return false;
    }
  }
}

// Main provider
final userManagementProvider =
    StateNotifierProvider<UserManagementNotifier, UserManagementState>((ref) {
  final repository = ref.watch(userManagementRepositoryProvider);
  return UserManagementNotifier(repository);
});

// Helper providers
final showSideBarProvider = Provider<bool>((ref) {
  return ref.watch(userManagementProvider).showSideBar;
});

final selectedUserProvider = Provider<ManagedUser?>((ref) {
  return ref.watch(userManagementProvider).selectedUser;
});

final searchQueryProvider = StateProvider<String>((ref) {
  return ref.watch(userManagementProvider).searchQuery;
});
