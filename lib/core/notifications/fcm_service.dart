import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_apis_flutter/core/utils/logger/logger.dart';

/// Firebase Cloud Messaging wrapper. Optional — the app boots fine even if
/// Firebase config files are missing; this service silently no-ops in that case.
class FcmService {
  FcmService([FirebaseMessaging? messaging]) : _messaging = messaging;

  final FirebaseMessaging? _messaging;
  bool _initialized = false;

  Future<String?> getToken() async {
    try {
      return await (_messaging ?? FirebaseMessaging.instance).getToken();
    } catch (e) {
      appLog.t('FCM: getToken failed (Firebase not configured?) -> $e');
      return null;
    }
  }

  Future<NotificationSettings?> requestPermission() async {
    try {
      return await (_messaging ?? FirebaseMessaging.instance)
          .requestPermission();
    } catch (_) {
      return null;
    }
  }

  Stream<RemoteMessage> onMessage() {
    try {
      return FirebaseMessaging.onMessage;
    } catch (_) {
      return const Stream<RemoteMessage>.empty();
    }
  }

  Future<void> init() async {
    if (_initialized) return;
    try {
      // For Android 13+ runtime permission flow.
      await requestPermission();
      // Background handler must be registered at top-level. Buyers wire
      // theirs in `main.dart`; we provide a default no-op for the demo.
      FirebaseMessaging.onBackgroundMessage(_defaultBgHandler);
      _initialized = true;
    } catch (e) {
      appLog.t('FCM init skipped: $e');
    }
  }
}

@pragma('vm:entry-point')
Future<void> _defaultBgHandler(RemoteMessage message) async {
  if (kDebugMode) {
    // Lightweight log — real handlers do work here (DB update, etc).
    appLog.t('FCM bg: ${message.messageId}');
  }
}

final Provider<FcmService> fcmServiceProvider = Provider<FcmService>(
  (Ref ref) => FcmService(),
);
