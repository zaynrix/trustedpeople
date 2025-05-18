// lib/features/user/payment_places/presentation/providers/payment_places_provider.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trustedtallentsvalley/features/admin/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:trustedtallentsvalley/features/user/payment_places/data/datasources/payment_places_remote_datasource.dart';
import 'package:trustedtallentsvalley/features/user/payment_places/data/repositories/home_repository_impl.dart';
import 'package:trustedtallentsvalley/features/user/payment_places/domain/entities/payment_place.dart';
import 'package:trustedtallentsvalley/features/user/payment_places/domain/repositories/payment_places_repository.dart';
import 'package:trustedtallentsvalley/features/user/payment_places/domain/usecases/crud_payment_place_usecase.dart';
import 'package:trustedtallentsvalley/features/user/payment_places/domain/usecases/get_categories_usecase.dart';
import 'package:trustedtallentsvalley/features/user/payment_places/domain/usecases/get_payment_places_usecase.dart';

enum PlacesFilterMode { all, highRated, category, byLocation }

class PaymentPlacesState {
  final bool showSideBar;
  final PaymentPlace? selectedPlace;
  final String searchQuery;
  final int currentPage;
  final int pageSize;
  final String sortField;
  final bool sortAscending;
  final PlacesFilterMode filterMode;
  final String? categoryFilter;
  final String? locationFilter;
  final bool isLoading;
  final String? errorMessage;

  PaymentPlacesState({
    this.showSideBar = false,
    this.selectedPlace,
    this.searchQuery = '',
    this.currentPage = 1,
    this.pageSize = 10,
    this.sortField = 'name',
    this.sortAscending = true,
    this.filterMode = PlacesFilterMode.all,
    this.categoryFilter,
    this.locationFilter,
    this.isLoading = false,
    this.errorMessage,
  });

  PaymentPlacesState copyWith({
    bool? showSideBar,
    PaymentPlace? selectedPlace,
    String? searchQuery,
    int? currentPage,
    int? pageSize,
    String? sortField,
    bool? sortAscending,
    PlacesFilterMode? filterMode,
    String? categoryFilter,
    String? locationFilter,
    bool? isLoading,
    String? errorMessage,
  }) {
    return PaymentPlacesState(
      showSideBar: showSideBar ?? this.showSideBar,
      selectedPlace: selectedPlace ?? this.selectedPlace,
      searchQuery: searchQuery ?? this.searchQuery,
      currentPage: currentPage ?? this.currentPage,
      pageSize: pageSize ?? this.pageSize,
      sortField: sortField ?? this.sortField,
      sortAscending: sortAscending ?? this.sortAscending,
      filterMode: filterMode ?? this.filterMode,
      categoryFilter: categoryFilter ?? this.categoryFilter,
      locationFilter: locationFilter ?? this.locationFilter,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

// Datasource provider
final paymentPlacesDatasourceProvider =
    Provider<PaymentPlacesRemoteDatasource>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return PaymentPlacesRemoteDatasource(firestore: firestore);
});

// Repository provider
final paymentPlacesRepositoryProvider =
    Provider<PaymentPlacesRepository>((ref) {
  final datasource = ref.watch(paymentPlacesDatasourceProvider);
  return PaymentPlacesRepositoryImpl(remoteDatasource: datasource);
});

// Use cases providers
final getAllPaymentPlacesUseCaseProvider =
    Provider<GetAllPaymentPlacesUseCase>((ref) {
  final repository = ref.watch(paymentPlacesRepositoryProvider);
  return GetAllPaymentPlacesUseCase(repository);
});

final getUniqueCategoriesUseCaseProvider =
    Provider<GetUniqueCategoriesUseCase>((ref) {
  final repository = ref.watch(paymentPlacesRepositoryProvider);
  return GetUniqueCategoriesUseCase(repository);
});

final addPaymentPlaceUseCaseProvider = Provider<AddPaymentPlaceUseCase>((ref) {
  final repository = ref.watch(paymentPlacesRepositoryProvider);
  return AddPaymentPlaceUseCase(repository);
});

final updatePaymentPlaceUseCaseProvider =
    Provider<UpdatePaymentPlaceUseCase>((ref) {
  final repository = ref.watch(paymentPlacesRepositoryProvider);
  return UpdatePaymentPlaceUseCase(repository);
});

final deletePaymentPlaceUseCaseProvider =
    Provider<DeletePaymentPlaceUseCase>((ref) {
  final repository = ref.watch(paymentPlacesRepositoryProvider);
  return DeletePaymentPlaceUseCase(repository);
});

// Stream providers
final paymentPlacesStreamProvider = StreamProvider<List<PaymentPlace>>((ref) {
  final useCase = ref.watch(getAllPaymentPlacesUseCaseProvider);
  return useCase.execute();
});

final categoriesStreamProvider = StreamProvider<List<String>>((ref) {
  final useCase = ref.watch(getUniqueCategoriesUseCaseProvider);
  return useCase.execute();
});

// Main state provider
class PaymentPlacesNotifier extends StateNotifier<PaymentPlacesState> {
  final PaymentPlacesRepository _repository;

