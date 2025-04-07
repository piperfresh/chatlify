import 'package:flutter/cupertino.dart';

class AppLifecycleObserver with WidgetsBindingObserver {
  final Function(bool) onAppStateChanged;

  AppLifecycleObserver(this.onAppStateChanged) {
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        onAppStateChanged(true);
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        onAppStateChanged(false);
        break;
      default:
        break;
    }
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
  }
}
