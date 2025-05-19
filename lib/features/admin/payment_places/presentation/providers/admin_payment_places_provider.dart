import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:trustedtallentsvalley/features/admin/payment_places/data/models/admin_payment_place_model.dart';

import '../../data/datasources/admin_payment_places_remote_datasource.dart';
import '../../data/repositories/admin_payment_places_repository_impl.dart';
import '../../domain/entities/admin_payment_place.dart';
import '../../domain/repositories/admin_payment_places_repository.dart';
import '../../domain/usecases/add_payment_place_usecase.dart';
import '../../domain/usecases/delete_payment_place_usecase.dart';
import '../../domain/usecases/export_places_to_csv_usecase.dart';
import '../../domain/usecases/export_places_to_excel_usecase.dart';
import '../../domain/usecases/get_admin_payment_places_usecase.dart';
import '../../domain/usecases/get_categories_usecase.dart';
import '../../domain/usecases/get_locations_usecase.dart';
import '../../domain/usecases/update_payment_place_usecase.dart';
import '../../domain/usecases/update_verification_status_usecase.dart';
import 'admin_payment_places_state.dart';

// Provider for Firestore
final firebaseFirestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

// Provider for remote data source
final adminPaymentPlacesRemoteDataSourceProvider =
Provider<AdminPaymentPlacesRemoteDataSource>((ref) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  return AdminPaymentPlacesRemoteDataSourceImpl(firestore);
});

// Provider for repository
final adminPaymentPlacesRepositoryProvider =
Provider<AdminPaymentPlacesRepository>((ref) {
  final remoteDataSource = ref.watch(adminPaymentPlacesRemoteDataSourceProvider);
  return AdminPaymentPlacesRepositoryImpl(remoteDataSource);
});

// Providers for use cases
final getAdminPaymentPlacesUseCaseProvider =
Provider<GetAdminPaymentPlacesUseCase>((ref) {
  final repository = ref.watch(adminPaymentPlacesRepositoryProvider);
  return GetAdminPaymentPlacesUseCase(repository);
});

final addPaymentPlaceUseCaseProvider = Provider<AddPaymentPlaceUseCase>((ref) {
  final repository = ref.watch(adminPaymentPlacesRepositoryProvider);
  return AddPaymentPlaceUseCase(repository);
});

final updatePaymentPlaceUseCaseProvider =
Provider<UpdatePaymentPlaceUseCase>((ref) {
  final repository = ref.watch(adminPaymentPlacesRepositoryProvider);
  return UpdatePaymentPlaceUseCase(repository);
});

final deletePaymentPlaceUseCaseProvider =
Provider<DeletePaymentPlaceUseCase>((ref) {
  final repository = ref.watch(adminPaymentPlacesRepositoryProvider);
  return DeletePaymentPlaceUseCase(repository);
});

final getAdminCategoriesUseCaseProvider = Provider<GetCategoriesUseCase>((ref) {
  final repository = ref.watch(adminPaymentPlacesRepositoryProvider);
  return GetCategoriesUseCase(repository);
});

final getAdminLocationsUseCaseProvider = Provider<GetLocationsUseCase>((ref) {
  final repository = ref.watch(adminPaymentPlacesRepositoryProvider);
  return GetLocationsUseCase(repository);
});

final updateVerificationStatusUseCaseProvider =
Provider<UpdateVerificationStatusUseCase>((ref) {
  final repository = ref.watch(adminPaymentPlacesRepositoryProvider);
  return UpdateVerificationStatusUseCase(repository);
});

final exportPlacesToCSVUseCaseProvider =
Provider<ExportPlacesToCSVUseCase>((ref) {
  final repository = ref.watch(adminPaymentPlacesRepositoryProvider);
  return ExportPlacesToCSVUseCase(repository);
});

final exportPlacesToExcelUseCaseProvider =
Provider<ExportPlacesToExcelUseCase>((ref) {
  final repository = ref.watch(adminPaymentPlacesRepositoryProvider);
  return ExportPlacesToExcelUseCase(repository);
});

// Main state notifier
class AdminPaymentPlacesNotifier extends StateNotifier<AdminPaymentPlacesState> {
  final GetAdminPaymentPlacesUseCase _getPaymentPlacesUseCase;
  final AddPaymentPlaceUseCase _addPaymentPlaceUseCase;
  final UpdatePaymentPlaceUseCase _updatePaymentPlaceUseCase;
  final DeletePaymentPlaceUseCase _deletePaymentPlaceUseCase;
  final UpdateVerificationStatusUseCase _updateVerificationStatusUseCase;
  final ExportPlacesToCSVUseCase _exportPlacesToCSVUseCase;
  final ExportPlacesToExcelUseCase _exportPlacesToExcelUseCase;

