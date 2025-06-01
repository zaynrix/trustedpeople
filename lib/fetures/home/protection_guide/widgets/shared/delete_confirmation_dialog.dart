import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/protection_tip.dart';
import '../../providers/protection_tips_provider.dart';

class DeleteConfirmationDialog extends ConsumerStatefulWidget {
  final ProtectionTip tip;

  const DeleteConfirmationDialog({
    Key? key,
    required this.tip,
  }) : super(key: key);

  @override
  ConsumerState<DeleteConfirmationDialog> createState() =>
      _DeleteConfirmationDialogState();

  // Static method to show the dialog
  static Future<void> show(
    BuildContext context,
    WidgetRef ref,
    ProtectionTip tip,
  ) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // Prevent accidental dismissal
      builder: (context) => DeleteConfirmationDialog(tip: tip),
    );
  }
}

class _DeleteConfirmationDialogState
    extends ConsumerState<DeleteConfirmationDialog> {
  bool _isDeleting = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: _buildTitle(),
      content: _buildContent(),
      actions: _buildActions(),
    );
  }

  Widget _buildTitle() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.delete_forever,
            color: Colors.red.shade600,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            'تأكيد الحذف',
            style: GoogleFonts.cairo(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.grey.shade800,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'هل أنت متأكد من أنك تريد حذف هذه النصيحة؟',
          style: GoogleFonts.cairo(
            fontSize: 16,
            height: 1.5,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 20),
        _buildTipPreview(),
        const SizedBox(height: 16),
        _buildWarningBox(),
      ],
    );
  }

  Widget _buildTipPreview() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade400, Colors.blue.shade600],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              widget.tip.icon,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.tip.title,
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.grey.shade800,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'نصيحة رقم ${widget.tip.order + 1}',
                  style: GoogleFonts.cairo(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWarningBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning,
            color: Colors.red.shade600,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'هذا الإجراء لا يمكن التراجع عنه',
              style: GoogleFonts.cairo(
                color: Colors.red.shade700,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildActions() {
    return [
      TextButton(
        onPressed: _isDeleting ? null : () => Navigator.pop(context),
        child: Text(
          'إلغاء',
          style: GoogleFonts.cairo(
            color: _isDeleting ? Colors.grey.shade400 : Colors.grey.shade600,
          ),
        ),
      ),
      Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.red.shade500, Colors.red.shade600],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: ElevatedButton.icon(
          onPressed: _isDeleting ? null : _handleDelete,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 12,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          icon: _isDeleting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Icon(Icons.delete, size: 18),
          label: Text(
            _isDeleting ? 'جاري الحذف...' : 'حذف',
            style: GoogleFonts.cairo(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    ];
  }

  Future<void> _handleDelete() async {
    setState(() {
      _isDeleting = true;
    });

    try {
      final service = ref.read(protectionTipsServiceProvider);
      await service.deleteTip(widget.tip.id);

      if (mounted) {
        Navigator.pop(context);
        _showSuccessSnackBar();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });
        _showErrorSnackBar(e.toString());
      }
    }
  }

  void _showSuccessSnackBar() {
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
                'تم حذف النصيحة "${widget.tip.title}" بنجاح',
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
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showErrorSnackBar(String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.error,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'حدث خطأ أثناء الحذف: $error',
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
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'إعادة المحاولة',
          textColor: Colors.white,
          onPressed: _handleDelete,
        ),
      ),
    );
  }
}
