import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/api/api_client.dart';
import '../models/business_model.dart';

class BusinessListNotifier extends AsyncNotifier<List<BusinessModel>> {
  @override
  Future<List<BusinessModel>> build() => _fetch();

  Future<List<BusinessModel>> _fetch() async {
    final dio = ref.read(dioProvider);
    final res = await dio.get('/businesses/');
    return (res.data as List)
        .map((b) => BusinessModel.fromJson(b as Map<String, dynamic>))
        .toList();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
  }

  Future<BusinessModel> create(Map<String, dynamic> body) async {
    try {
      final dio = ref.read(dioProvider);
      final res = await dio.post('/businesses/', data: body);
      final created = BusinessModel.fromJson(res.data as Map<String, dynamic>);
      state = AsyncData([...state.asData?.value ?? [], created]);
      return created;
    } on DioException catch (e) {
      throw dioToApi(e);
    }
  }

  Future<BusinessModel> updateBusiness(String id, Map<String, dynamic> body) async {
    try {
      final dio = ref.read(dioProvider);
      final res = await dio.patch('/businesses/$id', data: body);
      final updated = BusinessModel.fromJson(res.data as Map<String, dynamic>);
      state = AsyncData(
        (state.asData?.value ?? [])
            .map((b) => b.id == id ? updated : b)
            .toList(),
      );
      return updated;
    } on DioException catch (e) {
      throw dioToApi(e);
    }
  }
}

final businessListProvider =
    AsyncNotifierProvider<BusinessListNotifier, List<BusinessModel>>(
        BusinessListNotifier.new);

final businessDetailProvider =
    FutureProvider.family<BusinessModel, String>((ref, id) async {
  try {
    final dio = ref.read(dioProvider);
    final res = await dio.get('/businesses/$id');
    return BusinessModel.fromJson(res.data as Map<String, dynamic>);
  } on DioException catch (e) {
    throw dioToApi(e);
  }
});
