/// Base user entity in the domain layer
class User {
  final String id;
  final String aliasName;
  final String mobileNumber;
  final String location;
  final String servicesProvided;
  final String telegramAccount;
  final String otherAccounts;
  final String reviews;
  final bool isTrusted;

  User({
    required this.id,
    required this.aliasName,
    required this.mobileNumber,
    required this.location,
    required this.servicesProvided,
    required this.telegramAccount,
    required this.otherAccounts,
    required this.reviews,
    required this.isTrusted,
  });

  /// Create a copy of this User with specific fields replaced
  User copyWith({
    String? id,
    String? aliasName,
    String? mobileNumber,
    String? location,
    String? servicesProvided,
    String? telegramAccount,
    String? otherAccounts,
    String? reviews,
    bool? isTrusted,
  }) {
    return User(
      id: id ?? this.id,
      aliasName: aliasName ?? this.aliasName,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      location: location ?? this.location,
      servicesProvided: servicesProvided ?? this.servicesProvided,
      telegramAccount: telegramAccount ?? this.telegramAccount,
      otherAccounts: otherAccounts ?? this.otherAccounts,
      reviews: reviews ?? this.reviews,
      isTrusted: isTrusted ?? this.isTrusted,
    );
  }
}
