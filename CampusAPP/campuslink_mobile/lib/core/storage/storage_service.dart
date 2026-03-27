import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';

final storageServiceProvider = Provider<StorageService>((ref) => StorageService());

class StorageService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(),
  );

  Future<void> saveTokens({required String accessToken, required String refreshToken}) async {
    await Future.wait([
      _storage.write(key: AppConstants.accessTokenKey,  value: accessToken),
      _storage.write(key: AppConstants.refreshTokenKey, value: refreshToken),
    ]);
  }

  Future<String?> getAccessToken()  => _storage.read(key: AppConstants.accessTokenKey);
  Future<String?> getRefreshToken() => _storage.read(key: AppConstants.refreshTokenKey);
  Future<void> saveAccessToken(String token) => _storage.write(key: AppConstants.accessTokenKey, value: token);

  Future<void> saveUserId(String id)       => _storage.write(key: AppConstants.userIdKey, value: id);
  Future<String?> getUserId()              => _storage.read(key: AppConstants.userIdKey);
  Future<void> saveUserEmail(String email) => _storage.write(key: AppConstants.userEmailKey, value: email);
  Future<String?> getUserEmail()           => _storage.read(key: AppConstants.userEmailKey);

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
