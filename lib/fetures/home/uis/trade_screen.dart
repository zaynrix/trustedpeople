import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trustedtallentsvalley/core/widgets/app_drawer.dart';
import 'package:trustedtallentsvalley/fetures/services/auth_service.dart';

// Provider for protection tips from Firestore
final protectionTipsProvider = StreamProvider<List<ProtectionTip>>((ref) {
  return FirebaseFirestore.instance
      .collection('protectionTips')
      .orderBy('order')
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => ProtectionTip.fromFirestore(doc))
          .toList());
});

// Protection tip model
class ProtectionTip {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final int order;

  ProtectionTip({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.order,
  });

  factory ProtectionTip.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Convert string icon name to IconData
    final iconName = data['icon'] ?? 'shield';
    final IconData iconData = _getIconFromString(iconName);

    return ProtectionTip(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      icon: iconData,
      order: (data['order'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'icon': _getStringFromIcon(icon),
      'order': order,
    };
  }

  static IconData _getIconFromString(String iconName) {
    switch (iconName) {
      case 'money':
        return Icons.money_off;
      case 'verify':
        return Icons.verified_user;
      case 'warning':
        return Icons.warning;
      case 'security':
        return Icons.security;
      case 'lock':
        return Icons.lock;
      case 'person':
        return Icons.person_off;
      default:
        return Icons.shield;
    }
  }

  static String _getStringFromIcon(IconData icon) {
    if (icon == Icons.money_off) return 'money';
    if (icon == Icons.verified_user) return 'verify';
    if (icon == Icons.warning) return 'warning';
    if (icon == Icons.security) return 'security';
    if (icon == Icons.lock) return 'lock';
    if (icon == Icons.person_off) return 'person';
    return 'shield';
  }
}

class ProtectionGuideScreen extends ConsumerWidget {
  const ProtectionGuideScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tipsAsync = ref.watch(protectionTipsProvider);
    final isAdmin = ref.watch(isAdminProvider);
    final size = MediaQuery.of(context).size;

    // Define breakpoints
    final isMobile = size.width < 768;
    final isTablet = size.width >= 768 && size.width < 1024;
    final isDesktop = size.width >= 1024;

    return Scaffold(
      appBar: _buildAppBar(context, ref, isMobile, isAdmin),
      drawer: isMobile ? const AppDrawer() : null,
      floatingActionButton: isAdmin && isMobile
          ? FloatingActionButton(
              onPressed: () => _showAddEditTipDialog(context, ref),
              backgroundColor: Colors.green.shade700,
              tooltip: 'إضافة نصيحة جديدة',
              child: const Icon(Icons.add),
            )
          : null,
      body: isMobile
          ? _buildMobileLayout(context, ref, tipsAsync)
          : _buildWebLayout(context, ref, tipsAsync, isDesktop),
    );
  }

  PreferredSizeWidget _buildAppBar(
      BuildContext context, WidgetRef ref, bool isMobile, bool isAdmin) {
    if (isMobile) {
      // Mobile: Traditional mobile app bar
      return AppBar(
        backgroundColor: isAdmin ? Colors.green.shade700 : Colors.teal,
        title: Text(
          'كيف تحمي نفسك؟',
          style: GoogleFonts.cairo(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 2,
      );
    } else {
      // Web: Enhanced app bar
      return AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: isAdmin ? Colors.green.shade700 : Colors.teal,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.security,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'دليل الحماية من النصب والاحتيال',
              style: GoogleFonts.cairo(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          if (isAdmin)
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ElevatedButton.icon(
                onPressed: () => _showAddEditTipDialog(context, ref),
                icon: const Icon(Icons.add, size: 18),
                label: Text('إضافة نصيحة', style: GoogleFonts.cairo()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.green.shade700,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          const SizedBox(width: 16),
        ],
        elevation: 0,
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
      AsyncValue<List<ProtectionTip>> tipsAsync) {
    return tipsAsync.when(
      data: (tips) => _buildMobileContent(context, ref, tips),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => _buildErrorState(context, error),
    );
  }

  Widget _buildWebLayout(BuildContext context, WidgetRef ref,
      AsyncValue<List<ProtectionTip>> tipsAsync, bool isDesktop) {
    final maxWidth = isDesktop ? 1200.0 : 900.0;

    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: tipsAsync.when(
          data: (tips) => _buildWebContent(context, ref, tips, isDesktop),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => _buildErrorState(context, error),
        ),
      ),
    );
  }

  Widget _buildMobileContent(
      BuildContext context, WidgetRef ref, List<ProtectionTip> tips) {
    if (tips.isEmpty) {
      return _buildEmptyState();
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMobileHeader(),
            const SizedBox(height: 24),
            _buildMobileTipsList(context, ref, tips),
          ],
        ),
      ),
    );
  }

