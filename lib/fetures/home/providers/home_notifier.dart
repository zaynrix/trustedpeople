import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:riverpod/riverpod.dart';
import 'package:trustedtallentsvalley/config/firebase_constant.dart';
import 'package:trustedtallentsvalley/fetures/Home/models/ActivityUpdate.dart';
import 'package:trustedtallentsvalley/fetures/Home/models/user_model.dart';
import 'package:trustedtallentsvalley/fetures/services/auth_service.dart';

class UserData {
  final String aliasName;
  final String mobileNumber;
  final String location;
  final bool isTrusted;
  final String servicesProvided;
  final String telegramAccount;
  final String otherAccounts;
  final String reviews;

  UserData({
    required this.aliasName,
    required this.mobileNumber,
    required this.location,
    required this.isTrusted,
    required this.servicesProvided,
    required this.telegramAccount,
    required this.otherAccounts,
    required this.reviews,
  });
}

// Define filter modes
enum FilterMode { all, withReviews, withoutTelegram, byLocation }

// Enhanced HomeState class with more properties
class HomeState {
  final bool showSideBar;
  final UserModel? selectedUser;
  final UserModel? userModel;
  final String searchQuery;
  final int currentPage;
  final int pageSize;
  final String sortField;
  final bool sortAscending;
  final FilterMode filterMode;
  final String? locationFilter;
  final bool isLoading;
  final String? errorMessage;

  HomeState({
    this.showSideBar = false,
    this.selectedUser,
    this.userModel,
    this.searchQuery = '',
    this.currentPage = 1,
    this.pageSize = 10,
    this.sortField = 'aliasName',
    this.sortAscending = true,
    this.filterMode = FilterMode.all,
    this.locationFilter,
    this.isLoading = false,
    this.errorMessage,
  });

