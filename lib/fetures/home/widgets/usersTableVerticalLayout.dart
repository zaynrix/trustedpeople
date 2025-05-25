import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

// Provider for search query in VerticalLayout
final verticalSearchQueryProvider = StateProvider<String>((ref) => '');

class VerticalLayout extends ConsumerWidget {
  const VerticalLayout({
    super.key,
    required this.users,
    required this.constraints,
  });

  final BoxConstraints constraints;
  final List<DocumentSnapshot> users;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the search query provider
    final searchQuery = ref.watch(verticalSearchQueryProvider);

    // Filter users based on the search query
    final filteredUsers = users.where((user) {
      final aliasName = user['aliasName'] ?? '';
      final mobileNumber = user['mobileNumber'] ?? '';
      final query = searchQuery.toLowerCase();
      return aliasName.toLowerCase().contains(query) ||
          mobileNumber.contains(query);
    }).toList();

    return SingleChildScrollView(
      child: Column(
        children: [
          // Add Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'بحث...',
                hintText: 'ابحث بالاسم أو رقم الجوال',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onChanged: (value) {
                ref.read(verticalSearchQueryProvider.notifier).state = value;
              },
            ),
          ),
          // Show the filtered users
          ...filteredUsers.map((user) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Container(
                  width: double.infinity, // Ensure the card takes up full width
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'الاسم المستعار: ${user['aliasName']}',
                        style: GoogleFonts.cairo(),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'رقم الجوال: ${user['mobileNumber']}',
                        style: GoogleFonts.cairo(),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'الموقع: ${user['location']}',
                        style: GoogleFonts.cairo(),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'الخدمات المقدمة: ${user['servicesProvided']}',
                        style: GoogleFonts.cairo(),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'حساب التليجرام: ${user['telegramAccount']}',
                        style: GoogleFonts.cairo(),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'حسابات أخرى: ${user['otherAccounts']}',
                        style: GoogleFonts.cairo(),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'المراجعات: ${user['reviews']}',
                        style: GoogleFonts.cairo(),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
