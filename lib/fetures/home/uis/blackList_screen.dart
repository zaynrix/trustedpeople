import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trustedtallentsvalley/fetures/Home/widgets/usersTable.dart';

// Provider for untrusted users stream (role = 3, which is fraud/scammers)
final untrustedUsersStreamProvider = StreamProvider<QuerySnapshot>((ref) {
  return FirebaseFirestore.instance
      .collection('userstransed')
      .where("role", isEqualTo: 3) // 3 = نصاب (Fraud)
      .snapshots();
});

// Provider for blacklisted users stream (role = 3, which is fraud/scammers)
final blackListUsersStreamProvider = StreamProvider<QuerySnapshot>((ref) {
  return FirebaseFirestore.instance
      .collection('userstransed')
      .where('role', isEqualTo: 3) // 3 = نصاب (Fraud)
      .snapshots();
});

// You might also want to add these additional providers for the new role system:

// Provider for trusted users stream (role = 1)
final trustedUsersStreamProvider = StreamProvider<QuerySnapshot>((ref) {
  return FirebaseFirestore.instance
      .collection('userstransed')
      .where('role', isEqualTo: 1) // 1 = موثوق (Trusted)
      .snapshots();
});

// Provider for known users stream (role = 2)
final knownUsersStreamProvider = StreamProvider<QuerySnapshot>((ref) {
  return FirebaseFirestore.instance
      .collection('userstransed')
      .where('role', isEqualTo: 2) // 2 = معروف (Known)
      .snapshots();
});

// Provider for admin users stream (role = 0)
final adminUsersStreamProvider = StreamProvider<QuerySnapshot>((ref) {
  return FirebaseFirestore.instance
      .collection('userstransed')
      .where('role', isEqualTo: 0) // 0 = مشرف (Admin)
      .snapshots();
});

// Provider for all users stream (no filtering)
final allUsersStreamProvider = StreamProvider<QuerySnapshot>((ref) {
  return FirebaseFirestore.instance.collection('userstransed').snapshots();
});

class BlackListUsersScreen extends ConsumerWidget {
  const BlackListUsersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersStream = ref.watch(untrustedUsersStreamProvider);

    return UsersListScreen(
      title: "قائمة النصابين",
      usersStream: usersStream,
      // appBarColor: Colors.red,
    );
  }
}
