import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trustedtallentsvalley/core/widgets/app_drawer.dart';
import 'package:trustedtallentsvalley/fetures/Home/widgets/search_bar.dart';
import 'package:trustedtallentsvalley/services/providers/service_provider.dart';
import 'package:trustedtallentsvalley/services/widgets/service_card.dart';

class ServicesListScreen extends ConsumerWidget {
  const ServicesListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final servicesStream = ref.watch(servicesStreamProvider);
    final searchQuery = ref.watch(servicesProvider).searchQuery;
    final categoryFilter = ref.watch(servicesProvider).categoryFilter;
    final notifier = ref.read(servicesProvider.notifier);
    final categories = ref.watch(serviceCategoriesProvider);

    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;
    final isMediumScreen = screenSize.width >= 600 && screenSize.width < 1100;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: isSmallScreen,
        title: Text(
          "اطلب خدمتك",
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.help_outline_rounded,
              color: Colors.white,
            ),
            onPressed: () => _showHelpDialog(context),
            tooltip: 'المساعدة',
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: isSmallScreen ? const AppDrawer() : null,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Side drawer for larger screens
              if (!isSmallScreen) const AppDrawer(isPermanent: true),

              // Main content
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Hero section
                      _buildHeroSection(context, isSmallScreen),
                      const SizedBox(height: 32),

                      // Search and filter
                      Row(
                        children: [
                          Expanded(
                            child: SearchField(
                              onChanged: (value) {
                                notifier.setSearchQuery(value);
                              },
                              hintText: 'ابحث عن خدمة...',
                            ),
                          ),
                          const SizedBox(width: 16),
                          _buildCategoryFilter(context, ref, categories)
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Services list
                      Expanded(
                        child: servicesStream.when(
                          data: (services) {
                            // Apply filtering based on search and category
                            final filteredServices = services.where((service) {
                              final matchesSearch = searchQuery.isEmpty ||
                                  service.title
                                      .toLowerCase()
                                      .contains(searchQuery.toLowerCase()) ||
                                  service.description
                                      .toLowerCase()
                                      .contains(searchQuery.toLowerCase());

                              final matchesCategory = categoryFilter == null ||
                                  service.category == categoryFilter;

                              return matchesSearch && matchesCategory;
                            }).toList();

                            if (filteredServices.isEmpty) {
                              return _buildEmptyState();
                            }

                            // Responsive grid based on screen size
                            return GridView.builder(
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: isSmallScreen
                                    ? 1
                                    : isMediumScreen
                                        ? 2
                                        : 3,
                                childAspectRatio: isSmallScreen ? 1.2 : 1.0,
                                crossAxisSpacing: 20,
                                mainAxisSpacing: 20,
                              ),
                              itemCount: filteredServices.length,
                              itemBuilder: (context, index) {
                                final service = filteredServices[index];
                                return ServiceCard(
                                  service: service,
                                  onTap: () {
                                    notifier.selectService(service);
                                    context.goNamed(
                                      'service_details',
                                      extra: service,
                                    );
                                  },
                                );
                              },
                            );
                          },
                          loading: () => const Center(
                            child: CircularProgressIndicator(),
                          ),
                          error: (error, stack) => Center(
                            child: Text(
                              'حدث خطأ أثناء تحميل الخدمات: $error',
                              style: GoogleFonts.cairo(color: Colors.red),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context, bool isSmallScreen) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isSmallScreen ? 24 : 32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.teal.shade700, Colors.teal.shade500],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'اطلب خدمتك الآن',
                      style: GoogleFonts.cairo(
                        fontSize: isSmallScreen ? 24 : 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'نقدم لك مجموعة من الخدمات المميزة والموثوقة. اختر الخدمة المناسبة لك واطلبها الآن وسيتم الرد عليك خلال ١٥ دقيقة',
                      style: GoogleFonts.cairo(
                        fontSize: isSmallScreen ? 14 : 16,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
              if (!isSmallScreen) ...[
                const SizedBox(width: 40),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.support_agent,
                    size: 80,
                    color: Colors.white,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _buildFeatureChip(context, 'خدمة سريعة', Icons.speed),
              _buildFeatureChip(context, 'رد خلال ١٥ دقيقة', Icons.timer),
              _buildFeatureChip(
                  context, 'دعم على مدار الساعة', Icons.support_agent),
              _buildFeatureChip(context, 'خدمات موثوقة', Icons.verified_user),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureChip(BuildContext context, String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.cairo(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter(BuildContext context, WidgetRef ref,
      AsyncValue<List<String>> categoriesAsync) {
    final currentFilter = ref.watch(servicesProvider).categoryFilter;
    final notifier = ref.read(servicesProvider.notifier);

    return PopupMenuButton<String?>(
      tooltip: 'تصفية حسب الفئة',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.filter_list, size: 20),
            const SizedBox(width: 8),
            Text(
              'تصفية',
              style: GoogleFonts.cairo(),
            ),
          ],
        ),
      ),
      itemBuilder: (context) {
        return [
          PopupMenuItem<String?>(
            value: null,
            child: Row(
              children: [
                Icon(
                  Icons.clear_all,
                  size: 18,
                  color: currentFilter == null ? Colors.teal : Colors.grey,
                ),
                const SizedBox(width: 8),
                Text('الكل', style: GoogleFonts.cairo()),
                const Spacer(),
                if (currentFilter == null)
                  const Icon(
                    Icons.check,
                    size: 18,
                    color: Colors.teal,
                  ),
              ],
            ),
          ),
          if (categoriesAsync.hasValue)
            ...categoriesAsync.value!.map((category) {
              return PopupMenuItem<String?>(
                value: category,
                child: Row(
                  children: [
                    Icon(
                      Icons.category,
                      size: 18,
                      color:
                          currentFilter == category ? Colors.teal : Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    Text(category, style: GoogleFonts.cairo()),
                    const Spacer(),
                    if (currentFilter == category)
                      const Icon(
                        Icons.check,
                        size: 18,
                        color: Colors.teal,
                      ),
                  ],
                ),
              );
            }),
        ];
      },
      onSelected: (value) {
        notifier.setCategoryFilter(value);
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'لم يتم العثور على خدمات',
            style: GoogleFonts.cairo(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'جرب البحث بكلمة مختلفة أو تصفح جميع الخدمات',
            style: GoogleFonts.cairo(
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.help_outline, color: Colors.teal),
            const SizedBox(width: 8),
            Text(
              'كيفية طلب الخدمة',
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHelpItem(
              title: 'اختر الخدمة',
              description:
                  'تصفح قائمة الخدمات واختر الخدمة التي تناسب احتياجاتك',
              number: 1,
            ),
            const SizedBox(height: 12),
            _buildHelpItem(
              title: 'قم بملء النموذج',
              description: 'أدخل بياناتك وتفاصيل طلبك في النموذج المخصص',
              number: 2,
            ),
            const SizedBox(height: 12),
            _buildHelpItem(
              title: 'انتظر الرد',
              description:
                  'سيتم الرد على طلبك في غضون 15 دقيقة من قبل فريق الدعم',
              number: 3,
            ),
            const SizedBox(height: 12),
            _buildHelpItem(
              title: 'متابعة الحالة',
              description: 'يمكنك متابعة حالة طلبك من خلال صفحة "طلباتي"',
              number: 4,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'فهمت',
              style: GoogleFonts.cairo(
                color: Colors.teal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpItem({
    required String title,
    required String description,
    required int number,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: Colors.teal,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number.toString(),
              style: GoogleFonts.cairo(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                description,
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