  // Create a copy of the state with modified properties
  HomeState copyWith({
    bool? showSideBar,
    UserModel? selectedUser,
    UserModel? userModel,
    String? searchQuery,
    int? currentPage,
    int? pageSize,
    String? sortField,
    bool? sortAscending,
    FilterMode? filterMode,
    String? locationFilter,
    bool? isLoading,
    String? errorMessage,
  }) {
    return HomeState(
      showSideBar: showSideBar ?? this.showSideBar,
      selectedUser: selectedUser ?? this.selectedUser,
      userModel: userModel ?? this.userModel,
      searchQuery: searchQuery ?? this.searchQuery,
      currentPage: currentPage ?? this.currentPage,
      pageSize: pageSize ?? this.pageSize,
      sortField: sortField ?? this.sortField,
      sortAscending: sortAscending ?? this.sortAscending,
      filterMode: filterMode ?? this.filterMode,
      locationFilter: locationFilter ?? this.locationFilter,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

final firebaseFirestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

// Enhanced HomeNotifier with additional methods
class HomeNotifier extends StateNotifier<HomeState> {
  final FirebaseFirestore _firestore;

  HomeNotifier(this._firestore) : super(HomeState());
  final visiblePhoneNumberProvider = StateProvider<String?>((ref) => null);
  // Method to toggle phone number visibility
  void togglePhoneNumberVisibility(String userId, ref) {
    final currentVisibleId = ref.read(visiblePhoneNumberProvider);

    if (currentVisibleId == userId) {
      // Hide the current visible number
      ref.read(visiblePhoneNumberProvider.notifier).state = null;
    } else {
      // Show this user's number (and hide any other)
      ref.read(visiblePhoneNumberProvider.notifier).state = userId;
    }
  }

  // Method to hide all phone numbers
  void hideAllPhoneNumbers(ref) {
    ref.read(visiblePhoneNumberProvider.notifier).state = null;
  }

  // Method to check if a specific user's phone number is visible
  bool isPhoneNumberVisible(String userId, ref) {
    final visibleId = ref.read(visiblePhoneNumberProvider);
    return visibleId == userId;
  }

  // Method to check if predefined users already exist (optional)
  Future<bool> checkIfPredefinedUsersExist() async {
    try {
      final snapshot = await _firestore
          .collection(FirebaseConstant.trustedUsers)
          .where('aliasName',
              isEqualTo: 'يحيى') // Check for the first user as example
          .limit(1)
          .get();

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      debugPrint('Error checking existing users: $e');
      return false;
    }
  }

  // Method to clear all users (use with caution!)
  Future<bool> clearAllUsers() async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      final snapshot =
          await _firestore.collection(FirebaseConstant.trustedUsers).get();

      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();

      state = state.copyWith(
        isLoading: false,
        selectedUser: null,
        showSideBar: false,
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Error clearing users: $e',
      );
      debugPrint('Error clearing users: $e');
      return false;
    }
  }

  // Get user data from Firestore
  Future<void> getGoalData() async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      DocumentSnapshot doc = await _firestore
          .collection(FirebaseConstant.trustedUsers)
          .doc()
          .get();

      state = state.copyWith(
        userModel: UserModel.fromFirestore(doc),
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Error fetching data: $e',
      );
      debugPrint('Error fetching goal data: $e');
    }
  }

  // Close/toggle sidebar
  void closeBar() {
    state = state.copyWith(showSideBar: !state.showSideBar);
  }

  // Toggle sidebar visibility based on selected user
  void visibleBar({UserModel? selected}) {
    if (state.selectedUser == selected) {
      // Toggle sidebar if same user is selected
      state = state.copyWith(showSideBar: !state.showSideBar);
    } else {
      // Show sidebar and update selected user
      state = state.copyWith(
        showSideBar: true,
        selectedUser: selected,
      );
    }
  }

  // Get currently selected user
  UserModel? getUser() {
    return state.selectedUser;
  }

  // Set search query
  void setSearchQuery(String query) {
    state = state.copyWith(
      searchQuery: query,
      currentPage: 1, // Reset to first page when search changes
    );
  }

  // Set current page for pagination
  void setCurrentPage(int page) {
    state = state.copyWith(currentPage: page);
  }

  // Set page size for pagination
  void setPageSize(int size) {
    state = state.copyWith(
      pageSize: size,
      currentPage: 1, // Reset to first page when page size changes
    );
  }

  // Set sort field and direction
  void setSort(String field, {bool? ascending}) {
    // If same field, toggle direction unless specified
    if (field == state.sortField && ascending == null) {
      state = state.copyWith(sortAscending: !state.sortAscending);
    } else {
      state = state.copyWith(
        sortField: field,
        sortAscending: ascending ?? true,
      );
    }
  }

  // Set filter mode
  void setFilterMode(FilterMode mode) {
    state = state.copyWith(
      filterMode: mode,
      currentPage: 1, // Reset to first page when filter changes
    );
  }

  // Set location filter
  void setLocationFilter(String? location) {
    state = state.copyWith(
      locationFilter: location,
      filterMode: FilterMode.byLocation,
      currentPage: 1, // Reset to first page when filter changes
    );
  }

  Future<bool> batchAddPredefinedUsers({required ref}) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      // Define the predefined users data
      final List<UserData> predefinedUsers = [
        UserData(
          aliasName: "يحيى",
          mobileNumber: "+972592487533",
          location: "فلسطين/إسرائيل",
          isTrusted: true,
          servicesProvided: "استقبال من جميع دول العالم، USDT, Revlout, Paypal",
          telegramAccount: "",
          otherAccounts: "",
          reviews: "",
        ),
        UserData(
          aliasName: "ماجد",
          mobileNumber: "+972 59-261-9965, +972562223551",
          location: "فلسطين/إسرائيل",
          isTrusted: true,
          servicesProvided:
              "أمريكا، أوروبا، بريطانيا،Wise, PayPal, Payoneer، ويسترن يونيون، دول الخليج",
          telegramAccount: "",
          otherAccounts: "",
          reviews: "",
        ),
        UserData(
          aliasName: "محمد",
          mobileNumber: "+972 56-6472431",
          location: "فلسطين/إسرائيل",
          isTrusted: true,
          servicesProvided: "USDT, TikTok",
          telegramAccount: "",
          otherAccounts: "",
          reviews: "",
        ),
        UserData(
          aliasName: "حمدي",
          mobileNumber: "+972598289003",
          location: "فلسطين/إسرائيل",
          isTrusted: true,
          servicesProvided: "حوالات دولية، PayPal",
          telegramAccount: "",
          otherAccounts: "",
          reviews: "",
        ),
        UserData(
          aliasName: "بيان",
          mobileNumber: "+972 59-506-9967",
          location: "فلسطين/إسرائيل",
          isTrusted: true,
          servicesProvided: "USDT",
          telegramAccount: "",
          otherAccounts: "",
          reviews: "",
        ),
        UserData(
          aliasName: "براء",
          mobileNumber: "+972 59-914-0957, +972 59-711-3369",
          location: "فلسطين/إسرائيل",
          isTrusted: true,
          servicesProvided: "الأردن، USDT، Revolut, PayPal,حوالات دولية",
          telegramAccount: "",
          otherAccounts: "",
          reviews: "",
        ),
        UserData(
          aliasName: "دولار للصرافة",
          mobileNumber: "+972 59-871-0003",
          location: "فلسطين/إسرائيل",
          isTrusted: true,
          servicesProvided:
              "USDT, فودافون كاش, الأردن امارات، كويت، قطر، عمان، المغرب، البحرين، السعودية، اليمن",
          telegramAccount: "",
          otherAccounts: "",
          reviews: "",
        ),
        UserData(
          aliasName: "البراء",
          mobileNumber: "+972 59-244-9244",
          location: "فلسطين/إسرائيل",
          isTrusted: true,
          servicesProvided: "USDT, الامارات، الاردن، مصر، PayPal، سلطنة عمان",
          telegramAccount: "",
          otherAccounts: "",
          reviews: "",
        ),
        UserData(
          aliasName: "أطلس للصرافة",
          mobileNumber: "+972 59-878-1313",
          location: "فلسطين/إسرائيل",
          isTrusted: true,
          servicesProvided:
              "ويسترن يونيون، موني غرام، ريا، تركيا، ليبيا، الجزائر، العراق",
          telegramAccount: "",
          otherAccounts: "",
          reviews: "",
        ),
        UserData(
          aliasName: "المنشاوي للصرافة والحوالات المالية",
          mobileNumber: "+970595704141",
          location: "فلسطين",
          isTrusted: true,
          servicesProvided: "",
          telegramAccount: "",
          otherAccounts: "",
          reviews: "",
        ),
        UserData(
          aliasName: "صالح",
          mobileNumber: "+972598258269",
          location: "فلسطين/إسرائيل",
          isTrusted: true,
          servicesProvided: "",
          telegramAccount: "",
          otherAccounts: "",
          reviews: "",
        ),
        UserData(
          aliasName: "معتصم",
          mobileNumber: "+972 59-253-1001",
          location: "فلسطين/إسرائيل",
          isTrusted: true,
          servicesProvided: "USDT",
          telegramAccount: "",
          otherAccounts: "",
          reviews: "",
        ),
        UserData(
          aliasName: "شركة الدفع السريع",
          mobileNumber: "+970 59-993-0036",
          location: "فلسطين",
          isTrusted: true,
          servicesProvided: "",
          telegramAccount: "",
          otherAccounts: "",
          reviews: "",
        ),
        UserData(
          aliasName: "خليل",
          mobileNumber: "+972 59-563-9555",
          location: "فلسطين/إسرائيل",
          isTrusted: true,
          servicesProvided: "USDT, تركيا، وايزو ويسترن يونيون، فودافون",
          telegramAccount: "",
          otherAccounts: "",
          reviews: "",
        ),
        UserData(
          aliasName: "محمد طموس",
          mobileNumber: "+972 59-708-0098",
          location: "فلسطين/إسرائيل",
          isTrusted: true,
          servicesProvided:
              "باي بال، USDT، فودافون، منصات العمل الحر، إستقبال بوابة دفع",
          telegramAccount: "",
          otherAccounts: "",
          reviews: "",
        ),
        UserData(
          aliasName: "محمود سالم",
          mobileNumber: "+972 598 84 4330",
          location: "فلسطين/إسرائيل",
          isTrusted: true,
          servicesProvided: "الأردن، دول الخليج، فودافون، USDT",
          telegramAccount: "",
          otherAccounts: "",
          reviews: "",
        ),
        UserData(
          aliasName: "صبَّاح للصرافة والحوالات المالية -دير البلح",
          mobileNumber: "+972 59-290-0707",
          location: "فلسطين/إسرائيل",
          isTrusted: true,
          servicesProvided: "",
          telegramAccount: "",
          otherAccounts: "",
          reviews: "",
        ),
        UserData(
          aliasName: "حمادة منيفي",
          mobileNumber: "+972 59-222-8463",
          location: "فلسطين/إسرائيل",
          isTrusted: true,
          servicesProvided: "USDT, الأردن, السعودية،الامارت،PayPal",
          telegramAccount: "",
          otherAccounts: "",
          reviews: "",
        ),
        UserData(
          aliasName: "حمادة النجار",
          mobileNumber: "+970 599 52 1600",
          location: "فلسطين",
          isTrusted: true,
          servicesProvided: "اوروبا، امريكا ، USDT, فودافون كاش",
          telegramAccount: "",
          otherAccounts: "",
          reviews: "",
        ),
        UserData(
          aliasName: "عابد للصرافة",
          mobileNumber: "+970 599 966 166",
          location: "فلسطين",
          isTrusted: true,
          servicesProvided:
              "حوالات دول الخليج، تركيا، فودافون، USDT، حوالات أوروبية، حوالات عربية",
          telegramAccount: "",
          otherAccounts: "",
          reviews: "",
        ),
        UserData(
          aliasName: "حرزالله للصرافة",
          mobileNumber: "+972 59-720-2152",
          location: "فلسطين/إسرائيل",
          isTrusted: true,
          servicesProvided: "الحوالات الدولية، USDT، فودافون كاش",
          telegramAccount: "",
          otherAccounts: "",
          reviews: "",
        ),
        UserData(
          aliasName: "احمد الشريف",
          mobileNumber: "+970 599 921 827",
          location: "فلسطين",
          isTrusted: true,
          servicesProvided: "USDT, فودافون",
          telegramAccount: "",
          otherAccounts: "",
          reviews: "",
        ),
        UserData(
          aliasName: "الفيصل للصرافة",
          mobileNumber: "+972 59-771-4208, +972598919757",
          location: "فلسطين/إسرائيل",
          isTrusted: true,
          servicesProvided: "",
          telegramAccount: "",
          otherAccounts: "",
          reviews: "",
        ),
        UserData(
          aliasName: "الوطني للصرافه والحوالات الماليه",
          mobileNumber: "+970 599 16 7166",
          location: "فلسطين",
          isTrusted: true,
          servicesProvided: "",
          telegramAccount: "",
          otherAccounts: "",
          reviews: "",
        ),
        UserData(
          aliasName: "المعتمد للصرافة والحوالات المالية - غزة",
          mobileNumber: "+970 593 09 9123",
          location: "فلسطين",
          isTrusted: true,
          servicesProvided: "",
          telegramAccount: "",
          otherAccounts: "",
          reviews: "",
        ),
        UserData(
          aliasName: "المنشاوي للصرافة والحوالات المالية",
          mobileNumber: "+970595704141",
          location: "فلسطين",
          isTrusted: true,
          servicesProvided: "",
          telegramAccount: "",
          otherAccounts: "",
          reviews: "",
        ),
        UserData(
          aliasName: "حرز الله للصرافة",
          mobileNumber: "0593330006, 972594560600",
          location: "فلسطين/إسرائيل",
          isTrusted: true,
          servicesProvided: "حوالات دولية، حوالات عربية",
          telegramAccount: "",
          otherAccounts: "",
          reviews: "",
        ),
        UserData(
          aliasName: "قويدر للصرافة",
          mobileNumber: "+970 599 60 4471",
          location: "فلسطين",
          isTrusted: true,
          servicesProvided: "",
          telegramAccount: "",
          otherAccounts: "",
          reviews: "",
        ),
        UserData(
          aliasName: "نادر - شيفت للصرافة",
          mobileNumber: "+972 59-956-2801, +972 59-828-8013",
          location: "فلسطين/إسرائيل",
          isTrusted: true,
          servicesProvided: "",
          telegramAccount: "",
          otherAccounts: "",
          reviews: "",
        ),
        UserData(
          aliasName: "الخليج الدولية للصرافة",
          mobileNumber: "+970 592 49 9843, +970 567 158 563",
          location: "فلسطين",
          isTrusted: true,
          servicesProvided: "",
          telegramAccount: "",
          otherAccounts: "",
          reviews: "",
        ),
        UserData(
          aliasName: "الدانا للصرافة",
          mobileNumber: "+972597234202",
          location: "فلسطين/إسرائيل",
          isTrusted: true,
          servicesProvided: "",
          telegramAccount: "",
          otherAccounts: "",
          reviews: "",
        ),
        UserData(
          aliasName: "شركة سريع للصرافة",
          mobileNumber: "+970 595 922 185",
          location: "فلسطين",
          isTrusted: true,
          servicesProvided: "",
          telegramAccount: "",
          otherAccounts: "",
          reviews: "",
        ),
        UserData(
          aliasName: "فاست كاش",
          mobileNumber: "+970 599 365 651",
          location: "فلسطين",
          isTrusted: true,
          servicesProvided: "",
          telegramAccount: "",
          otherAccounts: "",
          reviews: "",
        ),
        UserData(
          aliasName: "ماهر البغدادي",
          mobileNumber: "+972 59-560-3802",
          location: "فلسطين/إسرائيل",
          isTrusted: true,
          servicesProvided: "الأردن، USDT",
          telegramAccount: "",
          otherAccounts: "",
          reviews: "",
        ),
        UserData(
          aliasName: "صهيب الاستاذ",
          mobileNumber: "+970 598 213 559",
          location: "فلسطين",
          isTrusted: true,
          servicesProvided: "حوالات خليجية، USDT",
          telegramAccount: "",
          otherAccounts: "",
          reviews: "",
        ),
        UserData(
          aliasName: "باسل ابو ريدة",
          mobileNumber: "+972 59-984-9306",
          location: "فلسطين/إسرائيل",
          isTrusted: true,
          servicesProvided: "PayPal, USDT, الخليج",
          telegramAccount: "",
          otherAccounts: "",
          reviews: "",
        ),
        UserData(
          aliasName: "رؤوف",
          mobileNumber: "+970 592 426 557",
          location: "فلسطين",
          isTrusted: true,
          servicesProvided: "حوالات دولية",
          telegramAccount: "",
          otherAccounts: "",
          reviews: "",
        ),
        UserData(
          aliasName: "ايهاب فلانكو",
          mobileNumber: "+972 56-892-6178",
          location: "فلسطين/إسرائيل",
          isTrusted: true,
          servicesProvided: "",
          telegramAccount: "",
          otherAccounts: "",
          reviews: "",
        ),
        UserData(
          aliasName: "ياسر الدباس",
          mobileNumber: "+972 59-536-1790",
          location: "فلسطين/إسرائيل",
          isTrusted: true,
          servicesProvided: "",
          telegramAccount: "",
          otherAccounts: "",
          reviews: "",
        ),
        UserData(
          aliasName: "مكتب كيشلي",
          mobileNumber: "+972 59-510-2759",
          location: "فلسطين/إسرائيل",
          isTrusted: true,
          servicesProvided: "استقبال جميع الدول، فودافون كاش، USDT، Tik Tok",
          telegramAccount: "",
          otherAccounts: "",
          reviews: "",
        ),
        UserData(
          aliasName: "انجاز للصرافة",
          mobileNumber: "+972 56-755-7590",
          location: "فلسطين/إسرائيل",
          isTrusted: true,
          servicesProvided: "استقبال دول، فودافون، كاش",
          telegramAccount: "",
          otherAccounts: "",
          reviews: "",
        ),
        UserData(
          aliasName: "بلال",
          mobileNumber: "+972 59-447-5597",
          location: "فلسطين/إسرائيل",
          isTrusted: true,
          servicesProvided: "الاردن، فودافون كاش، USDT",
          telegramAccount: "",
          otherAccounts: "",
          reviews: "",
        ),
        UserData(
          aliasName: "مصعب رضوان",
          mobileNumber: "+972 59-255-4866",
          location: "فلسطين/إسرائيل",
          isTrusted: true,
          servicesProvided: "ويسترن يونيون، موني غرام، قطر، فودافون",
          telegramAccount: "",
          otherAccounts: "",
          reviews: "",
        ),
        UserData(
          aliasName: "معاذ",
          mobileNumber: "+972 59-281-2551",
          location: "فلسطين/إسرائيل",
          isTrusted: true,
          servicesProvided: "",
          telegramAccount: "",
          otherAccounts: "",
          reviews: "",
        ),
        UserData(
          aliasName: "شركة ساجد شقليه للصرافة والحوالات المالية WU",
          mobileNumber: "+972 59-973-5137",
          location: "فلسطين/إسرائيل",
          isTrusted: true,
          servicesProvided: "",
          telegramAccount: "",
          otherAccounts: "",
          reviews: "",
        ),
        UserData(
          aliasName: "احمد",
          mobileNumber: "+970 595 564 510",
          location: "فلسطين",
          isTrusted: true,
          servicesProvided: "منصات العمل الحر، فودافون كاش",
          telegramAccount: "",
          otherAccounts: "",
          reviews: "",
        ),
        UserData(
          aliasName: "الأستاذ للصرافة",
          mobileNumber: "+972 56-912-1919, +972 59-786-6281",
          location: "فلسطين/إسرائيل",
          isTrusted: true,
          servicesProvided: "",
          telegramAccount: "",
          otherAccounts: "",
          reviews: "",
        ),
        UserData(
          aliasName: "مرشد للصرافة",
          mobileNumber: "+972 59-980-3137, +970 599 180 478",
          location: "فلسطين/إسرائيل",
          isTrusted: true,
          servicesProvided: "",
          telegramAccount: "",
          otherAccounts: "",
          reviews: "",
        ),
        UserData(
          aliasName: "ابو عمر",
          mobileNumber: "+972 59-216-1229",
          location: "فلسطين/إسرائيل",
          isTrusted: true,
          servicesProvided:
              "فودافون كاش +انستا باي، USDT + paypal +ويسترن يونيون، حوالات دول عربية",
          telegramAccount: "",
          otherAccounts: "",
          reviews: "",
        ),
        UserData(
          aliasName: "احمد النجار",
          mobileNumber: "00972595816203, 00972562772891",
          location: "فلسطين/إسرائيل",
          isTrusted: true,
          servicesProvided: "أوروبا، الجزائر، الاردن،PayPal، USDT",
          telegramAccount: "",
          otherAccounts: "",
          reviews: "",
        ),
        UserData(
          aliasName: "محمد قويدر",
          mobileNumber: "+970-597999232",
          location: "فلسطين",
          isTrusted: true,
          servicesProvided: "USDT فودافون كاش ,انستا باي, ويسترن يونيون",
          telegramAccount: "",
          otherAccounts: "",
          reviews: "",
        ),
        UserData(
          aliasName: "ابو ادم",
          mobileNumber: "+972592155294",
          location: "فلسطين/إسرائيل",
          isTrusted: true,
          servicesProvided:
              "USDT, Revlout, Paypal، اوروبا، امريكا، الخليج، بريطانيا",
          telegramAccount: "",
          otherAccounts: "",
          reviews: "",
        ),
        UserData(
          aliasName: "مكتب آدم",
          mobileNumber: "972592553910",
          location: "فلسطين/إسرائيل",
          isTrusted: true,
          servicesProvided:
              "الدول العربية، الاوروبية، ويسترن يونيون، الاردن، المغرب",
          telegramAccount: "",
          otherAccounts: "",
          reviews: "",
        ),
        UserData(
          aliasName: "مكتب ترست بلس",
          mobileNumber: "0594429043",
          location: "فلسطين",
          isTrusted: true,
          servicesProvided: "حوالات دولية - حوالات عربية - USDT",
          telegramAccount: "",
          otherAccounts: "",
          reviews: "",
        ),
        UserData(
          aliasName: "مكتب ايلاف",
          mobileNumber: "970599516360",
          location: "فلسطين",
          isTrusted: true,
          servicesProvided: "حوالات دولية - حوالات عربية - USDT",
          telegramAccount: "",
          otherAccounts: "",
          reviews: "",
        ),
        UserData(
          aliasName: "ارشي للصرافة - السرايا",
          mobileNumber: "0599704097, 972595731317",
          location: "فلسطين/إسرائيل",
          isTrusted: true,
          servicesProvided: "حوالات دولية - حوالات عربية - USDT",
          telegramAccount: "",
          otherAccounts: "",
          reviews: "",
        ),
        UserData(
          aliasName: "ارشي للصرافة - شارع الوحدة",
          mobileNumber: "972599876133",
          location: "فلسطين/إسرائيل",
          isTrusted: true,
          servicesProvided: "حوالات دولية - حوالات عربية - USDT",
          telegramAccount: "",
          otherAccounts: "",
          reviews: "",
        ),
        UserData(
          aliasName: "قشطة للصرافة",
          mobileNumber: "972568033337",
          location: "فلسطين/إسرائيل",
          isTrusted: true,
          servicesProvided: "حوالات دولية - حوالات عربية - USDT",
          telegramAccount: "",
          otherAccounts: "",
          reviews: "",
        ),
      ];

      int successCount = 0;
      int errorCount = 0;
      List<String> errors = [];

      // Get admin information
      final auth = ref.read(firebaseAuthProvider);
      final currentUser = auth.currentUser;
      final adminName =
          currentUser?.displayName ?? currentUser?.email ?? 'مشرف غير معروف';

      // Add each user
      for (final userData in predefinedUsers) {
        try {
          // Generate a new document ID
          final docRef =
              _firestore.collection(FirebaseConstant.trustedUsers).doc();

          await docRef.set({
            'id': docRef.id,
            'aliasName': userData.aliasName,
            'mobileNumber': userData.mobileNumber,
            'location': userData.location,
            'isTrusted': userData.isTrusted,
            'servicesProvided': userData.servicesProvided,
            'telegramAccount': userData.telegramAccount,
            'otherAccounts': userData.otherAccounts,
            'reviews': userData.reviews,
            'createdAt': FieldValue.serverTimestamp(),
            'addedBy': adminName,
          });

          successCount++;
          debugPrint('Successfully added user: ${userData.aliasName}');

          // Add a small delay between operations to prevent overwhelming Firestore
          await Future.delayed(const Duration(milliseconds: 100));
        } catch (e) {
          errorCount++;
          errors.add('Error adding ${userData.aliasName}: $e');
          debugPrint('Error adding user ${userData.aliasName}: $e');
        }
      }

      state = state.copyWith(
        isLoading: false,
        errorMessage: errorCount > 0
            ? 'Added $successCount users successfully. $errorCount failed. First error: ${errors.isNotEmpty ? errors.first : "Unknown error"}'
            : null,
      );

      debugPrint(
          'Batch add completed: $successCount successful, $errorCount failed');
      return errorCount == 0;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Error in batch add operation: $e',
      );
      debugPrint('Error in batch add: $e');
      return false;
    }
  }

  // Add new user to Firestore
  Future<bool> addUser({
    ref,
    required String aliasName,
    required String mobileNumber,
    required String location,
    required bool isTrusted,
    String? servicesProvided,
    String? telegramAccount,
    String? otherAccounts,
    String? reviews,
  }) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      // Obtener información del administrador actual
      final auth = ref.read(firebaseAuthProvider);
      final currentUser = auth.currentUser;
      final adminName =
          currentUser?.displayName ?? currentUser?.email ?? 'مشرف غير معروف';

      // Generate a new document ID
      final docRef = _firestore.collection(FirebaseConstant.trustedUsers).doc();

      await docRef.set({
        'id': docRef.id,
        'aliasName': aliasName,
        'mobileNumber': mobileNumber,
        'location': location,
        'isTrusted': isTrusted,
        'servicesProvided': servicesProvided ?? '',
        'telegramAccount': telegramAccount ?? '',
        'otherAccounts': otherAccounts ?? '',
        'reviews': reviews ?? '',
        'createdAt': FieldValue.serverTimestamp(),
        'addedBy': adminName, // Agregamos el nombre del administrador actual
      });

      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Error adding user: $e',
      );
      debugPrint('Error adding user: $e');
      return false;
    }
  }

  // Update existing user in Firestore
  Future<bool> updateUser({
    required String id,
    required String aliasName,
    required String mobileNumber,
    required String location,
    required bool isTrusted,
    required String servicesProvided,
    required String telegramAccount,
    required String otherAccounts,
    required String reviews,
  }) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      // Para actualizaciones, no cambiamos el campo addedBy
      await _firestore
          .collection(FirebaseConstant.trustedUsers)
          .doc(id)
          .update({
        'aliasName': aliasName,
        'mobileNumber': mobileNumber,
        'location': location,
        'isTrusted': isTrusted,
        'servicesProvided': servicesProvided,
        'telegramAccount': telegramAccount,
        'otherAccounts': otherAccounts,
        'reviews': reviews,
        'updatedAt': FieldValue
            .serverTimestamp(), // Se puede agregar un campo para la última actualización
        // No actualizamos 'addedBy' para mantener el registro original
      });

      // Si queremos registrar quién actualizó, podríamos añadir otro campo
      // 'lastUpdatedBy': adminName,

      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Error updating user: $e',
      );
      debugPrint('Error updating user: $e');
      return false;
    }
  }

  // Delete user from Firestore
  Future<bool> deleteUser(String id) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      await _firestore
          .collection(FirebaseConstant.trustedUsers)
          .doc(id)
          .delete();

      // If we're deleting the currently selected user, clear it from the state
      if (state.selectedUser?.id == id) {
        state = state.copyWith(
          selectedUser: null,
          showSideBar: false,
          isLoading: false,
        );
      } else {
        state = state.copyWith(isLoading: false);
      }

      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Error deleting user: $e',
      );
      debugPrint('Error deleting user: $e');
      return false;
    }
  }

  // Export data (placeholder for actual implementation)
  Future<String?> exportData(String format) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      // This would be implemented with actual export logic
      // For now, it's just a placeholder
      await Future.delayed(const Duration(seconds: 1));

      state = state.copyWith(isLoading: false);
      return "Exported data.$format";
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Error exporting data: $e',
      );
      debugPrint('Error exporting data: $e');
      return null;
    }
  }
}

