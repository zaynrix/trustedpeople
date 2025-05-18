// lib/services/providers/service_provider.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trustedtallentsvalley/services/service_model.dart';

// State class for services
class ServicesState {
  final bool isLoading;
  final String? errorMessage;
  final List<ServiceModel> services;
  final ServiceModel? selectedService;
  final String searchQuery;
  final String? categoryFilter;

  ServicesState({
    this.isLoading = false,
    this.errorMessage,
    this.services = const [],
    this.selectedService,
    this.searchQuery = '',
    this.categoryFilter,
  });

  ServicesState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<ServiceModel>? services,
    ServiceModel? selectedService,
    String? searchQuery,
    String? categoryFilter,
  }) {
    return ServicesState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      services: services ?? this.services,
      selectedService: selectedService ?? this.selectedService,
      searchQuery: searchQuery ?? this.searchQuery,
      categoryFilter: categoryFilter ?? this.categoryFilter,
    );
  }
}

// Services notifier to manage state
class ServicesNotifier extends StateNotifier<ServicesState> {
  final FirebaseFirestore _firestore;

  ServicesNotifier(this._firestore) : super(ServicesState()) {
    loadServices();
  }
  Stream<List<ServiceModel>> getActiveServicesStream() {
    return _firestore
        .collection('services')
        .where('status', isEqualTo: 'active')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ServiceModel.fromFirestore(doc))
            .toList());
  }

  // Load all active services
  Future<void> loadServices() async {
    try {
      debugPrint('Loading services...');
      state = state.copyWith(isLoading: true, errorMessage: null);

      final snapshot = await _firestore
          .collection('services')
          .orderBy('createdAt', descending: true)
          .get();

      debugPrint('Services fetched: ${snapshot.docs.length}');

      final services =
          snapshot.docs.map((doc) => ServiceModel.fromFirestore(doc)).toList();

      state = state.copyWith(
        services: services,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load services: $e',
      );
      debugPrint('Error loading services: $e');
    }
  }

  // Select a service
  void selectService(ServiceModel service) {
    state = state.copyWith(selectedService: service);
  }

  // Clear selected service
  void clearSelectedService() {
    state = state.copyWith(selectedService: null);
  }

  // Set search query
  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  // Set category filter
  void setCategoryFilter(String? category) {
    state = state.copyWith(categoryFilter: category);
  }

  // Add a new service (admin only)
  Future<bool> addService(ServiceModel service) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      final docRef = _firestore.collection('services').doc();
      final newService = service.copyWith(
        id: docRef.id,
        createdAt: Timestamp.now().toDate(),
      );

      await docRef.set(newService.toMap());

      // Refresh services list
      await loadServices();

      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to add service: $e',
      );
      debugPrint('Error adding service: $e');
      return false;
    }
  }

  // Update a service (admin only)
  Future<bool> updateService(ServiceModel service) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      final updatedService = service.copyWith(
        createdAt: Timestamp.now().toDate(),
      );

      await _firestore
          .collection('services')
          .doc(service.id)
          .update(updatedService.toMap());

      // Refresh services list
      await loadServices();

      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to update service: $e',
      );
      debugPrint('Error updating service: $e');
      return false;
    }
  }

  // Delete a service (admin only)
  Future<bool> deleteService(String serviceId) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      // Soft delete by changing status
      await _firestore.collection('services').doc(serviceId).update({
        'status': 'deleted',
        'updatedAt': Timestamp.now(),
      });

      // Refresh services list
      await loadServices();

      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to delete service: $e',
      );
      debugPrint('Error deleting service: $e');
      return false;
    }
  }

  // Get filtered services
  List<ServiceModel> getFilteredServices() {
    final query = state.searchQuery.toLowerCase();
    final categoryFilter = state.categoryFilter;

    return state.services.where((service) {
      final matchesQuery = query.isEmpty ||
          service.title.toLowerCase().contains(query) ||
          service.description.toLowerCase().contains(query);

      final matchesCategory = categoryFilter == null ||
          service.category.toString().split('.').last == categoryFilter;

      return matchesQuery && matchesCategory;
    }).toList();
  }
}

// Provider for Firestore
final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

// Provider for services state
final servicesProvider =
    StateNotifierProvider<ServicesNotifier, ServicesState>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return ServicesNotifier(firestore);
});

// Provider for service categories
final serviceCategoriesProvider = FutureProvider<List<String>>((ref) async {
  final firestore = FirebaseFirestore.instance;
  final snapshot = await firestore
      .collection('services')
      .where('status', isEqualTo: 'active')
      .get();

  final categories = snapshot.docs
      .map((doc) => (doc.data()['category'] as String?) ?? '')
      .where((category) => category.isNotEmpty)
      .toSet()
      .toList();

  categories.sort();
  return categories;
});

// Stream provider for all active services
final servicesStreamProvider = StreamProvider<List<ServiceModel>>((ref) {
  return FirebaseFirestore.instance
      .collection('services')
      // .where('status', isEqualTo: 'active')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) =>
          snapshot.docs.map((doc) => ServiceModel.fromFirestore(doc)).toList());
});

// Stream provider for all services including inactive ones
final allServicesStreamProvider = StreamProvider<List<ServiceModel>>((ref) {
  return FirebaseFirestore.instance
      .collection('services')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) =>
          snapshot.docs.map((doc) => ServiceModel.fromFirestore(doc)).toList());
});

// Provider for filtered services based on search and category filters
final filteredServicesProvider = Provider<List<ServiceModel>>((ref) {
  return ref.read(servicesProvider.notifier).getFilteredServices();
});
