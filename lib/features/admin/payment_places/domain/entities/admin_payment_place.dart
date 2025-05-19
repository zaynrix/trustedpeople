class AdminPaymentPlace {
  final String id;
  final String name;
  final String phoneNumber;
  final String location;
  final String category;
  final List<String> paymentMethods;
  final String workingHours;
  final String description;
  final String imageUrl;
  final bool isVerified;
  final double rating;
  final int reviewsCount;

  const AdminPaymentPlace({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.location,
    required this.category,
    required this.paymentMethods,
    this.workingHours = '',
    this.description = '',
    this.imageUrl = '',
    this.isVerified = true,
    this.rating = 0.0,
    this.reviewsCount = 0,
  });
}