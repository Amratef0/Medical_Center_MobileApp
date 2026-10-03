import '../core/network/api_client.dart';
import '../core/network/list_response_parser.dart';
import '../models/service_model.dart';

/// كل اللي يخص الخدمات، نفس /services بتاعة الباك اند.
class ServicesRepository {
  final _dio = ApiClient().dio;

  Future<List<ServiceModel>> getServices() async {
    final response = await _dio.get('/services');
    final list = extractListData(response.data);
    return list.map((e) => ServiceModel.fromJson(e)).toList();
  }

  Future<List<ServiceModel>> getActiveServices() async {
    final response = await _dio.get('/services/active');
    final list = extractListData(response.data);
    return list.map((e) => ServiceModel.fromJson(e)).toList();
  }
}
