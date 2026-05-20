import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/api/api_client.dart';
import '../models/route_model.dart';

final routeListProvider = FutureProvider<List<RouteModel>>((ref) async {
  try {
    final dio = ref.read(dioProvider);
    final res = await dio.get('/routes');
    return (res.data as List)
        .map((r) => RouteModel.fromJson(r as Map<String, dynamic>))
        .toList();
  } on DioException catch (e) {
    throw dioToApi(e);
  }
});

final routeDetailProvider =
    FutureProvider.family<RouteModel, String>((ref, routeId) async {
  try {
    final dio = ref.read(dioProvider);
    final res = await dio.get('/routes/$routeId');
    return RouteModel.fromJson(res.data as Map<String, dynamic>);
  } on DioException catch (e) {
    throw dioToApi(e);
  }
});

final assignRouteProvider =
    FutureProvider.family<TrackerModel, ({String routeId, String businessId})>(
        (ref, args) async {
  try {
    final dio = ref.read(dioProvider);
    final res = await dio.post('/routes/assign', data: {
      'route_id': args.routeId,
      'business_id': args.businessId,
    });
    return TrackerModel.fromJson(res.data as Map<String, dynamic>);
  } on DioException catch (e) {
    throw dioToApi(e);
  }
});
