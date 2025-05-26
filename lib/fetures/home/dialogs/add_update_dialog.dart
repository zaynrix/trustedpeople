import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AddUpdateDialog {
  static void show(BuildContext context) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('إضافة تحديث جديد',
              style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: 'عنوان التحديث',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء إدخال عنوان التحديث';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: descriptionController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'وصف التحديث',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء إدخال وصف التحديث';
                    }
                    return null;
                  },
                ),
                if (isLoading)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: CircularProgressIndicator(),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.pop(context),
              child: Text('إلغاء', style: GoogleFonts.cairo()),
            ),
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () async {
                if (formKey.currentState!.validate()) {
                  try {
                    setState(() {
                      isLoading = true;
                    });

                    // Get a reference to Firestore
                    final FirebaseFirestore firestore =
                        FirebaseFirestore.instance;

                    // Create the update object
                    final Map<String, dynamic> updateData = {
                      'title': titleController.text.trim(),
                      'description': descriptionController.text.trim(),
                      'date': FieldValue.serverTimestamp(),
                      'version':
                      '1.0.${DateTime.now().millisecondsSinceEpoch % 1000}',
                      // Generate a simple version number
                    };

                    // Add the update to Firestore
                    await firestore
                        .collection('app_updates')
                        .add(updateData);

                    // Show success message
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('تم إضافة التحديث بنجاح',
                            style: GoogleFonts.cairo()),
                        backgroundColor: Colors.green,
                      ),
                    );

                    // Close the dialog
                    Navigator.pop(context);
                  } catch (e) {
                    // Show error message
                    setState(() {
                      isLoading = false;
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('حدث خطأ: ${e.toString()}',
                            style: GoogleFonts.cairo()),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade700,
              ),
              child: Text('حفظ', style: GoogleFonts.cairo(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  // Method for editing existing updates
  static void editUpdate(BuildContext context, String updateId, Map<String, dynamic> updateData) {
    final titleController = TextEditingController(text: updateData['title']);
    final descriptionController = TextEditingController(text: updateData['description']);
    bool isLoading = false;
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('تعديل التحديث',
              style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: 'عنوان التحديث',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء إدخال عنوان التحديث';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: descriptionController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'وصف التحديث',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء إدخال وصف التحديث';
                    }
                    return null;
                  },
                ),
                if (isLoading)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: CircularProgressIndicator(),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.pop(context),
              child: Text('إلغاء', style: GoogleFonts.cairo()),
            ),
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () async {
                if (formKey.currentState!.validate()) {
                  try {
                    setState(() {
                      isLoading = true;
                    });

                    await FirebaseFirestore.instance
                        .collection('app_updates')
                        .doc(updateId)
                        .update({
                      'title': titleController.text.trim(),
                      'description': descriptionController.text.trim(),
                      'lastEdited': FieldValue.serverTimestamp(),
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('تم تحديث البيانات بنجاح',
                            style: GoogleFonts.cairo()),
                        backgroundColor: Colors.green,
                      ),
                    );

                    Navigator.pop(context);
                  } catch (e) {
                    setState(() {
                      isLoading = false;
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('حدث خطأ: ${e.toString()}',
                            style: GoogleFonts.cairo()),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade700,
              ),
              child: Text('حفظ التغييرات',
                  style: GoogleFonts.cairo(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  // Method for confirming deletion
  static void confirmDeleteUpdate(BuildContext context, String updateId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تأكيد الحذف',
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
        content: Text(
          'هل أنت متأكد من حذف هذا التحديث؟ لا يمكن التراجع عن هذه العملية.',
          style: GoogleFonts.cairo(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء', style: GoogleFonts.cairo()),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await FirebaseFirestore.instance
                    .collection('app_updates')
                    .doc(updateId)
                    .delete();

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('تم حذف التحديث بنجاح',
                        style: GoogleFonts.cairo()),
                    backgroundColor: Colors.green,
                  ),
                );

                Navigator.pop(context);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('حدث خطأ أثناء الحذف: ${e.toString()}',
                        style: GoogleFonts.cairo()),
                    backgroundColor: Colors.red,
                  ),
                );
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text('حذف', style: GoogleFonts.cairo(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}