// Main provider for HomeState using StateNotifierProvider
final homeProvider = StateNotifierProvider<HomeNotifier, HomeState>((ref) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  return HomeNotifier(firestore);
});

// Individual providers for specific parts of the state
final showSideBarProvider = Provider<bool>((ref) {
  return ref.watch(homeProvider).showSideBar;
});

final selectedUserProvider = Provider<UserModel?>((ref) {
  return ref.watch(homeProvider).selectedUser;
});

final searchQueryProvider = StateProvider<String>((ref) {
  return ref.watch(homeProvider).searchQuery;
});

final currentPageProvider = StateProvider<int>((ref) {
  return ref.watch(homeProvider).currentPage;
});

final pageSizeProvider = StateProvider<int>((ref) {
  return ref.watch(homeProvider).pageSize;
});

final sortFieldProvider = StateProvider<String>((ref) {
  return ref.watch(homeProvider).sortField;
});

final sortDirectionProvider = StateProvider<bool>((ref) {
  return ref.watch(homeProvider).sortAscending;
});

final filterModeProvider = StateProvider<FilterMode>((ref) {
  return ref.watch(homeProvider).filterMode;
});

final locationFilterProvider = StateProvider<String?>((ref) {
  return ref.watch(homeProvider).locationFilter;
});

