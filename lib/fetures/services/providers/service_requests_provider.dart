// lib/fetures/services/providers/service_requests_provider.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trustedtallentsvalley/fetures/services/providers/service_provider.dart';
import 'package:trustedtallentsvalley/fetures/services/service_model.dart';

// State class for service requests
class ServiceRequestsState {
  final bool isLoading;
  final String? errorMessage;
  final List<ServiceRequestModel> requests;
  final ServiceRequestModel? selectedRequest;
  final int newRequestsCount;
  final bool showNewRequestsBadge;

  ServiceRequestsState({
    this.isLoading = false,
    this.errorMessage,
    this.requests = const [],
    this.selectedRequest,
    this.newRequestsCount = 0,
    this.showNewRequestsBadge = false,
  });

  ServiceRequestsState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<ServiceRequestModel>? requests,
    ServiceRequestModel? selectedRequest,
    int? newRequestsCount,
    bool? showNewRequestsBadge,
  }) {
    return ServiceRequestsState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      requests: requests ?? this.requests,
      selectedRequest: selectedRequest ?? this.selectedRequest,
      newRequestsCount: newRequestsCount ?? this.newRequestsCount,
      showNewRequestsBadge: showNewRequestsBadge ?? this.showNewRequestsBadge,
    );
  }
}

// Service requests notifier to manage state
class ServiceRequestsNotifier extends StateNotifier<ServiceRequestsState> {
  final FirebaseFirestore _firestore;

  ServiceRequestsNotifier(this._firestore) : super(ServiceRequestsState()) {
    loadRequests();
    _listenForNewRequests();
  }

  // Load all service requests
  Future<void> loadRequests() async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      final snapshot = await _firestore
          .collection('service_requests')
          .orderBy('createdAt', descending: true)
          .get();

      final requests = snapshot.docs
          .map((doc) => ServiceRequestModel.fromFirestore(doc))
          .toList();

      state = state.copyWith(
        requests: requests,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load service requests: $e',
      );
      debugPrint('Error loading service requests: $e');
    }
  }

  // Listen for new service requests
  void _listenForNewRequests() {
    _firestore
        .collection('service_requests')
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .listen((snapshot) {
      state = state.copyWith(
        newRequestsCount: snapshot.docs.length,
        showNewRequestsBadge: snapshot.docs.isNotEmpty,
      );
    });
  }

  Future<bool> createRequest(ServiceRequestModel request) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      final docRef = _firestore.collection('service_requests').doc();
      final newRequest = request.copyWith(
        id: docRef.id,
        createdAt: Timestamp.now(),
      );

      await docRef.set(newRequest.toMap());

      // Refresh requests list
      await loadRequests();

      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to create request: $e',
      );
      debugPrint('Error creating request: $e');
      return false;
    }
  }

  // Clear the notification badge
  void clearNewRequestsBadge() {
    state = state.copyWith(showNewRequestsBadge: false);
  }

  // Create a new service request
  Future<bool> createServiceRequest(ServiceRequestModel request) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      final docRef = _firestore.collection('service_requests').doc();
      final newRequest = request.copyWith(
        id: docRef.id,
      );

      await docRef.set(newRequest.toMap());

      await loadRequests();
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to create request: $e',
      );
      return false;
    }
  }

  // Start processing a service request (admin only)
  Future<bool> startProcessing(
      String requestId, String adminId, String adminName) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      final docRef = _firestore.collection('service_requests').doc(requestId);
      final doc = await docRef.get();

      if (!doc.exists) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Request not found',
        );
        return false;
      }

      final request = ServiceRequestModel.fromFirestore(doc);

      if (request.status != ServiceRequestStatus.pending) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'This request is already being processed',
        );
        return false;
      }

      await docRef.update({
        'status': 'inProgress',
        'startedAt': FieldValue.serverTimestamp(),
        'assignedAdminId': adminId,
        'assignedAdminName': adminName,
      });

      await loadRequests();
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to start processing request: $e',
      );
      debugPrint('Error starting processing of request: $e');
      return false;
    }
  }

  // Complete a service request (admin only)
  Future<bool> completeRequest(String requestId, String? notes) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      await _firestore.collection('service_requests').doc(requestId).update({
        'status': 'completed',
        'completedAt': FieldValue.serverTimestamp(),
        'notes': notes,
      });

      await loadRequests();
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to complete request: $e',
      );
      debugPrint('Error completing request: $e');
      return false;
    }
  }

  // Reject a service request (admin only)
  Future<bool> rejectRequest(String requestId, String reason) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      await _firestore.collection('service_requests').doc(requestId).update({
        'status': 'cancelled',
        'completedAt': FieldValue.serverTimestamp(),
        'notes': reason,
      });

      await loadRequests();
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to reject request: $e',
      );
      debugPrint('Error rejecting request: $e');
      return false;
    }
  }

  // Cancel a service request
  Future<bool> cancelRequest(String requestId) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      final docRef = _firestore.collection('service_requests').doc(requestId);
      final doc = await docRef.get();

      if (!doc.exists) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Request not found',
        );
        return false;
      }

      final request = ServiceRequestModel.fromFirestore(doc);

      if (request.status != ServiceRequestStatus.pending &&
          request.status != ServiceRequestStatus.inProgress) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Cannot cancel a request that is completed',
        );
        return false;
      }

      await docRef.update({
        'status': 'cancelled',
        'completedAt': FieldValue.serverTimestamp(),
      });

      await loadRequests();
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to cancel request: $e',
      );
      debugPrint('Error cancelling request: $e');
      return false;
    }
  }
}

// Provider for service requests state
final serviceRequestsProvider =
    StateNotifierProvider<ServiceRequestsNotifier, ServiceRequestsState>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return ServiceRequestsNotifier(firestore);
});

// Stream provider for pending service requests
final pendingServiceRequestsProvider =
    StreamProvider<List<ServiceRequestModel>>((ref) {
  return FirebaseFirestore.instance
      .collection('service_requests')
      .where('status', isEqualTo: 'pending')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => ServiceRequestModel.fromFirestore(doc))
          .toList());
});

// Stream provider for in-progress service requests
final inProgressServiceRequestsProvider =
    StreamProvider<List<ServiceRequestModel>>((ref) {
  return FirebaseFirestore.instance
      .collection('service_requests')
      .where('status', whereIn: ['processing', 'inProgress'])
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => ServiceRequestModel.fromFirestore(doc))
          .toList());
});

// Stream provider for all service requests
final allServiceRequestsProvider =
    StreamProvider<List<ServiceRequestModel>>((ref) {
  return FirebaseFirestore.instance
      .collection('service_requests')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => ServiceRequestModel.fromFirestore(doc))
          .toList());
});

// Provider for new requests count
final newRequestsCountProvider = Provider<int>((ref) {
  final requestsState = ref.watch(serviceRequestsProvider);
  return requestsState.newRequestsCount;
});
