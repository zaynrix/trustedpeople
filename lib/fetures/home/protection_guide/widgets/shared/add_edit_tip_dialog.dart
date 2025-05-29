import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/protection_tip.dart';
import '../../providers/protection_tips_provider.dart';

class AddEditTipDialog extends ConsumerStatefulWidget {
  final ProtectionTip? existingTip;

  const AddEditTipDialog({
    Key? key,
    this.existingTip,
  }) : super(key: key);

  @override
  ConsumerState<AddEditTipDialog> createState() => _AddEditTipDialogState();

  // Static method to show the dialog
  static Future<void> show(BuildContext context, WidgetRef ref,
      [ProtectionTip? existingTip]) {
    return showDialog<void>(
      context: context,
      builder: (context) => AddEditTipDialog(existingTip: existingTip),
    );
  }
}

class _AddEditTipDialogState extends ConsumerState<AddEditTipDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late IconData _selectedIcon;
  bool _isLoading = false;

  bool get _isEditing => widget.existingTip != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: _isEditing ? widget.existingTip!.title : '',
    );
    _descriptionController = TextEditingController(
      text: _isEditing ? widget.existingTip!.description : '',
    );
    _selectedIcon = _isEditing ? widget.existingTip!.icon : Icons.shield;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: _buildTitle(),
      content: SizedBox(
        width: isMobile ? double.maxFinite : 500,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTitleField(),
              const SizedBox(height: 20),
              _buildDescriptionField(),
              const SizedBox(height: 24),
              _buildIconSelection(),
            ],
          ),
        ),
      ),
      actions: _buildActions(),
    );
  }

  Widget _buildTitle() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _isEditing ? Icons.edit : Icons.add,
            color: Colors.blue.shade600,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          _isEditing ? 'تعديل نصيحة' : 'إضافة نصيحة جديدة',
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ],
    );
  }

  Widget _buildTitleField() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextField(
        controller: _titleController,
        enabled: !_isLoading,
        decoration: InputDecoration(
          labelText: 'العنوان',
          labelStyle: GoogleFonts.cairo(
            color: Colors.grey.shade600,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
          prefixIcon: Icon(
            Icons.title,
            color: Colors.grey.shade400,
          ),
        ),
        style: GoogleFonts.cairo(),
      ),
    );
  }

  Widget _buildDescriptionField() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextField(
        controller: _descriptionController,
        enabled: !_isLoading,
        decoration: InputDecoration(
          labelText: 'الوصف التفصيلي',
          labelStyle: GoogleFonts.cairo(
            color: Colors.grey.shade600,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
          prefixIcon: Icon(
            Icons.description,
            color: Colors.grey.shade400,
          ),
        ),
        style: GoogleFonts.cairo(),
        maxLines: 5,
      ),
    );
  }

  Widget _buildIconSelection() {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: Row(
            children: [
              Icon(
                Icons.palette,
                color: Colors.grey.shade600,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'اختر الأيقونة:',
                style: GoogleFonts.cairo(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildIconOption(Icons.shield),
              _buildIconOption(Icons.money_off),
              _buildIconOption(Icons.verified_user),
              _buildIconOption(Icons.warning),
              _buildIconOption(Icons.security),
              _buildIconOption(Icons.lock),
              _buildIconOption(Icons.person_off),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildIconOption(IconData icon) {
    final isSelected = icon == _selectedIcon;

    return GestureDetector(
      onTap: _isLoading
          ? null
          : () {
              setState(() {
                _selectedIcon = icon;
              });
            },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [Colors.blue.shade400, Colors.blue.shade600],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSelected ? null : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.transparent : Colors.grey.shade300,
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Icon(
          icon,
          size: 28,
          color: isSelected ? Colors.white : Colors.grey.shade600,
        ),
      ),
    );
  }

  List<Widget> _buildActions() {
    return [
      TextButton(
        onPressed: _isLoading ? null : () => Navigator.pop(context),
        child: Text(
          'إلغاء',
          style: GoogleFonts.cairo(
            color: Colors.grey.shade600,
          ),
        ),
      ),
      Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade500, Colors.blue.shade600],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: ElevatedButton(
          onPressed: _isLoading ? null : _handleSubmit,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 12,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(
                  _isEditing ? 'تحديث' : 'إضافة',
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ),
    ];
  }

  Future<void> _handleSubmit() async {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();

    // Validation
    if (title.isEmpty || description.isEmpty) {
      _showErrorSnackBar('يرجى ملء جميع الحقول');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final service = ref.read(protectionTipsServiceProvider);

      if (_isEditing) {
        await service.updateTip(
          widget.existingTip!.id,
          title,
          description,
          _selectedIcon,
          widget.existingTip!.order,
        );
      } else {
        await service.addTip(title, description, _selectedIcon);
      }

      if (mounted) {
        Navigator.pop(context);
        _showSuccessSnackBar(
          _isEditing ? 'تم تحديث النصيحة بنجاح' : 'تمت إضافة النصيحة بنجاح',
        );
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('حدث خطأ: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.warning,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.cairo(),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.check_circle,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.cairo(),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