final isLoadingProvider = Provider<bool>((ref) {
  return ref.watch(homeProvider).isLoading;
});

final errorMessageProvider = Provider<String?>((ref) {
  return ref.watch(homeProvider).errorMessage;
});

// A provider to get all unique locations for filtering
final locationsProvider = StreamProvider<List<String>>((ref) {
  return FirebaseFirestore.instance
      .collection(FirebaseConstant.trustedUsers)
      .snapshots()
      .map((snapshot) {
    final locations = snapshot.docs
        .map((doc) => doc['location'] as String? ?? '')
        .where((location) => location.isNotEmpty)
        .toSet()
        .toList();
    locations.sort();
    return locations;
  });
});

// Stream provider for trusted users
final trustedUsersStreamProvider = StreamProvider<QuerySnapshot>((ref) {
  return FirebaseFirestore.instance
      .collection(FirebaseConstant.trustedUsers)
      .where("isTrusted", isEqualTo: true)
      .snapshots();
});

// Stream provider for untrusted users
final untrustedUsersStreamProvider = StreamProvider<QuerySnapshot>((ref) {
  return FirebaseFirestore.instance
      .collection(FirebaseConstant.trustedUsers)
      .where("isTrusted", isEqualTo: false)
      .snapshots();
});

// Stream provider for all users
final allUsersStreamProvider = StreamProvider<QuerySnapshot>((ref) {
  return FirebaseFirestore.instance
      .collection(FirebaseConstant.trustedUsers)
      .snapshots();
});

