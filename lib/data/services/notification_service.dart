import 'package:flutter/widgets.dart';

/// Service de notifications push (Firebase Cloud Messaging).
///
/// SETUP REQUIS (manuel):
/// 1. Creer un projet Firebase sur console.firebase.google.com
/// 2. Android: telecharger google-services.json -> android/app/
/// 3. iOS: telecharger GoogleService-Info.plist -> ios/Runner/
/// 4. Ajouter firebase_core et firebase_messaging dans pubspec.yaml
/// 5. Decommenter le code ci-dessous
///
/// En attendant, ce service est un stub qui ne fait rien.
class NotificationService {
  String? _fcmToken;
  String? get fcmToken => _fcmToken;

  /// Initialise FCM et recupere le token
  Future<void> init() async {
    // TODO: Decommenter quand Firebase est configure
    //
    // await Firebase.initializeApp();
    // final messaging = FirebaseMessaging.instance;
    //
    // // Demander la permission (iOS)
    // await messaging.requestPermission(
    //   alert: true,
    //   badge: true,
    //   sound: true,
    // );
    //
    // // Recuperer le token FCM
    // _fcmToken = await messaging.getToken();
    // debugPrint('[NotificationService] FCM Token: $_fcmToken');
    //
    // // Ecouter les refresh de token
    // messaging.onTokenRefresh.listen((newToken) {
    //   _fcmToken = newToken;
    //   debugPrint('[NotificationService] FCM Token refreshed: $newToken');
    //   // TODO: envoyer le nouveau token au BFF
    // });
    //
    // // Messages en foreground
    // FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    //   debugPrint('[NotificationService] Foreground message: ${message.notification?.title}');
    //   // TODO: afficher une notification locale ou un snackbar
    // });
    //
    // // Messages quand l'app est ouverte depuis une notification
    // FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    //   debugPrint('[NotificationService] Opened from notification: ${message.data}');
    //   // TODO: naviguer vers l'ecran appropriate
    // });

    debugPrint('[NotificationService] Stub mode - Firebase non configure');
  }

  /// Enregistre le token FCM aupres du BFF
  Future<void> registerToken(String identifiant, dynamic api) async {
    if (_fcmToken == null) return;
    try {
      await api.post('/notifications/register', body: {
        'identifiant': identifiant,
        'token': _fcmToken,
      });
      debugPrint('[NotificationService] Token enregistre au BFF');
    } catch (e) {
      debugPrint('[NotificationService] Erreur enregistrement token: $e');
    }
  }
}
