import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trustedtallentsvalley/core/widgets/app_drawer.dart';
import 'package:trustedtallentsvalley/fetures/services/auth_service.dart';
import 'package:trustedtallentsvalley/fetures/services/service_model.dart';

import '../../../fetures/services/providers/service_provider.dart';

class AdminServicesScreen extends ConsumerWidget {
  const AdminServicesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAdmin = ref.watch(isAdminProvider);
    final servicesStream = ref.watch(servicesStreamProvider);
    final screenSize = MediaQuery.of(context).size;

    // Define breakpoints
    final isMobile = screenSize.width < 768;
    final isTablet = screenSize.width >= 768 && screenSize.width < 1024;
    final isDesktop = screenSize.width >= 1024;

    if (!isAdmin) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.security,
                size: 64,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                'يجب أن تكون مشرفاً للوصول إلى هذه الصفحة',
                style: GoogleFonts.cairo(
                  fontSize: 18,
                  color: Colors.grey.shade700,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: _buildAppBar(context, ref, isMobile),
      drawer: isMobile ? const AppDrawer() : null,
      floatingActionButton: isMobile
          ? FloatingActionButton(
              onPressed: () => _showAddServiceDialog(context, ref),
              backgroundColor: Colors.teal,
              child: const Icon(Icons.add),
            )
          : null,
      body: isMobile
          ? _buildMobileLayout(context, ref, servicesStream)
          : _buildWebLayout(context, ref, servicesStream, isDesktop),
    );
  }

  PreferredSizeWidget _buildAppBar(
      BuildContext context, WidgetRef ref, bool isMobile) {
    if (isMobile) {
      // Mobile: Traditional mobile app bar
      return AppBar(
        title: Text(
          'إدارة الخدمات',
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.teal,
        elevation: 2,
      );
    } else {
      // Web: Enhanced app bar
      return AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.business_center,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'إدارة الخدمات',
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 20,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.teal,
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ElevatedButton.icon(
              onPressed: () => _showAddServiceDialog(context, ref),
              icon: const Icon(Icons.add, size: 18),
              label: Text('إضافة خدمة جديدة', style: GoogleFonts.cairo()),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.teal,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
        ),
      );
    }
  }

  Widget _buildMobileLayout(BuildContext context, WidgetRef ref,
      AsyncValue<List<ServiceModel>> servicesStream) {
    return servicesStream.when(
      data: (services) => _buildMobileContent(context, ref, services),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => _buildErrorState(context, error),
    );
  }

  Widget _buildWebLayout(BuildContext context, WidgetRef ref,
      AsyncValue<List<ServiceModel>> servicesStream, bool isDesktop) {
    final maxWidth = isDesktop ? 1400.0 : 1000.0;

    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: servicesStream.when(
          data: (services) =>
              _buildWebContent(context, ref, services, isDesktop),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => _buildErrorState(context, error),
        ),
      ),
    );
  }

  Widget _buildMobileContent(
      BuildContext context, WidgetRef ref, List<ServiceModel> services) {
    if (services.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        // Mobile header
        Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.teal.shade50, Colors.teal.shade100],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.teal.shade200),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.teal.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.business_center,
                  color: Colors.teal.shade700,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'إدارة الخدمات',
                      style: GoogleFonts.cairo(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal.shade700,
                      ),
                    ),
                    Text(
                      '${services.length} خدمة متاحة',
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        color: Colors.teal.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Services list
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: services.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final service = services[index];
              return _buildMobileServiceCard(context, ref, service);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildWebContent(BuildContext context, WidgetRef ref,
      List<ServiceModel> services, bool isDesktop) {
    if (services.isEmpty) {
      return _buildEmptyState();
    }

    return Padding(
      padding: EdgeInsets.all(isDesktop ? 32.0 : 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWebHeader(context, ref, services.length, isDesktop),
          const SizedBox(height: 32),
          Expanded(
            child: isDesktop
                ? _buildDesktopGrid(context, ref, services)
                : _buildTabletList(context, ref, services),
          ),
        ],
      ),
    );
  }

  // Mobile-specific widgets
  Widget _buildMobileServiceCard(
      BuildContext context, WidgetRef ref, ServiceModel service) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Service icon
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.teal.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: service.imageUrl.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            service.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                _getCategoryIcon(service.category.name),
                                size: 25,
                                color: Colors.teal,
                              );
                            },
                          ),
                        )
                      : Icon(
                          _getCategoryIcon(service.category.name),
                          size: 25,
                          color: Colors.teal,
                        ),
                ),
                const SizedBox(width: 12),

                // Title and category
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        service.title,
                        style: GoogleFonts.cairo(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          service.category.displayName,
                          style: GoogleFonts.cairo(
                            fontSize: 11,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Actions
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () =>
                          _showEditServiceDialog(context, ref, service),
                      icon: const Icon(Icons.edit, size: 20),
                      tooltip: 'تعديل',
                      color: Colors.blue,
                      constraints:
                          const BoxConstraints(minWidth: 40, minHeight: 40),
                      padding: const EdgeInsets.all(8),
                    ),
                    IconButton(
                      onPressed: () =>
                          _showDeleteConfirmation(context, ref, service),
                      icon: const Icon(Icons.delete, size: 20),
                      tooltip: 'حذف',
                      color: Colors.red,
                      constraints:
                          const BoxConstraints(minWidth: 40, minHeight: 40),
                      padding: const EdgeInsets.all(8),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Description
            Text(
              service.description,
              style: GoogleFonts.cairo(
                fontSize: 14,
                color: Colors.grey.shade600,
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 12),

            // Price and delivery info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '\$${service.price.toStringAsFixed(2)}',
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.bold,
                    color: Colors.teal.shade700,
                    fontSize: 16,
                  ),
                ),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 14,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${service.deliveryTimeInDays} أيام',
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Web-specific widgets
  Widget _buildWebHeader(
      BuildContext context, WidgetRef ref, int servicesCount, bool isDesktop) {
    return Container(
      padding: EdgeInsets.all(isDesktop ? 32.0 : 24.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.teal.shade600, Colors.teal.shade500],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.teal.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'إدارة الخدمات',
                  style: GoogleFonts.cairo(
                    color: Colors.white,
                    fontSize: isDesktop ? 28 : 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'يمكنك إدارة جميع الخدمات المتاحة في النظام وإضافة خدمات جديدة',
                  style: GoogleFonts.cairo(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              _buildStatCard('إجمالي الخدمات', servicesCount.toString(),
                  Icons.business_center),
              const SizedBox(height: 12),
              _buildStatCard(
                  'النشطة', servicesCount.toString(), Icons.check_circle),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.cairo(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.cairo(
              color: Colors.white.withOpacity(0.8),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopGrid(
      BuildContext context, WidgetRef ref, List<ServiceModel> services) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 400,
        childAspectRatio: 1.1,
        crossAxisSpacing: 24,
        mainAxisSpacing: 24,
      ),
      itemCount: services.length,
      itemBuilder: (context, index) {
        final service = services[index];
        return _buildDesktopServiceCard(context, ref, service);
      },
    );
  }

  Widget _buildTabletList(
      BuildContext context, WidgetRef ref, List<ServiceModel> services) {
    return ListView.separated(
      itemCount: services.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final service = services[index];
        return _buildTabletServiceCard(context, ref, service);
      },
    );
  }

  Widget _buildDesktopServiceCard(
      BuildContext context, WidgetRef ref, ServiceModel service) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              // Could implement service details view
            },
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with icon and actions
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.teal.shade400,
                              Colors.teal.shade600
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _getCategoryIcon(service.category.name),
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const Spacer(),
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'edit') {
                            _showEditServiceDialog(context, ref, service);
                          } else if (value == 'delete') {
                            _showDeleteConfirmation(context, ref, service);
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                const Icon(Icons.edit,
                                    size: 18, color: Colors.blue),
                                const SizedBox(width: 8),
                                Text('تعديل', style: GoogleFonts.cairo()),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                const Icon(Icons.delete,
                                    size: 18, color: Colors.red),
                                const SizedBox(width: 8),
                                Text('حذف', style: GoogleFonts.cairo()),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Category
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.teal.shade50,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      service.category.displayName,
                      style: GoogleFonts.cairo(
                        color: Colors.teal.shade700,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Title
                  Text(
                    service.title,
                    style: GoogleFonts.cairo(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 8),

                  // Description
                  Expanded(
                    child: Text(
                      service.description,
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        height: 1.5,
                        color: Colors.grey.shade600,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Price and delivery
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${service.price.toStringAsFixed(2)}',
                        style: GoogleFonts.cairo(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal.shade700,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 14,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${service.deliveryTimeInDays} أيام',
                              style: GoogleFonts.cairo(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabletServiceCard(
      BuildContext context, WidgetRef ref, ServiceModel service) {
    return Container(
      padding: const EdgeInsets.all(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Service icon
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.teal.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: service.imageUrl.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      service.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          _getCategoryIcon(service.category.name),
                          size: 30,
                          color: Colors.teal,
                        );
                      },
                    ),
                  )
                : Icon(
                    _getCategoryIcon(service.category.name),
                    size: 30,
                    color: Colors.teal,
                  ),
          ),
          const SizedBox(width: 16),

          // Service info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        service.category.displayName,
                        style: GoogleFonts.cairo(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '\$${service.price.toStringAsFixed(2)}',
                      style: GoogleFonts.cairo(
                        fontWeight: FontWeight.bold,
                        color: Colors.teal.shade700,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  service.title,
                  style: GoogleFonts.cairo(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  service.description,
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${service.deliveryTimeInDays} أيام',
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Actions
          Column(
            children: [
              IconButton(
                onPressed: () => _showEditServiceDialog(context, ref, service),
                icon: const Icon(Icons.edit),
                tooltip: 'تعديل',
                color: Colors.blue,
              ),
              IconButton(
                onPressed: () => _showDeleteConfirmation(context, ref, service),
                icon: const Icon(Icons.delete),
                tooltip: 'حذف',
                color: Colors.red,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Shared widgets
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.business_center,
              size: 64,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'لا توجد خدمات حالياً',
            style: GoogleFonts.cairo(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'قم بإضافة خدمات جديدة بالضغط على زر "إضافة خدمة جديدة"',
            style: GoogleFonts.cairo(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 48),
          const SizedBox(height: 16),
          Text(
            'حدث خطأ أثناء تحميل الخدمات',
            style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            style: GoogleFonts.cairo(color: Colors.grey.shade700, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Dialog methods (keeping existing functionality)
  void _showAddServiceDialog(BuildContext context, WidgetRef ref) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final categoryController = TextEditingController();
    final priceController = TextEditingController();
    final timeController = TextEditingController();
    final imageUrlController = TextEditingController();
    bool isLoading = false;

    final notifier = ref.read(servicesProvider.notifier);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.add_circle, color: Colors.teal),
              const SizedBox(width: 8),
              Text(
                'إضافة خدمة جديدة',
                style: GoogleFonts.cairo(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: isMobile ? double.maxFinite : 500,
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: titleController,
                      decoration: InputDecoration(
                        labelText: 'عنوان الخدمة',
                        labelStyle: GoogleFonts.cairo(),
                        hintText: 'أدخل عنوان الخدمة',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.title),
                      ),
                      style: GoogleFonts.cairo(),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'يرجى إدخال عنوان الخدمة';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: descriptionController,
                      decoration: InputDecoration(
                        labelText: 'وصف الخدمة',
                        labelStyle: GoogleFonts.cairo(),
                        hintText: 'أدخل وصف الخدمة',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignLabelWithHint: true,
                        prefixIcon: const Icon(Icons.description),
                      ),
                      style: GoogleFonts.cairo(),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'يرجى إدخال وصف الخدمة';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: categoryController,
                      decoration: InputDecoration(
                        labelText: 'التصنيف',
                        labelStyle: GoogleFonts.cairo(),
                        hintText: 'مثال: برمجة، تسويق، تصميم',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.category),
                      ),
                      style: GoogleFonts.cairo(),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'يرجى إدخال التصنيف';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: priceController,
                            decoration: InputDecoration(
                              labelText: 'السعر',
                              labelStyle: GoogleFonts.cairo(),
                              hintText: 'أدخل السعر',
                              prefixText: '\'',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              prefixIcon: const Icon(Icons.attach_money),
                            ),
                            style: GoogleFonts.cairo(),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'يرجى إدخال السعر';
                              }
                              try {
                                double.parse(value);
                              } catch (e) {
                                return 'سعر غير صحيح';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: timeController,
                            decoration: InputDecoration(
                              labelText: 'أيام التنفيذ',
                              labelStyle: GoogleFonts.cairo(),
                              hintText: 'مثال: 3',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              prefixIcon: const Icon(Icons.access_time),
                            ),
                            style: GoogleFonts.cairo(),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'يرجى إدخال أيام التنفيذ';
                              }
                              try {
                                int.parse(value);
                              } catch (e) {
                                return 'رقم غير صحيح';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: imageUrlController,
                      decoration: InputDecoration(
                        labelText: 'رابط الصورة (اختياري)',
                        labelStyle: GoogleFonts.cairo(),
                        hintText: 'أدخل رابط صورة الخدمة',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.image),
                      ),
                      style: GoogleFonts.cairo(),
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.pop(context),
              child: Text(
                'إلغاء',
                style: GoogleFonts.cairo(),
              ),
            ),
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      if (formKey.currentState!.validate()) {
                        setState(() {
                          isLoading = true;
                        });

                        final service = ServiceModel(
                          isActive: true,
                          deliveryTimeInDays: int.parse(timeController.text),
                          additionalDetails: {},
                          id: '',
                          title: titleController.text,
                          description: descriptionController.text,
                          category: ServiceCategory.other,
                          price: double.parse(priceController.text),
                          imageUrl: imageUrlController.text,
                          createdAt: Timestamp.fromDate(DateTime.now()),
                        );

                        final success = await notifier.addService(service);
                        await ref
                            .read(servicesProvider.notifier)
                            .loadServices();

                        if (success && context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  const Icon(Icons.check_circle,
                                      color: Colors.white),
                                  const SizedBox(width: 8),
                                  Text('تمت إضافة الخدمة بنجاح',
                                      style: GoogleFonts.cairo()),
                                ],
                              ),
                              backgroundColor: Colors.green,
                            ),
                          );
                        } else if (context.mounted) {
                          setState(() {
                            isLoading = false;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('حدث خطأ أثناء إضافة الخدمة',
                                  style: GoogleFonts.cairo()),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      'إضافة',
                      style: GoogleFonts.cairo(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  void _showEditServiceDialog(
      BuildContext context, WidgetRef ref, ServiceModel service) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController(text: service.title);
    final descriptionController =
        TextEditingController(text: service.description);
    final categoryController =
        TextEditingController(text: service.category.displayName);
    final priceController =
        TextEditingController(text: service.price.toString());
    final timeController =
        TextEditingController(text: service.deliveryTimeInDays.toString());
    final imageUrlController = TextEditingController(text: service.imageUrl);
    bool isLoading = false;

    final notifier = ref.read(servicesProvider.notifier);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.edit, color: Colors.blue),
              const SizedBox(width: 8),
              Text(
                'تعديل الخدمة',
                style: GoogleFonts.cairo(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: isMobile ? double.maxFinite : 500,
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: titleController,
                      decoration: InputDecoration(
                        labelText: 'عنوان الخدمة',
                        labelStyle: GoogleFonts.cairo(),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.title),
                      ),
                      style: GoogleFonts.cairo(),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'يرجى إدخال عنوان الخدمة';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: descriptionController,
                      decoration: InputDecoration(
                        labelText: 'وصف الخدمة',
                        labelStyle: GoogleFonts.cairo(),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignLabelWithHint: true,
                        prefixIcon: const Icon(Icons.description),
                      ),
                      style: GoogleFonts.cairo(),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'يرجى إدخال وصف الخدمة';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: categoryController,
                      decoration: InputDecoration(
                        labelText: 'التصنيف',
                        labelStyle: GoogleFonts.cairo(),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.category),
                      ),
                      style: GoogleFonts.cairo(),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'يرجى إدخال التصنيف';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: priceController,
                            decoration: InputDecoration(
                              labelText: 'السعر',
                              labelStyle: GoogleFonts.cairo(),
                              prefixText: '\'',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              prefixIcon: const Icon(Icons.attach_money),
                            ),
                            style: GoogleFonts.cairo(),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'يرجى إدخال السعر';
                              }
                              try {
                                double.parse(value);
                              } catch (e) {
                                return 'سعر غير صحيح';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: timeController,
                            decoration: InputDecoration(
                              labelText: 'أيام التنفيذ',
                              labelStyle: GoogleFonts.cairo(),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              prefixIcon: const Icon(Icons.access_time),
                            ),
                            style: GoogleFonts.cairo(),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'يرجى إدخال أيام التنفيذ';
                              }
                              try {
                                int.parse(value);
                              } catch (e) {
                                return 'رقم غير صحيح';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: imageUrlController,
                      decoration: InputDecoration(
                        labelText: 'رابط الصورة (اختياري)',
                        labelStyle: GoogleFonts.cairo(),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.image),
                      ),
                      style: GoogleFonts.cairo(),
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.pop(context),
              child: Text(
                'إلغاء',
                style: GoogleFonts.cairo(),
              ),
            ),
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      if (formKey.currentState!.validate()) {
                        setState(() {
                          isLoading = true;
                        });

                        final updatedService = service.copyWith(
                          title: titleController.text,
                          description: descriptionController.text,
                          price: double.parse(priceController.text),
                          // deliveryTimeInDays: int.parse(timeController.text),
                          imageUrl: imageUrlController.text,
                        );

                        final success =
                            await notifier.updateService(updatedService);

                        if (success && context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  const Icon(Icons.check_circle,
                                      color: Colors.white),
                                  const SizedBox(width: 8),
                                  Text('تم تحديث الخدمة بنجاح',
                                      style: GoogleFonts.cairo()),
                                ],
                              ),
                              backgroundColor: Colors.green,
                            ),
                          );
                        } else if (context.mounted) {
                          setState(() {
                            isLoading = false;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('حدث خطأ أثناء تحديث الخدمة',
                                  style: GoogleFonts.cairo()),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      'تحديث',
                      style: GoogleFonts.cairo(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(
      BuildContext context, WidgetRef ref, ServiceModel service) {
    final notifier = ref.read(servicesProvider.notifier);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.warning, color: Colors.red),
            const SizedBox(width: 8),
            Text(
              'تأكيد الحذف',
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'هل أنت متأكد من رغبتك في حذف هذه الخدمة؟',
              style: GoogleFonts.cairo(),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    _getCategoryIcon(service.category.name),
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          service.title,
                          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '\${service.price.toStringAsFixed(2)}',
                          style: GoogleFonts.cairo(
                            color: Colors.grey.shade700,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'هذا الإجراء لا يمكن التراجع عنه.',
              style: GoogleFonts.cairo(
                color: Colors.red.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'إلغاء',
              style: GoogleFonts.cairo(),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final success = await notifier.deleteService(service.id);

              if (success) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.white),
                        const SizedBox(width: 8),
                        Text('تم حذف الخدمة بنجاح', style: GoogleFonts.cairo()),
                      ],
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('حدث خطأ أثناء حذف الخدمة',
                        style: GoogleFonts.cairo()),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(
              'حذف',
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'برمجة':
      case 'programming':
      case 'webdevelopment':
        return Icons.code;
      case 'تصميم':
      case 'design':
      case 'graphicdesign':
        return Icons.design_services;
      case 'تسويق':
      case 'marketing':
        return Icons.campaign;
      case 'كتابة':
      case 'writing':
        return Icons.edit_note;
      case 'ترجمة':
      case 'translation':
        return Icons.translate;
      case 'استشارات':
        return Icons.support_agent;
      case 'فيديو':
        return Icons.videocam;
      case 'صوت':
        return Icons.mic;
      case 'mobiledevelopment':
        return Icons.phone_android;
      default:
        return Icons.miscellaneous_services;
    }
  }
}
