import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  static const _storage = FlutterSecureStorage(
    webOptions: WebOptions(dbName: 'sane_secure', publicKey: 'sane_pk'),
  );
  static const _key = 'access_token';

  static Future<void> save(String token) => _storage.write(key: _key, value: token);
  static Future<String?> read() => _storage.read(key: _key);
  static Future<void> delete() => _storage.delete(key: _key);
}
