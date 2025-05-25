import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trustedtallentsvalley/fetures/Home/widgets/usersTable.dart';

// Provider for trusted users stream
final trustedUsersStreamProvider = StreamProvider<QuerySnapshot>((ref) {
  return FirebaseFirestore.instance
      .collection('userstransed')
      .where("isTrusted", isEqualTo: true)
      .snapshots();
});

class TrustedUsersScreen extends ConsumerWidget {
  const TrustedUsersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersStream = ref.watch(trustedUsersStreamProvider);

    return UsersListScreen(
      title: "قائمة الموثوقين",
      usersStream: usersStream,
    );
  }
}
