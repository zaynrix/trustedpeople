// lib/fetures/PaymentPlaces/providers/payment_places_provider.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trustedtallentsvalley/fetures/PaymentPlaces/models/payment_place_model.dart';

enum PlacesFilterMode { all, highRated, category, byLocation }

class PaymentPlacesState {
  final bool showSideBar;
  final PaymentPlaceModel? selectedPlace;
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
    PaymentPlaceModel? selectedPlace,
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
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class PaymentPlacesNotifier extends StateNotifier<PaymentPlacesState> {
  final FirebaseFirestore _firestore;

  PaymentPlacesNotifier(this._firestore) : super(PaymentPlacesState());

  // Close/toggle sidebar
  void closeBar() {
    state = state.copyWith(showSideBar: !state.showSideBar);
  }

  // Toggle sidebar visibility based on selected place
  void selectPlace(PaymentPlaceModel? place) {
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

  // Add new payment place to Firestore
  Future<bool> addPlace(PaymentPlaceModel place) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      // Generate a new document ID
      final docRef = _firestore.collection('paymentPlaces').doc();

      await docRef.set({
        ...place.toMap(),
        'id': docRef.id,
        'createdAt': FieldValue.serverTimestamp(),
      });

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

  // Update existing place in Firestore
  Future<bool> updatePlace(PaymentPlaceModel place) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      await _firestore
          .collection('paymentPlaces')
          .doc(place.id)
          .update(place.toMap());

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

  // Delete place from Firestore
  Future<bool> deletePlace(String id) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      await _firestore.collection('paymentPlaces').doc(id).delete();

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
}

// Firebase provider
final firebaseFirestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

// Main provider for PaymentPlacesState
final paymentPlacesProvider =
    StateNotifierProvider<PaymentPlacesNotifier, PaymentPlacesState>((ref) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  return PaymentPlacesNotifier(firestore);
});

// Individual providers for specific parts of the state
final showPlaceSideBarProvider = Provider<bool>((ref) {
  return ref.watch(paymentPlacesProvider).showSideBar;
});

final selectedPlaceProvider = Provider<PaymentPlaceModel?>((ref) {
  return ref.watch(paymentPlacesProvider).selectedPlace;
});

final placesSearchQueryProvider = StateProvider<String>((ref) {
  return ref.watch(paymentPlacesProvider).searchQuery;
});

final placesCurrentPageProvider = StateProvider<int>((ref) {
  return ref.watch(paymentPlacesProvider).currentPage;
});

final placesPageSizeProvider = StateProvider<int>((ref) {
  return ref.watch(paymentPlacesProvider).pageSize;
});

final placesSortFieldProvider = StateProvider<String>((ref) {
  return ref.watch(paymentPlacesProvider).sortField;
});

final placesSortDirectionProvider = StateProvider<bool>((ref) {
  return ref.watch(paymentPlacesProvider).sortAscending;
});

final placesFilterModeProvider = StateProvider<PlacesFilterMode>((ref) {
  return ref.watch(paymentPlacesProvider).filterMode;
});

final placesIsLoadingProvider = Provider<bool>((ref) {
  return ref.watch(paymentPlacesProvider).isLoading;
});

final placesErrorMessageProvider = Provider<String?>((ref) {
  return ref.watch(paymentPlacesProvider).errorMessage;
});

// Stream provider for all payment places
final paymentPlacesStreamProvider = StreamProvider<QuerySnapshot>((ref) {
  return FirebaseFirestore.instance.collection('paymentPlaces').snapshots();
});

// Provider to get all unique categories for filtering
final placesCategoriesProvider = StreamProvider<List<String>>((ref) {
  return FirebaseFirestore.instance
      .collection('paymentPlaces')
      .snapshots()
      .map((snapshot) {
    final categories = snapshot.docs
        .map((doc) =>
            (doc.data() as Map<String, dynamic>)['category'] as String? ?? '')
        .where((category) => category.isNotEmpty)
        .toSet()
        .toList();
    categories.sort();
    return categories;
  });
});

// Provider to get all unique locations for filtering
final placesLocationsProvider = StreamProvider<List<String>>((ref) {
  return FirebaseFirestore.instance
      .collection('paymentPlaces')
      .snapshots()
      .map((snapshot) {
    final locations = snapshot.docs
        .map((doc) =>
            (doc.data() as Map<String, dynamic>)['location'] as String? ?? '')
        .where((location) => location.isNotEmpty)
        .toSet()
        .toList();
    locations.sort();
    return locations;
  });
});