  PaymentPlacesNotifier(this._repository) : super(PaymentPlacesState());

  // Close/toggle sidebar
  void closeBar() {
    state = state.copyWith(showSideBar: !state.showSideBar);
  }

  // Toggle sidebar visibility based on selected place
  void selectPlace(PaymentPlace? place) {
    if (state.selectedPlace?.id == place?.id) {
      // Toggle sidebar if same place is selected
      state = state.copyWith(showSideBar: !state.showSideBar);
    } else {
      // Show sidebar and update selected place
      state = state.copyWith(
        showSideBar: true,
        selectedPlace: place,
      );
    }
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
  void setFilterMode(PlacesFilterMode mode) {
    state = state.copyWith(
      filterMode: mode,
      currentPage: 1, // Reset to first page when filter changes
    );
  }

  // Set category filter
  void setCategoryFilter(String? category) {
    state = state.copyWith(
      categoryFilter: category,
      filterMode: PlacesFilterMode.category,
      currentPage: 1, // Reset to first page when filter changes
    );
  }

  // Set location filter
  void setLocationFilter(String? location) {
    state = state.copyWith(
      locationFilter: location,
      filterMode: PlacesFilterMode.byLocation,
      currentPage: 1, // Reset to first page when filter changes
    );
  }

  // Add new payment place
  Future<bool> addPlace(PaymentPlace place) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      final success = await _repository.addPaymentPlace(place);
      state = state.copyWith(isLoading: false);
      return success;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Error adding place: $e',
      );
      debugPrint('Error adding place: $e');
      return false;
    }
  }

  // Update existing place
  Future<bool> updatePlace(PaymentPlace place) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      final success = await _repository.updatePaymentPlace(place);

      // If we're updating the currently selected place, update it in the state
      if (success && state.selectedPlace?.id == place.id) {
        state = state.copyWith(
          selectedPlace: place,
          isLoading: false,
        );
      } else {
        state = state.copyWith(isLoading: false);
      }

      return success;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Error updating place: $e',
      );
      debugPrint('Error updating place: $e');
      return false;
    }
  }

  // Delete place
  Future<bool> deletePlace(String id) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      final success = await _repository.deletePaymentPlace(id);

      // If we're deleting the currently selected place, clear it from the state
      if (success && state.selectedPlace?.id == id) {
        state = state.copyWith(
          selectedPlace: null,
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
        errorMessage: 'Error deleting place: $e',
      );
      debugPrint('Error deleting place: $e');
      return false;
    }
  }
}

// Main provider
final paymentPlacesProvider =
    StateNotifierProvider<PaymentPlacesNotifier, PaymentPlacesState>((ref) {
  final repository = ref.watch(paymentPlacesRepositoryProvider);
  return PaymentPlacesNotifier(repository);
});

// Helper providers
final showPlaceSideBarProvider = Provider<bool>((ref) {
  return ref.watch(paymentPlacesProvider).showSideBar;
});

final selectedPlaceProvider = Provider<PaymentPlace?>((ref) {
  return ref.watch(paymentPlacesProvider).selectedPlace;
});

final placesSearchQueryProvider = StateProvider<String>((ref) {
  return ref.watch(paymentPlacesProvider).searchQuery;
});
