class NavBarState {
  final int index;

  NavBarState({this.index = 0});

  NavBarState copyWith({
    int? index,
  }) {
    return NavBarState(
      index: index ?? this.index,
    );
  }
}
