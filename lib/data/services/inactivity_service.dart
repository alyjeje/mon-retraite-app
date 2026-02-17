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

  /// Demarre le service
  void start({
    required int timeoutMinutes,
    required VoidCallback onTimeout,
    required VoidCallback onAppDetached,
  }) {
    _timeoutMinutes = timeoutMinutes;
    _onTimeout = onTimeout;
    _onAppDetached = onAppDetached;
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
        // App minimisee - ne rien faire, le timer continue
        debugPrint('[InactivityService] App paused (minimized)');
        break;
      case AppLifecycleState.resumed:
        // App revenue au premier plan - reset le timer
        debugPrint('[InactivityService] App resumed');
        _resetTimer();
        break;
      default:
        break;
    }
  }

  void dispose() {
    stop();
  }
}
