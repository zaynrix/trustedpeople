/// Constants used throughout the app
class AppConstants {
  // Private constructor to prevent instantiation
  AppConstants._();

  // Firebase collections
  static const String usersCollection = 'users';
  static const String trustedUsersCollection = 'userstransed';
  static const String goalsCollection = 'goals';
  static const String categoriesCollection = 'exercise_categories';
  static const String exercisesCollection = 'exercises';
  static const String additionalExerciseCollection = 'additional_exercise';
  static const String paymentPlacesCollection = 'paymentPlaces';
  static const String appUpdatesCollection = 'app_updates';
  static const String visitorStatsCollection = 'visitor_stats';
  static const String analyticsCollection = 'analytics';
  static const String adminsCollection = 'admins';

  // Firebase fields
  static const String uid = 'uid';
  static const String name = 'name';
  static const String aliasName = 'aliasName';
  static const String email = 'email';
  static const String phone = 'phone';
  static const String mobileNumber = 'mobileNumber';
  static const String location = 'location';
  static const String goal = 'goal';
  static const String image = 'image';
  static const String level = 'level';
  static const String title = 'title';
  static const String plans = 'plans';
  static const String notifications = 'notifications';
  static const String articles = 'articles';
  static const String isTrusted = 'isTrusted';
  static const String servicesProvided = 'servicesProvided';
  static const String telegramAccount = 'telegramAccount';
  static const String otherAccounts = 'otherAccounts';
  static const String reviews = 'reviews';
  static const String createdAt = 'createdAt';
  static const String updatedAt = 'updatedAt';
  static const String role = 'role';

  // URL patterns for web integration
  static const String apiBaseUrl = 'https://api.example.com';

  // Shared preferences keys
  static const String lastVisitDateKey = 'last_visit_date';
  static const String prefsShowOnceKey = 'prefs_show_once';

  // Default values
  static const int defaultPageSize = 10;
}
