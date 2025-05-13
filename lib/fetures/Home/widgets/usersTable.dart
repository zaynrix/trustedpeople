import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trustedtallentsvalley/fetures/Home/models/user_model.dart';
import 'package:trustedtallentsvalley/fetures/Home/providers/home_notifier.dart';
import 'package:trustedtallentsvalley/fetures/Home/widgets/chipWidget.dart';

class UsersTable extends ConsumerWidget {
  const UsersTable({
    super.key,
    required this.users,
  });

  final List<DocumentSnapshot> users;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    double screenWidth = MediaQuery.sizeOf(context).width;
    // Get current selected user from provider
    final selectedUser = ref.watch(selectedUserProvider);
    final notifier = ref.read(homeProvider.notifier);

    return DataTable(
      headingRowColor:
          MaterialStateColor.resolveWith((states) => Colors.grey.shade200),
      columns: [
        DataColumn(
          label: Text(
            'الاسم',
            style: GoogleFonts.cairo(),
          ),
        ),
        DataColumn(
          label: Text(
            'الحالة',
            style: GoogleFonts.cairo(),
          ),
        ),
        DataColumn(
          label: Text(
            'رقم الجوال',
            style: GoogleFonts.cairo(),
          ),
        ),
        DataColumn(
          label: Text(
            'الموقع',
            style: GoogleFonts.cairo(),
          ),
        ),
        DataColumn(
          label: Text(
            'التقييمات',
            style: GoogleFonts.cairo(),
          ),
        ),
        const DataColumn(label: Text('')),
      ],
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade100),
        borderRadius: BorderRadius.circular(6),
      ),
      rows: users.map((user) {
        // Highlight row if it's the selected user
        final isSelected = user.id == selectedUser?.id;

        return DataRow(
          color: MaterialStateColor.resolveWith(
            (states) => isSelected ? Colors.blue.shade50 : Colors.white,
          ),
          cells: [
            // الاسم المستعار
            DataCell(
              SizedBox(
                width: screenWidth * 0.1,
                child: Text(
                  user['aliasName'] ?? '',
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.cairo(), // ✅ خط عربي
                ),
              ),
            ),

            // الحالة (باستخدام ويدجت ChipWidget)
            DataCell(
              SizedBox(
                width: screenWidth * 0.1,
                // height: screenWidth * 0.1,
                child: ChipWidget(isTrusted: user["isTrusted"]),
              ),
            ),

            // رقم الجوال مع زر النسخ
            DataCell(
              SizedBox(
                child: TextButton.icon(
                  label: Text(
                    user['mobileNumber'] ?? '',
                    style: GoogleFonts.cairo(
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.normal,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                  onPressed: () {
                    // TODO: Implement copy functionality
                  },
                  icon: const Icon(Icons.copy, size: 12),
                ),
              ),
            ),

            DataCell(
              SizedBox(
                width: screenWidth * 0.1,
                child: Text(
                  user['location'] ?? '',
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.cairo(), // ✅ خط عربي
                ),
              ),
            ),
            DataCell(
              SizedBox(
                width: screenWidth * 0.1,
                child: Text(
                  user['reviews'] ?? '',
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.cairo(), // ✅ خط عربي
                ),
              ),
            ),
            // زر "المزيد"
            DataCell(
              GestureDetector(
                onTap: () {
                  notifier.visibleBar(selected: UserModel.fromFirestore(user));
                },
                child: Text(
                  "المزيد",
                  style: GoogleFonts.cairo(
                    textStyle: const TextStyle(color: Colors.blue),
                  ),
                ),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}
