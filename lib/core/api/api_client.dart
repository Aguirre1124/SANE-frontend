import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../storage/token_storage.dart';
import 'api_exception.dart';

const String kBaseUrl = 'http://localhost:8000';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(
    baseUrl: kBaseUrl,
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 30),
  ));

  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (opts, handler) async {
      final token = await TokenStorage.read();
      if (token != null) {
        opts.headers['Authorization'] = 'Bearer $token';
      }
      handler.next(opts);
    },
    onError: (error, handler) async {
      if (error.response?.statusCode == 401) {
        await TokenStorage.delete();
      }
      handler.next(error);
    },
  ));

  return dio;
});

ApiException dioToApi(DioException e) {
  final data = e.response?.data;
  final msg = (data is Map ? data['detail']?.toString() : null) ??
      e.message ??
      'Error de conexión';
  return ApiException(msg, e.response?.statusCode ?? 0);
}