  Widget _buildWebContent(BuildContext context, WidgetRef ref,
      List<ProtectionTip> tips, bool isDesktop) {
    if (tips.isEmpty) {
      return _buildEmptyState();
    }

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(isDesktop ? 32.0 : 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWebHeader(context, ref, tips.length, isDesktop),
            const SizedBox(height: 48),
            _buildWebTipsGrid(context, ref, tips, isDesktop),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // Mobile-specific widgets
  Widget _buildMobileHeader() {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade50, Colors.blue.shade100],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.security,
                  color: Colors.blue.shade700,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'احمِ نفسك من النصب',
                  style: GoogleFonts.cairo(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'تعلم كيفية حماية نفسك من عمليات النصب والاحتيال من خلال هذه النصائح المهمة',
            style: GoogleFonts.cairo(
              fontSize: 14,
              color: Colors.blue.shade800,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileTipsList(
      BuildContext context, WidgetRef ref, List<ProtectionTip> tips) {
    final isAdmin = ref.watch(isAdminProvider);

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: tips.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final tip = tips[index];
        return _buildMobileTipCard(context, ref, tip, isAdmin);
      },
    );
  }

  Widget _buildMobileTipCard(
      BuildContext context, WidgetRef ref, ProtectionTip tip, bool isAdmin) {
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
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    tip.icon,
                    color: Colors.blue.shade700,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tip.title,
                        style: GoogleFonts.cairo(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        tip.description,
                        style: GoogleFonts.cairo(
                          fontSize: 14,
                          height: 1.5,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (isAdmin) ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () => _showAddEditTipDialog(context, ref, tip),
                    icon: const Icon(Icons.edit, size: 16),
                    label: Text('تعديل', style: GoogleFonts.cairo()),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.blue,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => _showDeleteConfirmation(context, ref, tip),
                    icon: const Icon(Icons.delete, size: 16),
                    label: Text('حذف', style: GoogleFonts.cairo()),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Web-specific widgets
  Widget _buildWebHeader(
      BuildContext context, WidgetRef ref, int tipsCount, bool isDesktop) {
    final isAdmin = ref.watch(isAdminProvider);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isDesktop ? 40.0 : 32.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blue.shade600,
            Colors.blue.shade500,
            Colors.teal.shade500,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.verified_user,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'دليل شامل للحماية',
                        style: GoogleFonts.cairo(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: isDesktop ? 24 : 16),
                Text(
                  'دليل الحماية من النصب والاحتيال',
                  style: GoogleFonts.cairo(
                    color: Colors.white,
                    fontSize: isDesktop ? 32 : 26,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
                SizedBox(height: isDesktop ? 16 : 12),
                Text(
                  'تعلم كيفية حماية نفسك ومالك من عمليات النصب والاحتيال من خلال هذه النصائح والإرشادات المهمة التي تساعدك على التعرف على المحتالين وتجنب الوقوع في فخاخهم.',
                  style: GoogleFonts.cairo(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: isDesktop ? 16 : 14,
                    height: 1.6,
                  ),
                ),
                SizedBox(height: isDesktop ? 32 : 24),
                Wrap(
                  spacing: 16,
                  runSpacing: 12,
                  children: [
                    _buildWebActionButton(
                      label: 'ابدأ القراءة',
                      icon: Icons.arrow_downward,
                      isPrimary: true,
                      onPressed: () {
                        // Scroll to tips section
                        Scrollable.ensureVisible(
                          context,
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeInOut,
                        );
                      },
                    ),
                    if (isAdmin)
                      _buildWebActionButton(
                        label: 'إدارة النصائح',
                        icon: Icons.settings,
                        isPrimary: false,
                        onPressed: () => _showAddEditTipDialog(context, ref),
                      ),
                  ],
                ),
              ],
            ),
          ),
          if (isDesktop) ...[
            const SizedBox(width: 48),
            Expanded(
              flex: 2,
              child: Container(
                height: 300,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.security,
                        color: Colors.white,
                        size: 80,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      '$tipsCount نصيحة مهمة',
                      style: GoogleFonts.cairo(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'لحمايتك من النصب',
                      style: GoogleFonts.cairo(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildWebActionButton({
    required String label,
    required IconData icon,
    required bool isPrimary,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        boxShadow: isPrimary
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(
          label,
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary ? Colors.white : Colors.transparent,
          foregroundColor: isPrimary ? Colors.blue.shade700 : Colors.white,
          side: isPrimary ? null : const BorderSide(color: Colors.white),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  Widget _buildWebTipsGrid(BuildContext context, WidgetRef ref,
      List<ProtectionTip> tips, bool isDesktop) {
    final isAdmin = ref.watch(isAdminProvider);
    final crossAxisCount = isDesktop ? 3 : 2;
    final childAspectRatio = isDesktop ? 1.2 : 1.1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'نصائح الحماية',
              style: GoogleFonts.cairo(
                fontSize: isDesktop ? 28 : 22,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            if (isAdmin)
              OutlinedButton.icon(
                onPressed: () => _showAddEditTipDialog(context, ref),
                icon: const Icon(Icons.add),
                label: Text('إضافة نصيحة جديدة', style: GoogleFonts.cairo()),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'اتبع هذه النصائح لتحمي نفسك من عمليات النصب والاحتيال',
          style: GoogleFonts.cairo(
            fontSize: 16,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 32),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: childAspectRatio,
            crossAxisSpacing: 24,
            mainAxisSpacing: 24,
          ),
          itemCount: tips.length,
          itemBuilder: (context, index) {
            final tip = tips[index];
            return _buildWebTipCard(context, ref, tip, isAdmin, isDesktop);
          },
        ),
      ],
    );
  }

  Widget _buildWebTipCard(BuildContext context, WidgetRef ref,
      ProtectionTip tip, bool isAdmin, bool isDesktop) {
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
              // Could show detailed view or expand functionality
            },
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon and number
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.blue.shade400,
                              Colors.blue.shade600
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          tip.icon,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${tip.order + 1}',
                          style: GoogleFonts.cairo(
                            color: Colors.blue.shade700,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Title
                  Text(
                    tip.title,
                    style: GoogleFonts.cairo(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),

                  // Description
                  Expanded(
                    child: Text(
                      tip.description,
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        height: 1.5,
                        color: Colors.grey.shade600,
                      ),
                      maxLines: isDesktop ? 4 : 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  // Admin actions
                  if (isAdmin) ...[
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () =>
                                _showAddEditTipDialog(context, ref, tip),
                            icon: const Icon(Icons.edit, size: 16),
                            label: Text('تعديل',
                                style: GoogleFonts.cairo(fontSize: 12)),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.blue,
                              side: BorderSide(color: Colors.blue.shade300),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () =>
                                _showDeleteConfirmation(context, ref, tip),
                            icon: const Icon(Icons.delete, size: 16),
                            label: Text('حذف',
                                style: GoogleFonts.cairo(fontSize: 12)),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              side: BorderSide(color: Colors.red.shade300),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
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
              Icons.security,
              size: 64,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'لا توجد نصائح متاحة حالياً',
            style: GoogleFonts.cairo(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'سيتم إضافة نصائح الحماية قريباً',
            style: GoogleFonts.cairo(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
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
            'حدث خطأ أثناء تحميل النصائح',
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

  // Dialog methods
  void _showAddEditTipDialog(BuildContext context, WidgetRef ref,
      [ProtectionTip? existingTip]) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    final isEditing = existingTip != null;
    final titleController = TextEditingController(
      text: isEditing ? existingTip.title : '',
    );
    final descriptionController = TextEditingController(
      text: isEditing ? existingTip.description : '',
    );

    IconData selectedIcon = isEditing ? existingTip.icon : Icons.shield;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                isEditing ? 'تعديل نصيحة' : 'إضافة نصيحة جديدة',
                style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
              ),
              content: SizedBox(
                width: isMobile ? double.maxFinite : 500,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: titleController,
                        decoration: InputDecoration(
                          labelText: 'العنوان',
                          labelStyle: GoogleFonts.cairo(),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        style: GoogleFonts.cairo(),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: descriptionController,
                        decoration: InputDecoration(
                          labelText: 'الوصف',
                          labelStyle: GoogleFonts.cairo(),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        style: GoogleFonts.cairo(),
                        maxLines: 5,
                      ),
                      const SizedBox(height: 16),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          'الأيقونة:',
                          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          _buildIconOption(Icons.shield, selectedIcon, (icon) {
                            setState(() => selectedIcon = icon);
                          }),
                          _buildIconOption(Icons.money_off, selectedIcon,
                              (icon) {
                            setState(() => selectedIcon = icon);
                          }),
                          _buildIconOption(Icons.verified_user, selectedIcon,
                              (icon) {
                            setState(() => selectedIcon = icon);
                          }),
                          _buildIconOption(Icons.warning, selectedIcon, (icon) {
                            setState(() => selectedIcon = icon);
                          }),
                          _buildIconOption(Icons.security, selectedIcon,
                              (icon) {
                            setState(() => selectedIcon = icon);
                          }),
                          _buildIconOption(Icons.lock, selectedIcon, (icon) {
                            setState(() => selectedIcon = icon);
                          }),
                          _buildIconOption(Icons.person_off, selectedIcon,
                              (icon) {
                            setState(() => selectedIcon = icon);
                          }),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('إلغاء', style: GoogleFonts.cairo()),
                ),
                ElevatedButton(
                  onPressed: () {
                    final title = titleController.text.trim();
                    final description = descriptionController.text.trim();

                    if (title.isEmpty || description.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('يرجى ملء جميع الحقول',
                              style: GoogleFonts.cairo()),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    if (isEditing) {
                      _updateTip(
                        existingTip.id,
                        title,
                        description,
                        selectedIcon,
                        existingTip.order,
                      );
                    } else {
                      _addTip(title, description, selectedIcon);
                    }

                    Navigator.pop(context);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isEditing
                              ? 'تم تحديث النصيحة بنجاح'
                              : 'تمت إضافة النصيحة بنجاح',
                          style: GoogleFonts.cairo(),
                        ),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(
                    isEditing ? 'تحديث' : 'إضافة',
                    style: GoogleFonts.cairo(),
                  ),
                ),
              ],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildIconOption(
      IconData icon, IconData selectedIcon, Function(IconData) onTap) {
    final isSelected = icon == selectedIcon;

    return GestureDetector(
      onTap: () => onTap(icon),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade100 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Icon(
          icon,
          size: 28,
          color: isSelected ? Colors.blue : Colors.grey.shade700,
        ),
      ),
    );
  }

  void _showDeleteConfirmation(
      BuildContext context, WidgetRef ref, ProtectionTip tip) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'تأكيد الحذف',
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'هل أنت متأكد من أنك تريد حذف هذه النصيحة؟',
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
                    Icon(tip.icon, color: Colors.grey.shade600),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        tip.title,
                        style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('إلغاء', style: GoogleFonts.cairo()),
            ),
            ElevatedButton(
              onPressed: () {
                _deleteTip(tip.id);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('تم حذف النصيحة بنجاح',
                        style: GoogleFonts.cairo()),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text('حذف', style: GoogleFonts.cairo()),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        );
      },
    );
  }

  // CRUD Operations
  Future<void> _addTip(String title, String description, IconData icon) async {
    try {
      final QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('protectionTips').get();

      final int newOrder = snapshot.docs.length;

      final newTip = ProtectionTip(
        id: '',
        title: title,
        description: description,
        icon: icon,
        order: newOrder,
      );

      await FirebaseFirestore.instance
          .collection('protectionTips')
          .add(newTip.toMap());
    } catch (e) {
      print('Error adding tip: $e');
    }
  }

  Future<void> _updateTip(String id, String title, String description,
      IconData icon, int order) async {
    try {
      final updatedTip = ProtectionTip(
        id: id,
        title: title,
        description: description,
        icon: icon,
        order: order,
      );

      await FirebaseFirestore.instance
          .collection('protectionTips')
          .doc(id)
          .update(updatedTip.toMap());
    } catch (e) {
      print('Error updating tip: $e');
    }
  }

  Future<void> _deleteTip(String id) async {
    try {
      await FirebaseFirestore.instance
          .collection('protectionTips')
          .doc(id)
          .delete();
    } catch (e) {
      print('Error deleting tip: $e');
    }
  }
}
