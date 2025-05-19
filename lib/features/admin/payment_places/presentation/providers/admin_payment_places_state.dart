import '../../domain/entities/admin_payment_place.dart';
import '../../domain/repositories/admin_payment_places_repository.dart';

class AdminPaymentPlacesState {
  final bool showSideBar;
  final AdminPaymentPlace? selectedPlace;
  final String searchQuery;
  final int currentPage;
  final int pageSize;
  final String sortField;
  final bool sortAscending;
  final AdminPlacesFilterMode filterMode;
  final String? categoryFilter;
  final String? locationFilter;
  final bool isLoading;
  final String? errorMessage;
  final bool isExporting;

  AdminPaymentPlacesState({
    this.showSideBar = false,
    this.selectedPlace,
    this.searchQuery = '',
    this.currentPage = 1,
    this.pageSize = 10,
    this.sortField = 'name',
    this.sortAscending = true,
    this.filterMode = AdminPlacesFilterMode.all,
    this.categoryFilter,
    this.locationFilter,
    this.isLoading = false,
    this.errorMessage,
    this.isExporting = false,
  });

  AdminPaymentPlacesState copyWith({
    bool? showSideBar,
    AdminPaymentPlace? selectedPlace,
    String? searchQuery,
    int? currentPage,
    int? pageSize,
    String? sortField,
    bool? sortAscending,
    AdminPlacesFilterMode? filterMode,
    String? categoryFilter,
    String? locationFilter,
    bool? isLoading,
    String? errorMessage,
    bool? isExporting,
  }) {
    return AdminPaymentPlacesState(
      showSideBar: showSideBar ?? this.showSideBar,
      selectedPlace: selectedPlace ?? this.selectedPlace,
      searchQuery: searchQuery ?? this.searchQuery,
      currentPage: currentPage ?? this.currentPage,
      pageSize: pageSize ?? this.pageSize,
      sortField: sortField ?? this.sortField,
      sortAscending: sortAscending ?? this.sortAscending,
      filterMode: filterMode ?? this.filterMode,
      categoryFilter: categoryFilter ?? this.categoryFilter,
      locationFilter: locationFilter ?? this.locationFilter,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      isExporting: isExporting ?? this.isExporting,
    );
  }
}