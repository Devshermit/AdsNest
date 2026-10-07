import 'package:ads_nest/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final SupabaseClient _supabase = Supabase.instance.client;

  static Future<void> syncFcmTokenPostLogin(
    AuthRemoteDataSource dataSource,
  ) async {
    try {
      final messaging = FirebaseMessaging.instance;
      final settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        final token = await messaging.getToken();
        if (token != null && token.isNotEmpty) {
          await dataSource.updateFcmToken(token);
          debugPrint('FCM Token synced successfully: $token');
        }
      }
    } catch (e) {
      debugPrint('Failed to sync FCM token: $e');
    }
  }

  Future<void> initAndSyncToken() async {
    final settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      final token = await _fcm.getToken();
      if (token != null) {
        await saveTokenToSupabase(token);
      }

      _fcm.onTokenRefresh.listen((newToken) async {
        await saveTokenToSupabase(newToken);
      });
    }
  }

  Future<void> saveTokenToSupabase(String token) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      await _supabase
          .from('profiles')
          .update({
            'fcm_token': token,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', userId);
    } catch (e) {
      debugPrint('Failed to sync FCM Token: $e');
    }
  }

  Future<void> clearTokenOnLogout() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId != null) {
      try {
        await _supabase
            .from('profiles')
            .update({'fcm_token': null})
            .eq('id', userId);
      } catch (e) {
        debugPrint('Failed to clear FCM Token: $e');
      }
    }
  }
}
