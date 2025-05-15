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
    required this.isTrusted,
    this.servicesProvided = '',
    this.telegramAccount = '',
    this.otherAccounts = '',
    this.reviews = '',
  });
}