  AdminPaymentPlacesNotifier({
    required GetAdminPaymentPlacesUseCase getPaymentPlacesUseCase,
    required AddPaymentPlaceUseCase addPaymentPlaceUseCase,
    required UpdatePaymentPlaceUseCase updatePaymentPlaceUseCase,
    required DeletePaymentPlaceUseCase deletePaymentPlaceUseCase,
    required UpdateVerificationStatusUseCase updateVerificationStatusUseCase,
    required ExportPlacesToCSVUseCase exportPlacesToCSVUseCase,
    required ExportPlacesToExcelUseCase exportPlacesToExcelUseCase,
  })  : _getPaymentPlacesUseCase = getPaymentPlacesUseCase,
        _addPaymentPlaceUseCase = addPaymentPlaceUseCase,
        _updatePaymentPlaceUseCase = updatePaymentPlaceUseCase,
        _deletePaymentPlaceUseCase = deletePaymentPlaceUseCase,
        _updateVerificationStatusUseCase = updateVerificationStatusUseCase,
        _exportPlacesToCSVUseCase = exportPlacesToCSVUseCase,
        _exportPlacesToExcelUseCase = exportPlacesToExcelUseCase,
        super(AdminPaymentPlacesState());

  // Toggle sidebar visibility
  void toggleSidebar() {
    state = state.copyWith(showSideBar: !state.showSideBar);
  }

  // Select a payment place
  void selectPlace(AdminPaymentPlace? place) {
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
  void setFilterMode(AdminPlacesFilterMode mode) {
    state = state.copyWith(
      filterMode: mode,
      currentPage: 1, // Reset to first page when filter changes
    );
  }

  // Set category filter
  void setCategoryFilter(String? category) {
    state = state.copyWith(
      categoryFilter: category,
      filterMode: AdminPlacesFilterMode.category,
      currentPage: 1, // Reset to first page when filter changes
    );
  }

  // Set location filter
  void setLocationFilter(String? location) {
    state = state.copyWith(
      locationFilter: location,
      filterMode: AdminPlacesFilterMode.byLocation,
      currentPage: 1, // Reset to first page when filter changes
    );
  }


  // Close sidebar
  void closeBar() {
    state = state.copyWith(showSideBar: false);
  }

  // Add new payment place
  Future<bool> addPlace(AdminPaymentPlace place) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      // Convert domain entity to data model
      final placeModel = AdminPaymentPlaceModel.fromEntity(place);

      await _addPaymentPlaceUseCase(placeModel);

      state = state.copyWith(isLoading: false);
      return true;
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
  Future<bool> updatePlace(AdminPaymentPlace place) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      // Convert domain entity to data model
      final placeModel = AdminPaymentPlaceModel.fromEntity(place);

      await _updatePaymentPlaceUseCase(placeModel);

      // If we're updating the currently selected place, update it in the state
      if (state.selectedPlace?.id == place.id) {
        state = state.copyWith(
          selectedPlace: place,
          isLoading: false,
        );
      } else {
        state = state.copyWith(isLoading: false);
      }

      return true;
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

      await _deletePaymentPlaceUseCase(id);

      // If we're deleting the currently selected place, clear it from the state
      if (state.selectedPlace?.id == id) {
        state = state.copyWith(
          selectedPlace: null,
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
        errorMessage: 'Error deleting place: $e',
      );
      debugPrint('Error deleting place: $e');
      return false;
    }
  }

  // Update verification status
  Future<bool> updateVerificationStatus(String id, bool isVerified) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      await _updateVerificationStatusUseCase(id, isVerified);

      // If we're updating the currently selected place, update its status
      if (state.selectedPlace?.id == id) {
        final updatedPlace = state.selectedPlace!;
        // In a real implementation, we'd properly create a new instance with updated values
        state = state.copyWith(
          selectedPlace: AdminPaymentPlace(
            id: updatedPlace.id,
            name: updatedPlace.name,
            phoneNumber: updatedPlace.phoneNumber,
            location: updatedPlace.location,
            category: updatedPlace.category,
            paymentMethods: updatedPlace.paymentMethods,
            workingHours: updatedPlace.workingHours,
            description: updatedPlace.description,
            imageUrl: updatedPlace.imageUrl,
            isVerified: isVerified,
            rating: updatedPlace.rating,
            reviewsCount: updatedPlace.reviewsCount,
          ),
          isLoading: false,
        );
      } else {
        state = state.copyWith(isLoading: false);
      }

      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Error updating verification status: $e',
      );
      debugPrint('Error updating verification status: $e');
      return false;
    }
  }

  // Export to CSV
  Future<String?> exportToCSV() async {
    try {
      state = state.copyWith(isExporting: true, errorMessage: null);

      final csvData = await _exportPlacesToCSVUseCase();

      state = state.copyWith(isExporting: false);
      return csvData;
    } catch (e) {
      state = state.copyWith(
        isExporting: false,
        errorMessage: 'Error exporting to CSV: $e',
      );
      debugPrint('Error exporting to CSV: $e');
      return null;
    }
  }

  // Export to Excel
  Future<String?> exportToExcel() async {
    try {
      state = state.copyWith(isExporting: true, errorMessage: null);

      final excelData = await _exportPlacesToExcelUseCase();

      state = state.copyWith(isExporting: false);
      return excelData;
    } catch (e) {
      state = state.copyWith(
        isExporting: false,
        errorMessage: 'Error exporting to Excel: $e',
      );
      debugPrint('Error exporting to Excel: $e');
      return null;
    }
  }
}

