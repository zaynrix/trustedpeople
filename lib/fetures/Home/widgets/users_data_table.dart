import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trustedtallentsvalley/fetures/Home/models/user_model.dart';
import 'package:trustedtallentsvalley/fetures/Home/providers/home_notifier.dart';
import 'package:trustedtallentsvalley/fetures/Home/widgets/status_chip.dart';

class UsersDataTable extends ConsumerWidget {
  final List<DocumentSnapshot> users;

  const UsersDataTable({
    Key? key,
    required this.users,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedUser = ref.watch(selectedUserProvider);
    final notifier = ref.read(homeProvider.notifier);
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        width: double.infinity,
        child: DataTable(
          dataRowMaxHeight: 64,
          headingRowColor: MaterialStateColor.resolveWith(
            (states) => Colors.grey.shade100,
          ),
          headingRowHeight: 56,
          horizontalMargin: 24,
          columnSpacing: 24,
          dividerThickness: 1,
          showCheckboxColumn: false,
          decoration: const BoxDecoration(
            color: Colors.white,
          ),
          columns: [
            DataColumn(
              label: Text(
                'الاسم', // Fixed typo
                style: GoogleFonts.cairo(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'الحالة',
                style: GoogleFonts.cairo(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'رقم الجوال',
                style: GoogleFonts.cairo(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'الموقع',
                style: GoogleFonts.cairo(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'التقييمات',
                style: GoogleFonts.cairo(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'تم بواسطة',
                style: GoogleFonts.cairo(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
            ),
            const DataColumn(label: Text('')),
          ],
          rows: users.map((usern) {
            final isSelected = usern.id == selectedUser?.id;
            final userData = UserModel.fromFirestore(usern);

            return DataRow(
              selected: isSelected,
              color: MaterialStateProperty.resolveWith((states) {
                if (states.contains(MaterialState.selected)) {
                  return theme.primaryColor.withOpacity(0.08);
                }
                return null;
              }),
              cells: [
                DataCell(
                  Text(
                    userData.aliasName ?? '',
                    style: GoogleFonts.cairo(
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? theme.primaryColor : Colors.black87,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                DataCell(
                  StatusChip(
                    isTrusted: usern["isTrusted"],
                    role: userData.role, // Convert to int if it exists
                    compact: true,
                  ),
                ),
                DataCell(
                  GestureDetector(
                    onTap: () {
                      final phone = usern['mobileNumber'] ?? '';
                      if (phone.isNotEmpty) {
                        Clipboard.setData(ClipboardData(text: phone));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('تم نسخ رقم الجوال'),
                            backgroundColor: Colors.blue.shade700,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            width: 200,
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      }
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          usern['mobileNumber'] ?? '',
                          style: GoogleFonts.cairo(
                            color: Colors.grey.shade800,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.content_copy,
                          size: 16,
                          color: Colors.blue,
                        ),
                      ],
                    ),
                  ),
                ),
                DataCell(
                  Text(
                    usern['location'] ?? '',
                    style: GoogleFonts.cairo(),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.star_rounded,
                        color: Colors.amber,
                        size: 18,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        usern['reviews'] ?? '',
                        style: GoogleFonts.cairo(),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // DataCell(Text(usern['reviews'],
                //     style: GoogleFonts.cairo())), // Show who added the user
                DataCell(
                  Builder(
                    builder: (context) {
                      String addedByValue = 'Unknown';
                      try {
                        final data = usern.data();
                        if (data != null && data is Map<String, dynamic>) {
                          if (data.containsKey('addedBy')) {
                            addedByValue = data['addedBy'] ?? 'Unknown';
                          }
                        }
                      } catch (e) {
                        // Silently handle any errors
                      }
                      return Text(
                        addedByValue,
                        style: GoogleFonts.cairo(),
                      );
                    },
                  ),
                ),
                DataCell(
                  TextButton.icon(
                    onPressed: () {
                      notifier.visibleBar(selected: userData);
                    },
                    icon: const Icon(Icons.visibility_rounded, size: 16),
                    label: Text(
                      "المزيد",
                      style: GoogleFonts.cairo(),
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: theme.primaryColor,
                      backgroundColor: theme.primaryColor.withOpacity(0.1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
