import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trustedtallentsvalley/fetures/trusted/widgets/usersTable.dart';

// Provider for untrusted users stream (role = 3, which is fraud/scammers)
final untrustedUsersStreamProvider = StreamProvider<QuerySnapshot>((ref) {
  return FirebaseFirestore.instance
      .collection('userstransed')
      .where("role", isEqualTo: 3) // 3 = نصاب (Fraud)
      .snapshots();
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
