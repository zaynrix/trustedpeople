import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trustedtallentsvalley/fetures/Home/models/user_model.dart';
import 'package:trustedtallentsvalley/fetures/Home/providers/home_notifier.dart';
import 'package:trustedtallentsvalley/fetures/trusted/presentation/dialogs/edit_user_dialog.dart';
import 'package:trustedtallentsvalley/fetures/trusted/presentation/dialogs/show_delete_confirmation.dart';
import 'package:trustedtallentsvalley/fetures/trusted/presentation/widgets/user_detail_slidebar.dart';

import '../../../../services/auth_service.dart';

void showUserDetailBottomSheet(BuildContext context, WidgetRef ref,
    UserModel user) {
  final homeNotifier = ref.read(homeProvider.notifier);
  final isAdmin = ref.watch(isAdminProvider);

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, controller) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                Expanded(
                  child: UserDetailSidebar(
                    user: user,
                    onClose: () {
                      Navigator.pop(context);
                      homeNotifier.closeBar();
                    },
                    onEdit: isAdmin
                        ? () {
                      Navigator.pop(context);
                      showEditUserDialog(context, ref, user);
                    }
                        : null,
                    onDelete: isAdmin
                        ? () {
                      Navigator.pop(context);
                      showDeleteConfirmation(context, ref, user);
                    }
                        : null,
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}