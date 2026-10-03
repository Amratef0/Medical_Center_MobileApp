import '../core/network/api_client.dart';
import '../core/network/list_response_parser.dart';
import '../models/treatment_plan_model.dart';

/// كل اللي يخص خطط العلاج، نفس /treatment-plans بتاعة الباك اند.
class TreatmentPlansRepository {
  final _dio = ApiClient().dio;

  Future<List<TreatmentPlanModel>> getPlans({int page = 1, int limit = 20, String? search}) async {
    final response = await _dio.get('/treatment-plans', queryParameters: {
      'page': page,
      'limit': limit,
      if (search != null && search.isNotEmpty) 'search': search,
    });
    final list = extractListData(response.data);
    return list.map((e) => TreatmentPlanModel.fromJson(e)).toList();
  }

  Future<List<TreatmentPlanModel>> getPlansByPatient(String patientId) async {
    final response = await _dio.get('/treatment-plans/patient/$patientId');
    final list = extractListData(response.data);
    return list.map((e) => TreatmentPlanModel.fromJson(e)).toList();
  }

  Future<TreatmentPlanModel> createPlan({
    required String patientId,
    String? doctorId,
    required int totalSessions,
    String? frequency,
  }) async {
    final response = await _dio.post('/treatment-plans', data: {
      'patient_id': patientId,
      if (doctorId != null) 'doctor_id': doctorId,
      'total_sessions': totalSessions,
      if (frequency != null) 'frequency': frequency,
    });
    return TreatmentPlanModel.fromJson(response.data);
  }

  Future<void> deletePlan(String id) async {
    await _dio.delete('/treatment-plans/$id');
  }
}
