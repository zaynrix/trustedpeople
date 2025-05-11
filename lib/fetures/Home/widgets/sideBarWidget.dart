import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trustedtallentsvalley/fetures/Home/providers/home_notifier.dart';
import 'package:trustedtallentsvalley/fetures/Home/widgets/chipWidget.dart';
import 'package:trustedtallentsvalley/fetures/Home/widgets/userInfoItem.dart';

class SideBarInformation extends ConsumerWidget {
  const SideBarInformation({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    double screenWidth = MediaQuery.sizeOf(context).width;

    final selectedUser = ref.watch(selectedUserProvider);

    return Container(
      decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6.0),
          side: const BorderSide(
            width: 1.0,
            color: Colors.grey,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    "معلومات التواصل",
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.cairo(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(width: 16),
                  SizedBox(
                    width: screenWidth * 0.1,
                    height: screenWidth * 0.1,
                    child: ChipWidget(
                      isTrusted: selectedUser?.isTrusted ?? false,
                    ),
                  ),
                  // ChipWidget(
                  //   isTrusted: selectedUser?.isTrusted ?? false,
                  // ),
                ],
              ),
              const Divider(thickness: 2, color: Colors.black54),
              UserInfoItem(
                iconData: Icons.person,
                title: "الاسم ",
                subtitle: selectedUser?.aliasName ?? '',
              ),
              UserInfoItem(
                iconData: Icons.phone,
                title: "رقم الجوال",
                subtitle: selectedUser?.mobileNumber ?? '',
              ),
              UserInfoItem(
                iconData: Icons.location_on,
                title: "الموقع",
                subtitle: selectedUser?.location ?? '',
              ),
              UserInfoItem(
                iconData: Icons.settings_rounded,
                title: "الخدمات المقدمة",
                subtitle: selectedUser?.servicesProvided ?? '',
              ),
              UserInfoItem(
                iconData: Icons.telegram,
                title: "حساب تيليجرام",
                subtitle: selectedUser?.telegramAccount ?? '',
              ),
              UserInfoItem(
                iconData: Icons.link,
                title: "حسابات أخرى",
                subtitle: selectedUser?.otherAccounts ?? '',
              ),
              UserInfoItem(
                iconData: Icons.star_border_purple500_outlined,
                title: "التقييمات",
                subtitle: selectedUser?.reviews ?? '',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
