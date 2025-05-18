// import 'package:flutter/foundation.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:trustedtallentsvalley/features/user/domain/entities/user.dart';
// import 'package:trustedtallentsvalley/features/user/domain/usecases/manage_users_usecases.dart';
//
// /// Enum for different filter modes
// enum FilterMode { all, withReviews, withoutTelegram, byLocation }
//
// /// State class for the user management feature
// class UserState {
//   final bool showSideBar;
//   final User? selectedUser;
//   final String searchQuery;
//   final int currentPage;
//   final int pageSize;
//   final String sortField;
//   final bool sortAscending;
//   final FilterMode filterMode;
//   final String? locationFilter;
//   final bool isLoading;
//   final String? errorMessage;
//
//   UserState({
//     this.showSideBar = false,
//     this.selectedUser,
//     this.searchQuery = '',
//     this.currentPage = 1,
//     this.pageSize = 10,
//     this.sortField = 'aliasName',
//     this.sortAscending = true,
//     this.filterMode = FilterMode.all,
//     this.locationFilter,
//     this.isLoading = false,
//     this.errorMessage,
//   });
//
//   UserState copyWith({
//     bool? showSideBar,
//     User? selectedUser,
//     String? searchQuery,
//     int? currentPage,
//     int? pageSize,
//     String? sortField,
//     bool? sortAscending,
//     FilterMode? filterMode,
//     String? locationFilter,
//     bool? isLoading,
//     String? errorMessage,
//   }) {
//     return UserState(
//       showSideBar: showSideBar ?? this.showSideBar,
//       selectedUser: selectedUser ?? this.selectedUser,
//       searchQuery: searchQuery ?? this.searchQuery,
//       currentPage: currentPage ?? this.currentPage,
//       pageSize: pageSize ?? this.pageSize,
//       sortField: sortField ?? this.sortField,
//       sortAscending: sortAscending ?? this.sortAscending,
//       filterMode: filterMode ?? this.filterMode,
//       locationFilter: locationFilter ?? this.locationFilter,
//       isLoading: isLoading ?? this.isLoading,
//       errorMessage: errorMessage != null ? errorMessage : this.errorMessage,
//     );
//   }
// }
//
// /// StateNotifier for user management
// class UserNotifier extends StateNotifier<UserState> {
//   final AddUserUseCase _addUserUseCase;
//   final UpdateUserUseCase _updateUserUseCase;
//   final DeleteUserUseCase _deleteUserUseCase;
//
//   UserNotifier({
//     required AddUserUseCase addUserUseCase,
//     required UpdateUserUseCase updateUserUseCase,
//     required DeleteUserUseCase deleteUserUseCase,
//   })  : _addUserUseCase = addUserUseCase,
//         _updateUserUseCase = updateUserUseCase,
//         _deleteUserUseCase = deleteUserUseCase,
//         super(UserState());
//
//   /// Toggle the sidebar
//   void toggleSidebar() {
//     state = state.copyWith(showSideBar: !state.showSideBar);
//   }
//
//   /// Close the sidebar
//   void closeSidebar() {
//     state = state.copyWith(showSideBar: false);
//   }
//
//   /// Select a user and show sidebar
//   void selectUser(User? user) {
//     if (state.selectedUser?.id == user?.id) {
//       // Toggle sidebar if the same user is selected again
//       state = state.copyWith(showSideBar: !state.showSideBar);
//     } else {
//       // Show sidebar with the new selected user
//       state = state.copyWith(
//         selectedUser: user,
//         showSideBar: true,
//       );
//     }
//   }
//
//   /// Set search query
//   void setSearchQuery(String query) {
//     state = state.copyWith(
//       searchQuery: query,
//       currentPage: 1, // Reset to first page on search change
//     );
//   }
//
//   /// Set current page for pagination
//   void setCurrentPage(int page) {
//     state = state.copyWith(currentPage: page);
//   }
//
//   /// Set page size for pagination
//   void setPageSize(int size) {
//     state = state.copyWith(
//       pageSize: size,
//       currentPage: 1, // Reset to first page on page size change
//     );
//   }
//
//   /// Set sort field and direction
//   void setSort(String field, {bool? ascending}) {
//     if (field == state.sortField && ascending == null) {
//       // Toggle direction if same field
//       state = state.copyWith(sortAscending: !state.sortAscending);
//     } else {
//       state = state.copyWith(
//         sortField: field,
//         sortAscending: ascending ?? true,
//       );
//     }
//   }
//
//   /// Set filter mode
//   void setFilterMode(FilterMode mode) {
//     state = state.copyWith(
//       filterMode: mode,
//       currentPage: 1, // Reset to first page on filter change
//     );
//   }
//
//   /// Set location filter
//   void setLocationFilter(String? location) {
//     state = state.copyWith(
//       locationFilter: location,
//       filterMode: FilterMode.byLocation,
//       currentPage: 1, // Reset to first page when filter changes
//     );
//   }
//
//   /// Add new user
//   Future<bool> addUser({
//     required String aliasName,
//     required String mobileNumber,
//     required String location,
//     required bool isTrusted,
//     String? servicesProvided,
//     String? telegramAccount,
//     String? otherAccounts,
//     String? reviews,
//   }) async {
//     try {
//       state = state.copyWith(isLoading: true, errorMessage: null);
//
//       final result = await _addUserUseCase(
//         aliasName: aliasName,
//         mobileNumber: mobileNumber,
//         location: location,
//         isTrusted: isTrusted,
//         servicesProvided: servicesProvided,
//         telegramAccount: telegramAccount,
//         otherAccounts: otherAccounts,
//         reviews: reviews,
//       );
//
//       state = state.copyWith(isLoading: false);
//       return result;
//     } catch (e) {
//       state = state.copyWith(
//         isLoading: false,
//         errorMessage: 'Error adding user: $e',
//       );
//       debugPrint('Error adding user: $e');
//       return false;
//     }
//   }
//
//   /// Update existing user
//   Future<bool> updateUser({
//     required String id,
//     String? aliasName,
//     String? mobileNumber,
//     String? location,
//     bool? isTrusted,
//     String? servicesProvided,
//     String? telegramAccount,
//     String? otherAccounts,
//     String? reviews,
//   }) async {
//     try {
//       state = state.copyWith(isLoading: true, errorMessage: null);
//
//       final result = await _updateUserUseCase(
//         id: id,
//         aliasName: aliasName,
//         mobileNumber: mobileNumber,
//         location: location,
//         isTrusted: isTrusted,
//         servicesProvided: servicesProvided,
//         telegramAccount: telegramAccount,
//         otherAccounts: otherAccounts,
//         reviews: reviews,
//       );
//
//       state = state.copyWith(isLoading: false);
//
//       // If we just updated the currently selected user, we need to refresh it
//       if (result && state.selectedUser?.id == id) {
//         // This would ideally fetch the updated user
//         // We'll implement this when we have the getUserById functionality
//       }
//
//       return result;
//     } catch (e) {
//       state = state.copyWith(
//         isLoading: false,
//         errorMessage: 'Error updating user: $e',
//       );
//       debugPrint('Error updating user: $e');
//       return false;
//     }
//   }
//
//   /// Delete user
//   Future<bool> deleteUser(String id) async {
//     try {
//       state = state.copyWith(isLoading: true, errorMessage: null);
//
//       final result = await _deleteUserUseCase(id);
//
//       // If we deleted the currently selected user, close the sidebar
//       if (result && state.selectedUser?.id == id) {
//         state = state.copyWith(
//           isLoading: false,
//           selectedUser: null,
//           showSideBar: false,
//         );
//       } else {
//         state = state.copyWith(isLoading: false);
//       }
//
//       return result;
//     } catch (e) {
//       state = state.copyWith(
//         isLoading: false,
//         errorMessage: 'Error deleting user: $e',
//       );
//       debugPrint('Error deleting user: $e');
//       return false;
//     }
//   }
// }
//
// /// Provider for UserState
// final userStateProvider = StateNotifierProvider<UserNotifier, UserState>((ref) {
//   final addUserUseCase = ref.watch(addUserUseCaseProvider);
//   final updateUserUseCase = ref.watch(updateUserUseCaseProvider);
//   final deleteUserUseCase = ref.watch(deleteUserUseCaseProvider);
//
//   return UserNotifier(
//     addUserUseCase: addUserUseCase,
//     updateUserUseCase: updateUserUseCase,
//     deleteUserUseCase: deleteUserUseCase,
//   );
// });
//
// // Utility providers for accessing specific parts of the state
// final showSideBarProvider = Provider<bool>((ref) {
//   return ref.watch(userStateProvider).showSideBar;
// });
//
// final selectedUserProvider = Provider<User?>((ref) {
//   return ref.watch(userStateProvider).selectedUser;
// });
//
// final searchQueryProvider = StateProvider<String>((ref) {
//   return ref.watch(userStateProvider).searchQuery;
// });
//
// final currentPageProvider = StateProvider<int>((ref) {
//   return ref.watch(userStateProvider).currentPage;
// });
//
// final pageSizeProvider = StateProvider<int>((ref) {
//   return ref.watch(userStateProvider).pageSize;
// });
//
// final sortFieldProvider = StateProvider<String>((ref) {
//   return ref.watch(userStateProvider).sortField;
// });
//
// final sortDirectionProvider = StateProvider<bool>((ref) {
//   return ref.watch(userStateProvider).sortAscending;
// });
//
// final filterModeProvider = StateProvider<FilterMode>((ref) {
//   return ref.watch(userStateProvider).filterMode;
// });
//
// final locationFilterProvider = StateProvider<String?>((ref) {
//   return ref.watch(userStateProvider).locationFilter;
// });
//
// final isLoadingProvider = Provider<bool>((ref) {
//   return ref.watch(userStateProvider).isLoading;
// });
//
// final errorMessageProvider = Provider<String?>((ref) {
//   return ref.watch(userStateProvider).errorMessage;
// });
