import 'package:chatlify/core/app_colors.dart';
import 'package:chatlify/core/extension/assets_extension.dart';
import 'package:chatlify/features/home/presentation/widgets/nav_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import '../providers/nav_bar_notifier.dart';

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, child) {
      final navBarState = ref.watch(navBarProvider);
      final theme = Theme.of(context);
      final isDark = theme.brightness == Brightness.dark;
      return Container(
        height: 40.h,
        decoration: BoxDecoration(
          color: isDark ? AppColors.black : AppColors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            NavBarWidget(
              onTap: () {
                ref.read(navBarProvider.notifier).setPageIndex(0);
              },
              icon: navBarState.index == 0
                  ? SvgPicture.asset('active_message'.svg)
                  : SvgPicture.asset('inactive_message'.svg),
            ),
            NavBarWidget(
              onTap: () {
                ref.read(navBarProvider.notifier).setPageIndex(1);
              },
              icon: navBarState.index == 1
                  ? SvgPicture.asset('active_call'.svg)
                  : SvgPicture.asset('inactive_call'.svg),
            ),
            NavBarWidget(
              onTap: () {
                ref.read(navBarProvider.notifier).setPageIndex(2);
              },
              icon: navBarState.index == 2
                  ? SvgPicture.asset('active_profile'.svg)
                  : SvgPicture.asset('inactive_profile'.svg),
            ),
          ],
        ),
      );
    });
  }
}
