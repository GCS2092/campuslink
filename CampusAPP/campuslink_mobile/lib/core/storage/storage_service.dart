import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';

final storageServiceProvider = Provider<StorageService>((ref) => StorageService());

class StorageService {

  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
    webOptions: WebOptions(
      dbName: 'campuslink_secure_db',
      publicKey: 'campuslink_pub_key',
    ),
  );

  /// Lecture sécurisée : si la clé WebCrypto est corrompue,
  /// on vide tout le storage et on retourne null
  Future<String?> _safeRead(String key) async {
    try {
      return await _storage.read(key: key);
    } catch (e) {
      await _storage.deleteAll();
      return null;
    }
  }

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await Future.wait([
      _storage.write(key: AppConstants.accessTokenKey,  value: accessToken),
      _storage.write(key: AppConstants.refreshTokenKey, value: refreshToken),
    ]);
  }

  Future<String?> getAccessToken()  => _safeRead(AppConstants.accessTokenKey);
  Future<String?> getRefreshToken() => _safeRead(AppConstants.refreshTokenKey);

  Future<void> saveAccessToken(String token) =>
      _storage.write(key: AppConstants.accessTokenKey, value: token);

  Future<void> saveUserId(String id) =>
      _storage.write(key: AppConstants.userIdKey, value: id);
  Future<String?> getUserId() => _safeRead(AppConstants.userIdKey);

  Future<void> saveUserEmail(String email) =>
      _storage.write(key: AppConstants.userEmailKey, value: email);
  Future<String?> getUserEmail() => _safeRead(AppConstants.userEmailKey);

  Future<void> clearAll()    => _storage.deleteAll();
  Future<void> clearTokens() async {
    await Future.wait([
      _storage.delete(key: AppConstants.accessTokenKey),
      _storage.delete(key: AppConstants.refreshTokenKey),
    ]);
  }

  Future<bool> isLoggedIn() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }
}