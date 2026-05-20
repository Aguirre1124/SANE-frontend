import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/api/api_client.dart';
import '../core/storage/token_storage.dart';
import '../models/user_model.dart';

class AuthNotifier extends AsyncNotifier<UserModel?> {
  @override
  Future<UserModel?> build() async {
    final token = await TokenStorage.read();
    if (token == null) return null;
    try {
      final dio = ref.read(dioProvider);
      final res = await dio.get('/auth/me');
      return UserModel.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      await TokenStorage.delete();
      if (e.response?.statusCode == 401) return null;
      rethrow;
    }
  }

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    try {
      final dio = ref.read(dioProvider);
      final loginRes = await dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });
      await TokenStorage.save(loginRes.data['access_token'] as String);
      final meRes = await dio.get('/auth/me');
      state = AsyncData(UserModel.fromJson(meRes.data as Map<String, dynamic>));
    } on DioException catch (e, st) {
      state = AsyncError(dioToApi(e), st);
    }
  }

  Future<void> register(
      String name, String email, String password, String? phone) async {
    state = const AsyncLoading();
    try {
      final dio = ref.read(dioProvider);
      final body = <String, dynamic>{
        'name': name,
        'email': email,
        'password': password,
      };
      if (phone != null && phone.trim().isNotEmpty) body['phone'] = phone.trim();
      await dio.post('/auth/register', data: body);
      await login(email, password);
    } on DioException catch (e, st) {
      state = AsyncError(dioToApi(e), st);
    }
  }

  Future<void> updateProfile(String? name, String? phone) async {
    try {
      final dio = ref.read(dioProvider);
      final body = <String, dynamic>{};
      if (name != null && name.trim().isNotEmpty) body['name'] = name.trim();
      if (phone != null) body['phone'] = phone.trim();
      final res = await dio.patch('/auth/me', data: body);
      state = AsyncData(UserModel.fromJson(res.data as Map<String, dynamic>));
    } on DioException catch (e) {
      throw dioToApi(e);
    }
  }

  Future<void> deleteAccount() async {
    try {
      final dio = ref.read(dioProvider);
      await dio.delete('/auth/delete');
    } on DioException catch (e) {
      throw dioToApi(e);
    } finally {
      await logout();
    }
  }

  Future<void> logout() async {
    await TokenStorage.delete();
    state = const AsyncData(null);
  }
}

final authProvider = AsyncNotifierProvider<AuthNotifier, UserModel?>(AuthNotifier.new);

final currentUserProvider = Provider<UserModel?>((ref) {
  return ref.watch(authProvider).asData?.value;
});
