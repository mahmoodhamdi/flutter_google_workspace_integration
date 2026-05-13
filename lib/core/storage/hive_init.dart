import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

/// One-time Hive initialization. Generates an AES-256 key, stores it in
/// secure storage on first launch, reuses it on subsequent launches.
class HiveBootstrap {
  HiveBootstrap._();

  static const String _kEncryptionKey = 'gws.hive.encryption_key';

  static bool _initialized = false;

  static Future<void> init({FlutterSecureStorage? storage}) async {
    if (_initialized) {
      return;
    }
    final dir = await getApplicationDocumentsDirectory();
    await Hive.initFlutter(dir.path);

    final cipher = await _resolveCipher(storage ?? const FlutterSecureStorage());

    // Open box registry. Box openings are lazy on first read but we
    // pre-warm caches that the app launches into.
    await Hive.openBox<String>('app.kv', encryptionCipher: cipher);
    await Hive.openBox<String>('app.cache.calendar', encryptionCipher: cipher);
    await Hive.openBox<String>('app.cache.drive', encryptionCipher: cipher);
    await Hive.openBox<String>('app.cache.sheets', encryptionCipher: cipher);
    await Hive.openBox<String>('app.cache.contacts', encryptionCipher: cipher);
    await Hive.openBox<String>('app.queue.outbox', encryptionCipher: cipher);

    _initialized = true;
  }

  static Future<HiveAesCipher> _resolveCipher(FlutterSecureStorage storage) async {
    final existing = await storage.read(key: _kEncryptionKey);
    Uint8List bytes;
    if (existing != null) {
      bytes = base64Decode(existing);
    } else {
      bytes = Hive.generateSecureKey() as Uint8List;
      await storage.write(key: _kEncryptionKey, value: base64Encode(bytes));
    }
    return HiveAesCipher(bytes);
  }
}

/// Box accessor — assumes [HiveBootstrap.init] has run.
final Provider<Box<String>> kvBoxProvider = Provider<Box<String>>(
  (Ref ref) => Hive.box<String>('app.kv'),
);

Box<String> cacheBox(String feature) => Hive.box<String>('app.cache.$feature');
Box<String> outboxBox() => Hive.box<String>('app.queue.outbox');
