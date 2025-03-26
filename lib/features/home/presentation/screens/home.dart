import 'package:chatlify/features/call/presentation/screens/call_list_screen.dart';
import 'package:chatlify/features/chat/presentation/screens/chat_list_screen.dart';
import 'package:chatlify/features/home/presentation/providers/nav_bar_notifier.dart';
import 'package:chatlify/features/home/presentation/widgets/bottom_nav_bar.dart';
import 'package:chatlify/features/profile/presentation/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Home extends ConsumerWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navBarState = ref.watch(navBarProvider);
    List<Widget> pages = const [
      ChatListScreen(),
      CallListScreen(),
      ProfileScreen(),
    ];

    return Scaffold(
      body: pages[navBarState.index],
      bottomNavigationBar: const BottomNavBar(),
    );
  }
}