// Provider for all activities (admin view)
final allActivitiesProvider = StreamProvider<List<Activity>>((ref) {
  return FirebaseFirestore.instance
      .collection('activities')
      .orderBy('date', descending: true)
      .snapshots()
      .map((snapshot) =>
          snapshot.docs.map((doc) => Activity.fromFirestore(doc)).toList());
});
// Provider for public activities only (user view)
final publicActivitiesProvider = StreamProvider<List<Activity>>((ref) {
  try {
    // First, check if the collection exists
    return FirebaseFirestore.instance
        .collection('activities')
        .where('isPublic', isEqualTo: true)
        .orderBy('date', descending: true)
        .limit(5)
        .snapshots()
        .map((snapshot) {
      // Debug information
      print('Activities snapshot: ${snapshot.docs.length} documents');

      // Map documents to Activity objects with error handling
      final activities = <Activity>[];

      for (final doc in snapshot.docs) {
        try {
          final data = doc.data();

          // Verify required fields exist
          if (!data.containsKey('title') ||
              !data.containsKey('description') ||
              !data.containsKey('date')) {
            print('Document ${doc.id} missing required fields');
            continue;
          }

          // Convert to Activity object
          activities.add(Activity.fromFirestore(doc));
        } catch (e) {
          print('Error parsing document ${doc.id}: $e');
          // Skip this document but continue processing others
        }
      }

      return activities;
    });
  } catch (e) {
    // Fallback to an empty list if collection doesn't exist
    print('Error setting up activities stream: $e');
    return Stream.value([]);
  }
});

