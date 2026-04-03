import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/api_constants.dart';
import '../storage/storage_service.dart';

final dioClientProvider = Provider<DioClient>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return DioClient(storage);
});

class DioClient {
  late final Dio _dio;
  final StorageService _storage;

  static String? _inMemoryToken;

  static void setToken(String token) => _inMemoryToken = token;
  static void clearToken() => _inMemoryToken = null;

  DioClient(this._storage) {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(milliseconds: ApiConstants.connectTimeout),
      receiveTimeout: const Duration(milliseconds: ApiConstants.receiveTimeout),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));
    _dio.interceptors.addAll([
      _AuthInterceptor(_storage, _dio),
      LogInterceptor(requestBody: true, responseBody: true, error: true),
    ]);
  }

  Dio get dio => _dio;

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters, Options? options}) =>
      _dio.get(path, queryParameters: queryParameters, options: options);

  Future<Response> post(String path, {dynamic data, Map<String, dynamic>? queryParameters, Options? options}) =>
      _dio.post(path, data: data, queryParameters: queryParameters, options: options);

  Future<Response> put(String path, {dynamic data, Options? options}) =>
      _dio.put(path, data: data, options: options);

  Future<Response> patch(String path, {dynamic data, Options? options}) =>
      _dio.patch(path, data: data, options: options);

  Future<Response> delete(String path, {dynamic data, Options? options}) =>
      _dio.delete(path, data: data, options: options);

  Future<Response> postFormData(String path, FormData formData) =>
      _dio.post(path, data: formData, options: Options(contentType: 'multipart/form-data'));
}

class _AuthInterceptor extends Interceptor {
  final StorageService _storage;
  final Dio _dio;

  _AuthInterceptor(this._storage, this._dio);

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = DioClient._inMemoryToken ?? await _storage.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      try {
        final refreshToken = await _storage.getRefreshToken();
        if (refreshToken != null) {
          final response = await _dio.post(
            ApiConstants.tokenRefresh,
            data: {'refresh': refreshToken},
            options: Options(headers: {'Authorization': null}),
          );
          final newToken = response.data['access'] as String?;
          if (newToken != null) {
            await _storage.saveAccessToken(newToken);
            DioClient.setToken(newToken);
            err.requestOptions.headers['Authorization'] = 'Bearer $newToken';
            final retry = await _dio.fetch(err.requestOptions);
            handler.resolve(retry);
            return;
          }
        }
      } catch (_) {
        await _storage.clearAll();
        DioClient.clearToken();
      }
    }
    handler.next(err);
  }
}