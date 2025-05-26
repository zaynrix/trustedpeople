// File: lib/features/maintenance/maintenance_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MaintenanceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'maintenance_status';

  // Get maintenance status for all screens
  Stream<Map<String, bool>> getMaintenanceStatus() {
    return _firestore
        .collection(_collection)
        .doc('screens')
        .snapshots()
        .map((doc) {
      if (!doc.exists) {
        return <String, bool>{};
      }
      final data = doc.data() as Map<String, dynamic>;
      return data.map((key, value) => MapEntry(key, value as bool));
    });
  }

  // Update maintenance status for a specific screen
  Future<void> updateScreenMaintenanceStatus(
      String screenName, bool isUnderMaintenance) async {
    try {
      await _firestore
          .collection(_collection)
          .doc('screens')
          .set({screenName: isUnderMaintenance}, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to update maintenance status: $e');
    }
  }

  // Check if a specific screen is under maintenance
  Future<bool> isScreenUnderMaintenance(String screenName) async {
    try {
      final doc = await _firestore.collection(_collection).doc('screens').get();

      if (!doc.exists) return false;

      final data = doc.data() as Map<String, dynamic>?;
      return data?[screenName] ?? false;
    } catch (e) {
      return false;
    }
  }

  // Bulk update multiple screens
  Future<void> bulkUpdateMaintenanceStatus(Map<String, bool> updates) async {
    try {
      await _firestore
          .collection(_collection)
          .doc('screens')
          .set(updates, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to bulk update maintenance status: $e');
    }
  }
}

// Providers
final maintenanceServiceProvider = Provider<MaintenanceService>((ref) {
  return MaintenanceService();
});

final maintenanceStatusProvider = StreamProvider<Map<String, bool>>((ref) {
  final service = ref.watch(maintenanceServiceProvider);
  return service.getMaintenanceStatus();
});

// Provider to check if a specific screen is under maintenance
final screenMaintenanceProvider =
    Provider.family<bool, String>((ref, screenName) {
  final maintenanceStatus = ref.watch(maintenanceStatusProvider);
  return maintenanceStatus.maybeWhen(
    data: (status) => status[screenName] ?? false,
    orElse: () => false,
  );
});