// Provider for AdminPaymentPlacesNotifier
final adminPaymentPlacesProvider =
StateNotifierProvider<AdminPaymentPlacesNotifier, AdminPaymentPlacesState>(
        (ref) {
      final getPaymentPlacesUseCase = ref.watch(getAdminPaymentPlacesUseCaseProvider);
      final addPaymentPlaceUseCase = ref.watch(addPaymentPlaceUseCaseProvider);
      final updatePaymentPlaceUseCase = ref.watch(updatePaymentPlaceUseCaseProvider);
      final deletePaymentPlaceUseCase = ref.watch(deletePaymentPlaceUseCaseProvider);
      final updateVerificationStatusUseCase =
      ref.watch(updateVerificationStatusUseCaseProvider);
      final exportPlacesToCSVUseCase = ref.watch(exportPlacesToCSVUseCaseProvider);
      final exportPlacesToExcelUseCase =
      ref.watch(exportPlacesToExcelUseCaseProvider);

      return AdminPaymentPlacesNotifier(
        getPaymentPlacesUseCase: getPaymentPlacesUseCase,
        addPaymentPlaceUseCase: addPaymentPlaceUseCase,
        updatePaymentPlaceUseCase: updatePaymentPlaceUseCase,
        deletePaymentPlaceUseCase: deletePaymentPlaceUseCase,
        updateVerificationStatusUseCase: updateVerificationStatusUseCase,
        exportPlacesToCSVUseCase: exportPlacesToCSVUseCase,
        exportPlacesToExcelUseCase: exportPlacesToExcelUseCase,
      );
    });

// Stream provider for all payment places
final adminPaymentPlacesStreamProvider =
StreamProvider<List<AdminPaymentPlace>>((ref) {
  final useCase = ref.watch(getAdminPaymentPlacesUseCaseProvider);
  return useCase();
});

// Provider to get all unique categories for filtering
final adminCategoriesProvider = StreamProvider<List<String>>((ref) {
  final useCase = ref.watch(getAdminCategoriesUseCaseProvider);
  return useCase();
});

// Provider to get all unique locations for filtering
final adminLocationsProvider = StreamProvider<List<String>>((ref) {
  final useCase = ref.watch(getAdminLocationsUseCaseProvider);
  return useCase();
});

// Individual providers for specific parts of the state
final adminShowSideBarProvider = Provider<bool>((ref) {
  return ref.watch(adminPaymentPlacesProvider).showSideBar;
});

final adminSelectedPlaceProvider = Provider<AdminPaymentPlace?>((ref) {
  return ref.watch(adminPaymentPlacesProvider).selectedPlace;
});

final adminSearchQueryProvider = StateProvider<String>((ref) {
  return ref.watch(adminPaymentPlacesProvider).searchQuery;
});

final adminCurrentPageProvider = StateProvider<int>((ref) {
  return ref.watch(adminPaymentPlacesProvider).currentPage;
});

final adminPageSizeProvider = StateProvider<int>((ref) {
  return ref.watch(adminPaymentPlacesProvider).pageSize;
});

final adminSortFieldProvider = StateProvider<String>((ref) {
  return ref.watch(adminPaymentPlacesProvider).sortField;
});

final adminSortDirectionProvider = StateProvider<bool>((ref) {
  return ref.watch(adminPaymentPlacesProvider).sortAscending;
});

final adminFilterModeProvider = StateProvider<AdminPlacesFilterMode>((ref) {
  return ref.watch(adminPaymentPlacesProvider).filterMode;
});

final adminIsLoadingProvider = Provider<bool>((ref) {
  return ref.watch(adminPaymentPlacesProvider).isLoading;
});

final adminIsExportingProvider = Provider<bool>((ref) {
  return ref.watch(adminPaymentPlacesProvider).isExporting;
});

final adminErrorMessageProvider = Provider<String?>((ref) {
  return ref.watch(adminPaymentPlacesProvider).errorMessage;
});