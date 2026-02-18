import 'dart:async';
import 'package:flutter/widgets.dart';

/// Service de detection d'inactivite et de lifecycle de l'app.
/// - Timer d'inactivite configurable (reset a chaque interaction)
/// - Detection app killed (detached) vs app minimisee (paused)
class InactivityService with WidgetsBindingObserver {
  Timer? _inactivityTimer;
  int _timeoutMinutes;
  VoidCallback? _onTimeout;
  VoidCallback? _onAppDetached;

  InactivityService({int timeoutMinutes = 60})
      : _timeoutMinutes = timeoutMinutes;

  VoidCallback? _onAppPaused;
  VoidCallback? _onAppResumed;

  /// Demarre le service
  void start({
    required int timeoutMinutes,
    required VoidCallback onTimeout,
    required VoidCallback onAppDetached,
    VoidCallback? onAppPaused,
    VoidCallback? onAppResumed,
  }) {
    _timeoutMinutes = timeoutMinutes;
    _onTimeout = onTimeout;
    _onAppDetached = onAppDetached;
    _onAppPaused = onAppPaused;
    _onAppResumed = onAppResumed;
    WidgetsBinding.instance.addObserver(this);
    _resetTimer();
  }

  /// Arrete le service
  void stop() {
    _inactivityTimer?.cancel();
    _inactivityTimer = null;
    WidgetsBinding.instance.removeObserver(this);
  }

  /// Met a jour le timeout (depuis l'admin config)
  void updateTimeout(int minutes) {
    _timeoutMinutes = minutes;
    _resetTimer();
  }

  /// Reset le timer d'inactivite (appele a chaque interaction utilisateur)
  void resetTimer() {
    _resetTimer();
  }

  void _resetTimer() {
    _inactivityTimer?.cancel();
    if (_timeoutMinutes > 0 && _onTimeout != null) {
      _inactivityTimer = Timer(
        Duration(minutes: _timeoutMinutes),
        () {
          debugPrint('[InactivityService] Timeout apres $_timeoutMinutes min');
          _onTimeout?.call();
        },
      );
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.detached:
        // App killed - trigger soft logout
        debugPrint('[InactivityService] App detached (killed)');
        _onAppDetached?.call();
        break;
      case AppLifecycleState.paused:
        // App minimisee - notifier pour verrouiller l'ecran
        debugPrint('[InactivityService] App paused (minimized)');
        _onAppPaused?.call();
        break;
      case AppLifecycleState.resumed:
        // App revenue au premier plan - reset le timer + notifier
        debugPrint('[InactivityService] App resumed');
        _resetTimer();
        _onAppResumed?.call();
        break;
      default:
        break;
    }
  }

  void dispose() {
    stop();
  }
}
