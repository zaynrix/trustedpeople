
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trustedtallentsvalley/fetures/trusted/domain/user_entity.dart';
import 'package:trustedtallentsvalley/fetures/trusted/presentation/providers/user_providers.dart';

class UserUIActions {
  final WidgetRef ref;

  UserUIActions(this.ref);

  void setSearchQuery(String query) {
    ref.read(searchQueryProvider.notifier).state = query;
    ref.read(currentPageProvider.notifier).state = 1; // Reset to first page
  }

  void setCurrentPage(int page) {
    ref.read(currentPageProvider.notifier).state = page;
  }

  void setPageSize(int size) {
    ref.read(pageSizeProvider.notifier).state = size;
    ref.read(currentPageProvider.notifier).state = 1; // Reset to first page
  }

  void setSort(String field, {bool? ascending}) {
    if (field == ref.read(sortFieldProvider) && ascending == null) {
      // Toggle direction if same field
      ref.read(sortDirectionProvider.notifier).state = !ref.read(sortDirectionProvider);
    } else {
      ref.read(sortFieldProvider.notifier).state = field;
      ref.read(sortDirectionProvider.notifier).state = ascending ?? true;
    }
  }

  void setFilterMode(FilterMode mode) {
    ref.read(filterModeProvider.notifier).state = mode;
    ref.read(currentPageProvider.notifier).state = 1; // Reset to first page
  }

  void setLocationFilter(String? location) {
    ref.read(locationFilterProvider.notifier).state = location;
    ref.read(filterModeProvider.notifier).state = FilterMode.byLocation;
    ref.read(currentPageProvider.notifier).state = 1; // Reset to first page
  }

  void selectUser(User? user) {
    final currentUser = ref.read(selectedUserProvider);

    if (currentUser == user) {
      // Toggle sidebar if same user is selected
      ref.read(showSideBarProvider.notifier).state = !ref.read(showSideBarProvider);
    } else {
      ref.read(selectedUserProvider.notifier).state = user;
      ref.read(showSideBarProvider.notifier).state = true;
    }
  }

  void closeSidebar() {
    ref.read(showSideBarProvider.notifier).state = false;
  }

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
      ref.read(isLoadingProvider.notifier).state = true;
      ref.read(errorMessageProvider.notifier).state = null;

      final user = User(
        id: '', // Will be set by Firestore
        aliasName: aliasName,
        mobileNumber: mobileNumber,
        location: location,
        isTrusted: isTrusted,
        servicesProvided: servicesProvided ?? '',
        telegramAccount: telegramAccount ?? '',
        otherAccounts: otherAccounts ?? '',
        reviews: reviews ?? '',
      );

      final addUser = ref.read(addUserProvider);
      await addUser(user);

      ref.read(isLoadingProvider.notifier).state = false;
      return true;
    } catch (e) {
      ref.read(isLoadingProvider.notifier).state = false;
      ref.read(errorMessageProvider.notifier).state = 'Error adding user: $e';
      return false;
    }
  }

  Future<bool> updateUser({
    required String id,
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
      ref.read(isLoadingProvider.notifier).state = true;
      ref.read(errorMessageProvider.notifier).state = null;

      final user = User(
        id: id,
        aliasName: aliasName,
        mobileNumber: mobileNumber,
        location: location,
        isTrusted: isTrusted,
        servicesProvided: servicesProvided ?? '',
        telegramAccount: telegramAccount ?? '',
        otherAccounts: otherAccounts ?? '',
        reviews: reviews ?? '',
      );

      final updateUser = ref.read(updateUserProvider);
      await updateUser(user);

      ref.read(isLoadingProvider.notifier).state = false;
      return true;
    } catch (e) {
      ref.read(isLoadingProvider.notifier).state = false;
      ref.read(errorMessageProvider.notifier).state = 'Error updating user: $e';
      return false;
    }
  }

  Future<bool> deleteUser(String id) async {
    try {
      ref.read(isLoadingProvider.notifier).state = true;
      ref.read(errorMessageProvider.notifier).state = null;

      final deleteUser = ref.read(deleteUserProvider);
      await deleteUser(id);

      // If we're deleting the currently selected user, clear it
      final selectedUser = ref.read(selectedUserProvider);
      if (selectedUser?.id == id) {
        ref.read(selectedUserProvider.notifier).state = null;
        ref.read(showSideBarProvider.notifier).state = false;
      }

      ref.read(isLoadingProvider.notifier).state = false;
      return true;
    } catch (e) {
      ref.read(isLoadingProvider.notifier).state = false;
      ref.read(errorMessageProvider.notifier).state = 'Error deleting user: $e';
      return false;
    }
  }

  Future<String?> exportData(String format) async {
    try {
      ref.read(isLoadingProvider.notifier).state = true;
      ref.read(errorMessageProvider.notifier).state = null;

      // This would be implemented with actual export logic
      // For now, it's just a placeholder
      await Future.delayed(const Duration(seconds: 1));

      ref.read(isLoadingProvider.notifier).state = false;
      return "Exported data.$format";
    } catch (e) {
      ref.read(isLoadingProvider.notifier).state = false;
      ref.read(errorMessageProvider.notifier).state = 'Error exporting data: $e';
      return null;
    }
  }
}

// Update the provider to use WidgetRef
final userUIActionsProvider = Provider<UserUIActions>((ref) {
  return UserUIActions(ref as WidgetRef);
});