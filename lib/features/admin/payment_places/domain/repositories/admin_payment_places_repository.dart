import 'package:trustedtallentsvalley/features/admin/payment_places/domain/entities/admin_payment_place.dart';

enum AdminPlacesFilterMode { all, verified, unverified, highRated, category, byLocation }

abstract class AdminPaymentPlacesRepository {
  // Get all payment places
  Stream<List<AdminPaymentPlace>> getPaymentPlaces();

  // Get payment place by ID
  Future<AdminPaymentPlace?> getPaymentPlaceById(String id);

  // Get categories for filtering
  Stream<List<String>> getCategories();

  // Get locations for filtering
  Stream<List<String>> getLocations();

  // Add new payment place
  Future<String> addPaymentPlace(AdminPaymentPlace place);

  // Update payment place
  Future<void> updatePaymentPlace(AdminPaymentPlace place);

  // Delete payment place
  Future<void> deletePaymentPlace(String id);

  // Update verification status
  Future<void> updateVerificationStatus(String id, bool isVerified);

  // Export places to CSV
  Future<String> exportPlacesToCSV();

  // Export places to Excel
  Future<String> exportPlacesToExcel();
}