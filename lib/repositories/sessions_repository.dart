import '../core/network/api_client.dart';
import '../core/network/list_response_parser.dart';
import '../models/session_model.dart';

/// كل اللي يخص الجلسات، نفس /sessions بتاعة الباك اند.
class SessionsRepository {
  final _dio = ApiClient().dio;

  Future<List<SessionModel>> getSessions({
    int page = 1,
    int limit = 20,
    String? search,
    String? status,
    String? date,
  }) async {
    final response = await _dio.get('/sessions', queryParameters: {
      'page': page,
      'limit': limit,
      if (search != null && search.isNotEmpty) 'search': search,
      if (status != null) 'status': status,
      if (date != null) 'date': date,
    });
    final list = extractListData(response.data);
    return list.map((e) => SessionModel.fromJson(e)).toList();
  }

  Future<List<SessionModel>> getSessionsByPatient(String patientId) async {
    final response = await _dio.get('/sessions/patient/$patientId');
    final list = extractListData(response.data);
    return list.map((e) => SessionModel.fromJson(e)).toList();
  }

  Future<SessionModel> getSessionById(String id) async {
    final response = await _dio.get('/sessions/$id');
    return SessionModel.fromJson(response.data);
  }

  Future<SessionModel> createSession({
    required String patientId,
    String? doctorId,
    String? serviceId,
    String? slotId,
    String? treatmentPlanId,
    required String sessionType,
    required String sessionDate,
  }) async {
    final response = await _dio.post('/sessions', data: {
      'patient_id': patientId,
      if (doctorId != null) 'doctor_id': doctorId,
      if (serviceId != null) 'service_id': serviceId,
      if (slotId != null) 'slot_id': slotId,
      if (treatmentPlanId != null) 'treatment_plan_id': treatmentPlanId,
      'session_type': sessionType,
      'session_date': sessionDate,
    });
    return SessionModel.fromJson(response.data);
  }

  Future<SessionModel> updateSession({
    required String id,
    String? status,
    String? doctorNotes,
    String? receptionNotes,
    String? absenceReason,
  }) async {
    final response = await _dio.put('/sessions/$id', data: {
      if (status != null) 'status': status,
      if (doctorNotes != null) 'doctor_notes': doctorNotes,
      if (receptionNotes != null) 'reception_notes': receptionNotes,
      if (absenceReason != null) 'absence_reason': absenceReason,
    });
    return SessionModel.fromJson(response.data);
  }

  Future<void> deleteSession(String id) async {
    await _dio.delete('/sessions/$id');
  }

  Future<void> markAttendance({
    required String sessionId,
    required String status, // ATTENDED or ABSENT
    String? reason,
  }) async {
    await _dio.post('/sessions/$sessionId/attendance', data: {
      'status': status,
      if (reason != null) 'reason': reason,
    });
  }
}
