import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trustedtallentsvalley/fetures/Home/widgets/usersTable.dart';

final untrustedUsersStreamProvider = StreamProvider<QuerySnapshot>((ref) {
  return FirebaseFirestore.instance
      .collection('userstransed')
      .where("isTrusted", isEqualTo: false)
      .snapshots();
});

// Provider for blacklisted users stream
final blackListUsersStreamProvider = StreamProvider<QuerySnapshot>((ref) {
  return FirebaseFirestore.instance
      .collection('userstransed')
      .where('isTrusted', isEqualTo: false)
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
