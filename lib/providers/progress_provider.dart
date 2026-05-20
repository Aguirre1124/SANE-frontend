import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/api/api_client.dart';
import '../models/progress_model.dart';

class ProgressNotifier
    extends FamilyAsyncNotifier<ProgressModel, String> {
  @override
  Future<ProgressModel> build(String businessId) => _fetch(businessId);

  Future<ProgressModel> _fetch(String businessId) async {
    try {
      final dio = ref.read(dioProvider);
      final res = await dio.get('/progress/$businessId');
      return ProgressModel.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw dioToApi(e);
    }
  }

  Future<void> completeStep(String trackerId, String stepId) async {
    try {
      final dio = ref.read(dioProvider);
      final res =
          await dio.post('/progress/$trackerId/steps/$stepId/complete', data: {});
      state = AsyncData(ProgressModel.fromJson(res.data as Map<String, dynamic>));
    } on DioException catch (e) {
      throw dioToApi(e);
    }
  }
}

final progressProvider =
    AsyncNotifierProviderFamily<ProgressNotifier, ProgressModel, String>(
        ProgressNotifier.new);
