import 'package:chatlify/core/common/loader.dart';
import 'package:chatlify/core/extension/size_extension.dart';
import 'package:chatlify/features/auth/presentation/providers/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/themes/theme_notifier.dart';
import '../../../auth/presentation/screen/sign_in_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final userAsync = ref.watch(authControllerProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings', style: Theme.of(context).textTheme.titleMedium),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: userAsync.when(
              data: (data) {
                final user = data.currentUser;
                return Row(
                  children: [
                    CircleAvatar(
                      radius: 36,
                      child: Text(user?.name[0].toUpperCase() ?? ''),
                    ),
                    24.sbW,
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.name ?? '',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontSize: 18.sp),
                        ),
                        8.sbH,
                        Text(
                          'Available',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                  fontSize: 12.sp, fontWeight: FontWeight.w400),
                        ),
                      ],
                    )
                  ],
                );
              },
              error: (error, stackTrace) {
                return const SizedBox.shrink();
              },
              loading: () {
                return const Loader();
              },
            ),
          ),
          18.sbH,
          const Divider(
            height: 1,
            color: Color(0XFFEBEBEB),
          ),
          32.sbH,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.dark_mode),
                    16.sbW,
                    Text(
                      'Dark mode',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 14.sp, fontWeight: FontWeight.w400),
                    ),
                  ],
                ),
                Switch(
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  value: !ref.watch(themeProvider.notifier).currentTheme,
                  onChanged: (value) {
                    ref.read(themeProvider.notifier).toggleTheme();
                  },
                )
              ],
            ),
          ),
          24.sbH,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: InkWell(
              onTap: () async {
                await ref.read(authControllerProvider.notifier).signOut();
                if (context.mounted) {
                  await Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                    (route) => false,
                  );
                }
              },
              child: Row(
                children: [
                  const Icon(
                    Icons.logout,
                    size: 30,
                  ),
                  16.sbW,
                  Text(
                    'Log out',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 14.sp, fontWeight: FontWeight.w400),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
