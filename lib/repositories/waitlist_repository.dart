import '../core/network/api_client.dart';
import '../core/network/list_response_parser.dart';
import '../models/waitlist_model.dart';

/// كل اللي يخص قائمة الانتظار، نفس /waitlist بتاعة الباك اند.
class WaitlistRepository {
  final _dio = ApiClient().dio;

  Future<List<WaitlistModel>> getWaitlist({int page = 1, int limit = 20, String? search}) async {
    final response = await _dio.get('/waitlist', queryParameters: {
      'page': page,
      'limit': limit,
      if (search != null && search.isNotEmpty) 'search': search,
    });
    final list = extractListData(response.data);
    return list.map((e) => WaitlistModel.fromJson(e)).toList();
  }

  Future<WaitlistModel> addToWaitlist({
    required String patientId,
    String? serviceId,
    String? doctorId,
    String? preferredDate,
    String? preferredTime,
    String? notes,
  }) async {
    final response = await _dio.post('/waitlist', data: {
      'patient_id': patientId,
      if (serviceId != null) 'service_id': serviceId,
      if (doctorId != null) 'doctor_id': doctorId,
      if (preferredDate != null) 'preferred_date': preferredDate,
      if (preferredTime != null) 'preferred_time': preferredTime,
      if (notes != null) 'notes': notes,
    });
    return WaitlistModel.fromJson(response.data);
  }

  Future<void> deleteFromWaitlist(String id) async {
    await _dio.delete('/waitlist/$id');
  }
}
