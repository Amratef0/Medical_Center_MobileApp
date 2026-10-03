import '../core/network/api_client.dart';
import '../core/network/list_response_parser.dart';
import '../models/follow_up_model.dart';

/// كل اللي يخص المتابعات، نفس /follow-ups بتاعة الباك اند.
class FollowUpsRepository {
  final _dio = ApiClient().dio;

  Future<List<FollowUpModel>> getFollowUps({String? status}) async {
    final response = await _dio.get('/follow-ups', queryParameters: {
      if (status != null) 'status': status,
    });
    final list = extractListData(response.data);
    return list.map((e) => FollowUpModel.fromJson(e)).toList();
  }

  Future<FollowUpModel> createFollowUp({
    required String patientId,
    required String type,
    String? message,
  }) async {
    final response = await _dio.post('/follow-ups', data: {
      'patient_id': patientId,
      'type': type,
      if (message != null) 'message': message,
    });
    return FollowUpModel.fromJson(response.data);
  }

  Future<void> updateStatus({required String id, required String status}) async {
    await _dio.patch('/follow-ups/$id', data: {'status': status});
  }

  Future<void> deleteFollowUp(String id) async {
    await _dio.delete('/follow-ups/$id');
  }
}
