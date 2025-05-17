import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trustedtallentsvalley/app/config/firebase_constant.dart';
import 'package:trustedtallentsvalley/features/user/home/domain/entities/home_data.dart';

// Provider for Firebase Firestore
final firebaseFirestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

// Provider for trusted users count
final trustedUsersCountProvider = StreamProvider<int>((ref) {
  return FirebaseFirestore.instance
      .collection(FirebaseConstants.trustedUsers)
      .where('isTrusted', isEqualTo: true)
      .snapshots()
      .map((snapshot) => snapshot.size);
});

// Provider for untrusted users count
final untrustedUsersCountProvider = StreamProvider<int>((ref) {
  return FirebaseFirestore.instance
      .collection(FirebaseConstants.trustedUsers)
      .where('isTrusted', isEqualTo: false)
      .snapshots()
      .map((snapshot) => snapshot.size);
});

// Provider for total visitors count
final totalVisitorsProvider = FutureProvider<int>((ref) async {
  final doc = await FirebaseFirestore.instance
      .collection(FirebaseConstants.visitorStats)
      .doc('totals')
      .get();
  return doc.data()?['totalUniqueVisitors'] ?? 0;
});

// Provider for recent updates
final recentUpdatesProvider = StreamProvider<List<AppUpdate>>((ref) {
  return FirebaseFirestore.instance
      .collection(FirebaseConstants.appUpdates)
      .orderBy('date', descending: true)
      .limit(5)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => AppUpdate.fromMap(doc.data(), doc.id))
          .toList());
});

// Combined provider for all home data
final homeDataProvider = Provider<AsyncValue<HomeData>>((ref) {
  final trustedCount = ref.watch(trustedUsersCountProvider);
  final untrustedCount = ref.watch(untrustedUsersCountProvider);
  final totalVisitors = ref.watch(totalVisitorsProvider);
  final recentUpdates = ref.watch(recentUpdatesProvider);

  // Combine all async values
  return trustedCount.when(
    data: (trustedData) => untrustedCount.when(
      data: (untrustedData) => totalVisitors.when(
        data: (visitorsData) => recentUpdates.when(
          data: (updatesData) => AsyncValue.data(
            HomeData(
              trustedCount: trustedData,
              untrustedCount: untrustedData,
              totalVisitors: visitorsData,
              recentUpdates: updatesData,
            ),
          ),
          loading: () => const AsyncValue.loading(),
          error: (e, st) => AsyncValue.error(e, st),
        ),
        loading: () => const AsyncValue.loading(),
        error: (e, st) => AsyncValue.error(e, st),
      ),
      loading: () => const AsyncValue.loading(),
      error: (e, st) => AsyncValue.error(e, st),
    ),
    loading: () => const AsyncValue.loading(),
    error: (e, st) => AsyncValue.error(e, st),
  );
});
