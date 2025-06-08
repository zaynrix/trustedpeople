// Helper functions
String extractFirstName(String fullName) {
  final parts = fullName.trim().split(' ');
  return parts.isNotEmpty ? parts.first : '';
}

String extractLastName(String fullName) {
  final parts = fullName.trim().split(' ');
  return parts.length > 1 ? parts.skip(1).join(' ') : '';
}
