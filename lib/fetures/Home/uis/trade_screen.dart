import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trustedtallentsvalley/fetures/Home/uis/trusted_screen.dart';
import 'package:trustedtallentsvalley/services/auth_service.dart';

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

    // Get screen size for responsive layout
    final size = MediaQuery.of(context).size;
    final isMobile = size.width <= 768;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: isMobile,
        backgroundColor: isAdmin ? Colors.green.shade700 : Colors.teal,
        title: Text(
          'كيف تحمي نفسك من النصب؟',
          style: GoogleFonts.cairo(
            textStyle: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      drawer: isMobile ? const AppDrawer() : null,
      // Show FAB only for admins
      floatingActionButton: isAdmin
          ? FloatingActionButton(
              onPressed: () => _showAddEditTipDialog(context, ref),
              backgroundColor: Colors.green.shade700,
              child: const Icon(Icons.add),
              tooltip: 'إضافة نصيحة جديدة',
            )
          : null,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Show permanent drawer on larger screens
              if (constraints.maxWidth > 768)
                const AppDrawer(isPermanent: true),

              // Main content area
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _buildProtectionContent(context, ref, tipsAsync),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProtectionContent(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<ProtectionTip>> tipsAsync,
  ) {
    final isAdmin = ref.watch(isAdminProvider);

    return tipsAsync.when(
      data: (tips) {
        if (tips.isEmpty) {
          return Center(
            child: Text(
              'لا توجد نصائح متاحة حالياً',
              style: GoogleFonts.cairo(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
          );
        }

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header section
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12.0),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.security,
                      size: 40,
                      color: Colors.blue.shade700,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'احمِ نفسك من عمليات النصب',
                            style: GoogleFonts.cairo(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade700,
                            ),
                          ),
                          Text(
                            'اتبع هذه النصائح لتحمي نفسك من عمليات النصب والاحتيال',
                            style: GoogleFonts.cairo(
                              fontSize: 14,
                              color: Colors.blue.shade900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Tips list
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: tips.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final tip = tips[index];
                  return _buildTipCard(context, ref, tip, isAdmin);
                },
              ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text(
          'حدث خطأ: $error',
          style: GoogleFonts.cairo(),
        ),
      ),
    );
  }

  Widget _buildTipCard(
    BuildContext context,
    WidgetRef ref,
    ProtectionTip tip,
    bool isAdmin,
  ) {
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
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tip.title,
                        style: GoogleFonts.cairo(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        tip.description,
                        style: GoogleFonts.cairo(
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Admin actions - only visible to admins
            if (isAdmin)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Row(
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
                    const SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: () =>
                          _showDeleteConfirmation(context, ref, tip),
                      icon: const Icon(Icons.delete, size: 16),
                      label: Text('حذف', style: GoogleFonts.cairo()),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Show dialog to add or edit a protection tip
  void _showAddEditTipDialog(BuildContext context, WidgetRef ref,
      [ProtectionTip? existingTip]) {
    final isEditing = existingTip != null;
    final titleController = TextEditingController(
      text: isEditing ? existingTip.title : '',
    );
    final descriptionController = TextEditingController(
      text: isEditing ? existingTip.description : '',
    );

    // Default icon for new tips or existing icon for edits
    IconData selectedIcon = isEditing ? existingTip.icon : Icons.shield;

    // Show the dialog
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
              content: SingleChildScrollView(
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
                    // Icon selector
                    Text(
                      'الأيقونة:',
                      style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        _buildIconOption(Icons.shield, selectedIcon, (icon) {
                          setState(() => selectedIcon = icon);
                        }),
                        _buildIconOption(Icons.money_off, selectedIcon, (icon) {
                          setState(() => selectedIcon = icon);
                        }),
                        _buildIconOption(Icons.verified_user, selectedIcon,
                            (icon) {
                          setState(() => selectedIcon = icon);
                        }),
                        _buildIconOption(Icons.warning, selectedIcon, (icon) {
                          setState(() => selectedIcon = icon);
                        }),
                        _buildIconOption(Icons.security, selectedIcon, (icon) {
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
                        const SnackBar(
                          content: Text('يرجى ملء جميع الحقول'),
                        ),
                      );
                      return;
                    }

                    if (isEditing) {
                      // Update existing tip
                      _updateTip(
                        existingTip.id,
                        title,
                        description,
                        selectedIcon,
                        existingTip.order,
                      );
                    } else {
                      // Add new tip
                      _addTip(
                        title,
                        description,
                        selectedIcon,
                      );
                    }

                    Navigator.pop(context);
                  },
                  child: Text(
                    isEditing ? 'تحديث' : 'إضافة',
                    style: GoogleFonts.cairo(),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Icon option widget for the dialog
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

  // Show confirmation dialog for deleting a tip
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
          content: Text(
            'هل أنت متأكد من أنك تريد حذف هذه النصيحة؟',
            style: GoogleFonts.cairo(),
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
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: Text('حذف', style: GoogleFonts.cairo()),
            ),
          ],
        );
      },
    );
  }

  // CRUD Operations

  // Add a new tip
  Future<void> _addTip(
    String title,
    String description,
    IconData icon,
  ) async {
    try {
      // Get the current count to determine new order
      final QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('protectionTips').get();

      final int newOrder = snapshot.docs.length;

      // Create the new tip
      final newTip = ProtectionTip(
        id: '', // Firestore will generate
        title: title,
        description: description,
        icon: icon,
        order: newOrder,
      );

      // Add to Firestore
      await FirebaseFirestore.instance
          .collection('protectionTips')
          .add(newTip.toMap());
    } catch (e) {
      print('Error adding tip: $e');
    }
  }

  // Update an existing tip
  Future<void> _updateTip(
    String id,
    String title,
    String description,
    IconData icon,
    int order,
  ) async {
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

  // Delete a tip
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
