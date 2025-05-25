import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trustedtallentsvalley/core/widgets/app_drawer.dart';
import 'package:trustedtallentsvalley/fetures/Home/uis/contactUs_screen.dart';

// Define the provider at top level instead of inline
final blockedUsersProvider = StreamProvider<List<BlockedUser>>((ref) {
  return Stream.fromFuture(
    Future.delayed(const Duration(milliseconds: 500), () async {
      try {
        // Check if collection exists first
        final snapshot = await FirebaseFirestore.instance
            .collection('blockedUsers')
            .limit(1)
            .get();

        // If we can access the collection and it's empty, return empty list right away
        if (snapshot.docs.isEmpty) {
          return <BlockedUser>[];
        }

        // Otherwise continue with the regular stream
        return FirebaseFirestore.instance
            .collection('blockedUsers')
            .orderBy('blockedAt', descending: true)
            .get()
            .then((snapshot) => snapshot.docs
                .map((doc) => BlockedUser.fromFirestore(doc))
                .toList());
      } catch (e) {
        print('Error checking blocked users: $e');
        return <BlockedUser>[];
      }
    }),
  ).asyncExpand((list) {
    // Convert Future result to Stream and handle errors
    if (list.isEmpty) {
      // If initial check returned empty, just use a static empty list
      return Stream.value(<BlockedUser>[]);
    } else {
      // Otherwise continue with real-time updates
      return FirebaseFirestore.instance
          .collection('blockedUsers')
          .orderBy('blockedAt', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => BlockedUser.fromFirestore(doc))
              .toList())
          .handleError((e) {
        print('Error in blocked users stream: $e');
        return <BlockedUser>[];
      });
    }
  });
});

class BlockedUsersScreen2 extends ConsumerWidget {
  const BlockedUsersScreen2({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use the provider defined at top level
    final blockedUsersAsync = ref.watch(blockedUsersProvider);

    final size = MediaQuery.of(context).size;
    final isMobile = size.width <= 768;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: isMobile,
        backgroundColor: Colors.red.shade700,
        title: Text(
          'إدارة المستخدمين المحظورين',
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
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (constraints.maxWidth > 768)
                const AppDrawer(isPermanent: true),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header section
                      Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(12.0),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.block,
                              size: 32,
                              color: Colors.red.shade700,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'قائمة المستخدمين المحظورين',
                                    style: GoogleFonts.cairo(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red.shade700,
                                    ),
                                  ),
                                  Text(
                                    'يتم منع المستخدمين المحظورين من الوصول إلى موقعنا والتواصل معنا',
                                    style: GoogleFonts.cairo(
                                      fontSize: 14,
                                      color: Colors.red.shade900,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Blocked users list
                      Expanded(
                        child: blockedUsersAsync.when(
                          data: (users) {
                            if (users.isEmpty) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.check_circle_outline,
                                      size: 64,
                                      color: Colors.green.shade300,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'لا يوجد مستخدمين محظورين',
                                      style: GoogleFonts.cairo(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                    Text(
                                      'القائمة فارغة حالياً',
                                      style: GoogleFonts.cairo(
                                        fontSize: 14,
                                        color: Colors.grey.shade500,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }

                            return ListView.separated(
                              itemCount: users.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final blockedUser = users[index];
                                return _buildBlockedUserCard(
                                    context, ref, blockedUser);
                              },
                            );
                          },
                          loading: () => const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(),
                                SizedBox(height: 16),
                                Text(
                                  'جاري تحميل البيانات...',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                          error: (error, stack) => Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  color: Colors.red,
                                  size: 48,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'حدث خطأ أثناء تحميل البيانات',
                                  style: GoogleFonts.cairo(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  error.toString(),
                                  style: GoogleFonts.cairo(
                                    color: Colors.grey.shade700,
                                    fontSize: 12,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 16),
                                ElevatedButton.icon(
                                  onPressed: () =>
                                      ref.refresh(blockedUsersProvider),
                                  icon: Icon(Icons.refresh),
                                  label: Text('إعادة المحاولة',
                                      style: GoogleFonts.cairo()),
                                ),
                              ],
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

  Widget _buildBlockedUserCard(
      BuildContext context, WidgetRef ref, BlockedUser user) {
    // Pass ref parameter to access providers inside this method
    final DateFormat formatter = DateFormat('yyyy-MM-dd – HH:mm');
    final String formattedDate = formatter.format(user.blockedAt);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.red.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.block, color: Colors.red.shade700),
                const SizedBox(width: 8),
                Text(
                  'تم الحظر: $formattedDate',
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _showUnblockConfirmation(context, ref, user),
                  tooltip: 'إلغاء الحظر',
                ),
              ],
            ),
            const Divider(),
            _buildDetailRow('عنوان IP', user.ip),
            if (user.userEmail.isNotEmpty)
              _buildDetailRow('البريد الإلكتروني', user.userEmail),
            _buildDetailRow('سبب الحظر', user.reason),
            _buildDetailRow('تم الحظر بواسطة', user.blockedBy),
            const SizedBox(height: 8),
            ExpansionTile(
              title: Text('تفاصيل المتصفح', style: GoogleFonts.cairo()),
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SelectableText(
                    user.userAgent,
                    style: GoogleFonts.robotoMono(fontSize: 12),
                  ),
                ),
                // Add copy button for easy copying
                TextButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: user.userAgent));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('تم نسخ معلومات المتصفح'),
                        backgroundColor: Colors.green,
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                  icon: const Icon(Icons.copy, size: 16),
                  label: Text('نسخ', style: GoogleFonts.cairo()),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '-' : value, // Show dash if empty
              style: GoogleFonts.cairo(),
            ),
          ),
        ],
      ),
    );
  }

  void _showUnblockConfirmation(
      BuildContext context, WidgetRef ref, BlockedUser user) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'تأكيد إلغاء الحظر',
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
          ),
          content: Text(
            'هل أنت متأكد من أنك تريد إلغاء حظر هذا المستخدم؟',
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
                      .collection('blockedUsers')
                      .doc(user.id)
                      .delete();

                  Navigator.pop(context);

                  // Refresh the provider to update the UI immediately
                  ref.refresh(blockedUsersProvider);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('تم إلغاء الحظر بنجاح'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('حدث خطأ: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              child: Text('إلغاء الحظر', style: GoogleFonts.cairo()),
            ),
          ],
        );
      },
    );
  }
}
