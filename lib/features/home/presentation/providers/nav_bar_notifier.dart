import 'package:chatlify/features/home/presentation/providers/nav_bar_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NavBarNotifier extends StateNotifier<NavBarState> {
  NavBarNotifier() : super(NavBarState());

  void setPageIndex(int index) {
    state = state.copyWith(index: index);
  }

  void resetToDefault() {
    state = NavBarState(index: 0);
  }

  int get pageIndex => state.index;
}

final navBarProvider = StateNotifierProvider<NavBarNotifier, NavBarState>(
  (ref) {
    return NavBarNotifier();
  },
);
