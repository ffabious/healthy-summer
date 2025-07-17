import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static final _storage = FlutterSecureStorage();
  static const _key = 'jwt_token';
  static const _lastSyncSegmentKey = 'last_step_sync_segment';
  static const _lastSyncDateKey = 'last_step_sync_date';

  static Future<void> saveToken(String token) async =>
      await _storage.write(key: _key, value: token);

  static Future<String?> getToken() async => await _storage.read(key: _key);

  static Future<void> deleteToken() async => await _storage.delete(key: _key);

  // Step sync storage methods
  static Future<void> saveLastSyncInfo(
    DateTime segmentStart,
    String segmentName,
  ) async {
    await _storage.write(
      key: _lastSyncDateKey,
      value: segmentStart.toIso8601String(),
    );
    await _storage.write(key: _lastSyncSegmentKey, value: segmentName);
  }

  static Future<String?> getLastSyncDate() async =>
      await _storage.read(key: _lastSyncDateKey);

  static Future<String?> getLastSyncSegment() async =>
      await _storage.read(key: _lastSyncSegmentKey);
}