// Activity service for CRUD operations
class ActivityService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add a new activity
  Future<String> addActivity(Activity activity) async {
    try {
      final docRef =
          await _firestore.collection('activities').add(activity.toMap());

      return docRef.id;
    } catch (e) {
      throw Exception('Failed to add activity: $e');
    }
  }

  // Update an existing activity
  Future<void> updateActivity(Activity activity) async {
    try {
      await _firestore
          .collection('activities')
          .doc(activity.id)
          .update(activity.toMap());
    } catch (e) {
      throw Exception('Failed to update activity: $e');
    }
  }

  // Delete an activity
  Future<void> deleteActivity(String id) async {
    try {
      await _firestore.collection('activities').doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete activity: $e');
    }
  }

  // Toggle activity visibility
  Future<void> toggleActivityVisibility(String id, bool isPublic) async {
    try {
      await _firestore
          .collection('activities')
          .doc(id)
          .update({'isPublic': isPublic});
    } catch (e) {
      throw Exception('Failed to toggle activity visibility: $e');
    }
  }
}

// Provider for the activity service
final activityServiceProvider = Provider<ActivityService>((ref) {
  return ActivityService();
});

// Call this at app initialization
Future<void> ensureActivitiesCollectionExists() async {
  try {
    final snapshot = await FirebaseFirestore.instance
        .collection('activities')
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      // Create an initial activity
      await FirebaseFirestore.instance.collection('activities').add({
        'title': 'مرحباً بكم',
        'description': 'أهلاً بكم في موقعنا. سنقوم بنشر آخر التحديثات هنا.',
        'date': Timestamp.now(),
        'type': 'announcement',
        'createdBy': 'النظام',
        'isPublic': true,
      });

      print('Created initial activity');
    }
  } catch (e) {
    print('Error ensuring activities collection exists: $e');
  }
}
