// Presentation Layer - User Providers
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:trustedtallentsvalley/fetures/trusted/data/user_remote_data_source.dart';
import 'package:trustedtallentsvalley/fetures/trusted/data/user_repository_iImplementation.dart';
import 'package:trustedtallentsvalley/fetures/trusted/domain/use_cases.dart';
import 'package:trustedtallentsvalley/fetures/trusted/domain/user_entity.dart';

// Filter modes
enum FilterMode { all, withReviews, withoutTelegram, byLocation }

// Create dependencies
final firebaseFirestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final userRemoteDataSourceProvider = Provider<UserRemoteDataSource>((ref) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  return UserRemoteDataSource(firestore: firestore);
});

final userRepositoryProvider = Provider((ref) {
  final dataSource = ref.watch(userRemoteDataSourceProvider);
  return UserRepositoryImpl(dataSource: dataSource);
});

// Use cases
final getTrustedUsersProvider = Provider((ref) {
  final repository = ref.watch(userRepositoryProvider);
  return GetTrustedUsers(repository);
});

final getUntrustedUsersProvider = Provider((ref) {
  final repository = ref.watch(userRepositoryProvider);
  return GetUntrustedUsers(repository);
});

final getAllUsersProvider = Provider((ref) {
  final repository = ref.watch(userRepositoryProvider);
  return GetAllUsers(repository);
});

final getLocationsProvider = Provider((ref) {
  final repository = ref.watch(userRepositoryProvider);
  return GetLocations(repository);
});

final addUserProvider = Provider((ref) {
  final repository = ref.watch(userRepositoryProvider);
  return AddUser(repository);
});

final updateUserProvider = Provider((ref) {
  final repository = ref.watch(userRepositoryProvider);
  return UpdateUser(repository);
});

final deleteUserProvider = Provider((ref) {
  final repository = ref.watch(userRepositoryProvider);
  return DeleteUser(repository);
});

// Stream providers
final trustedUsersStreamProvider = StreamProvider<List<User>>((ref) {
  final getTrustedUsers = ref.watch(getTrustedUsersProvider);
  return getTrustedUsers();
});

final untrustedUsersStreamProvider = StreamProvider<List<User>>((ref) {
  final getUntrustedUsers = ref.watch(getUntrustedUsersProvider);
  return getUntrustedUsers();
});

final allUsersStreamProvider = StreamProvider<List<User>>((ref) {
  final getAllUsers = ref.watch(getAllUsersProvider);
  return getAllUsers();
});

final locationsStreamProvider = StreamProvider<List<String>>((ref) {
  final getLocations = ref.watch(getLocationsProvider);
  return getLocations();
});

// UI State Providers
// These providers help manage the UI state without the need for a complex state class

// Search query
final searchQueryProvider = StateProvider<String>((ref) => '');

// Pagination
final currentPageProvider = StateProvider<int>((ref) => 1);
final pageSizeProvider = StateProvider<int>((ref) => 10);

// Sorting
final sortFieldProvider = StateProvider<String>((ref) => 'aliasName');
final sortDirectionProvider = StateProvider<bool>((ref) => true); // true = ascending

// Filtering
final filterModeProvider = StateProvider<FilterMode>((ref) => FilterMode.all);
final locationFilterProvider = StateProvider<String?>((ref) => null);

// Selected user and sidebar
final selectedUserProvider = StateProvider<User?>((ref) => null);
final showSideBarProvider = StateProvider<bool>((ref) => false);

// Loading state
final isLoadingProvider = StateProvider<bool>((ref) => false);
final errorMessageProvider = StateProvider<String?>((ref) => null);

// Admin status (for simplicity, could be integrated with auth)
final isAdminProvider = StateProvider<bool>((ref) => true);

// Helper provider for filtered users
final filteredUsersProvider = Provider<List<User>>((ref) {
  final users = ref.watch(trustedUsersStreamProvider).maybeWhen(
    data: (users) => users,
    orElse: () => <User>[],
  );

  final searchQuery = ref.watch(searchQueryProvider);
  final filterMode = ref.watch(filterModeProvider);
  final locationFilter = ref.watch(locationFilterProvider);
  final sortField = ref.watch(sortFieldProvider);
  final sortAscending = ref.watch(sortDirectionProvider);

  // Filter
  var filteredUsers = users.where((user) {
    // Apply search filter
    final aliasName = user.aliasName.toLowerCase();
    final mobileNumber = user.mobileNumber;
    final location = user.location.toLowerCase();
    final services = user.servicesProvided.toLowerCase();
    final query = searchQuery.toLowerCase();

    bool matchesSearch = query.isEmpty ||
        aliasName.contains(query) ||
        mobileNumber.contains(query) ||
        location.contains(query) ||
        services.contains(query);

    // Apply additional filters based on filter mode
    switch (filterMode) {
      case FilterMode.all:
        return matchesSearch;
      case FilterMode.withReviews:
        final hasReviews = user.reviews.isNotEmpty;
        return matchesSearch && hasReviews;
      case FilterMode.withoutTelegram:
        final noTelegram = user.telegramAccount.isEmpty;
        return matchesSearch && noTelegram;
      case FilterMode.byLocation:
      // Location-specific filtering
        if (locationFilter == null || locationFilter.isEmpty) {
          return matchesSearch;
        }
        return matchesSearch && location.contains(locationFilter.toLowerCase());
    }
  }).toList();

  // Sort
  filteredUsers.sort((a, b) {
    String aValue = '';
    String bValue = '';

    switch (sortField) {
      case 'aliasName':
        aValue = a.aliasName;
        bValue = b.aliasName;
        break;
      case 'mobileNumber':
        aValue = a.mobileNumber;
        bValue = b.mobileNumber;
        break;
      case 'location':
        aValue = a.location;
        bValue = b.location;
        break;
      case 'reviews':
        aValue = a.reviews;
        bValue = b.reviews;
        break;
      default:
        aValue = a.aliasName;
        bValue = b.aliasName;
    }

    return sortAscending ? aValue.compareTo(bValue) : bValue.compareTo(aValue);
  });

  return filteredUsers;
});

// Helper provider for paginated users
final paginatedUsersProvider = Provider<List<User>>((ref) {
  final filteredUsers = ref.watch(filteredUsersProvider);
  final currentPage = ref.watch(currentPageProvider);
  final pageSize = ref.watch(pageSizeProvider);

  final startIndex = (currentPage - 1) * pageSize;
  final endIndex = startIndex + pageSize < filteredUsers.length
      ? startIndex + pageSize
      : filteredUsers.length;

  if (startIndex >= filteredUsers.length) {
    return [];
  }

  return filteredUsers.sublist(startIndex, endIndex);
});

