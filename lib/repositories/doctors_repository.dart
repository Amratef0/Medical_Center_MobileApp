import '../core/network/api_client.dart';
import '../core/network/list_response_parser.dart';
import '../models/doctor_model.dart';
import '../models/doctor_availability_model.dart';

/// كل اللي يخص الأطباء، نفس /doctors بتاعة الباك اند.
class DoctorsRepository {
  final _dio = ApiClient().dio;

  Future<List<DoctorModel>> getDoctors({int page = 1, int limit = 50, String? search}) async {
    final response = await _dio.get('/doctors', queryParameters: {
      'page': page,
      'limit': limit,
      if (search != null && search.isNotEmpty) 'search': search,
    });
    final list = extractListData(response.data);
    return list.map((e) => DoctorModel.fromJson(e)).toList();
  }

  Future<DoctorModel> getDoctorById(String id) async {
    final response = await _dio.get('/doctors/$id');
    return DoctorModel.fromJson(response.data);
  }

  Future<DoctorModel> createDoctor({
    required String name,
    String? specialization,
    String? phone,
    String? email,
  }) async {
    final response = await _dio.post('/doctors', data: {
      'name': name,
      if (specialization != null) 'specialization': specialization,
      if (phone != null) 'phone': phone,
      if (email != null) 'email': email,
    });
    return DoctorModel.fromJson(response.data);
  }

  Future<DoctorModel> updateDoctor({
    required String id,
    required String name,
    String? specialization,
    String? phone,
    String? email,
    bool? isActive,
  }) async {
    final response = await _dio.put('/doctors/$id', data: {
      'name': name,
      if (specialization != null) 'specialization': specialization,
      if (phone != null) 'phone': phone,
      if (email != null) 'email': email,
      if (isActive != null) 'is_active': isActive,
    });
    return DoctorModel.fromJson(response.data);
  }

  Future<void> deleteDoctor(String id) async {
    await _dio.delete('/doctors/$id');
  }

  Future<List<DoctorAvailabilityModel>> getAvailability(String doctorId) async {
    final response = await _dio.get('/doctors/$doctorId/availability');
    final list = extractListData(response.data);
    return list.map((e) => DoctorAvailabilityModel.fromJson(e)).toList();
  }

  Future<void> addAvailability({
    required String doctorId,
    required int dayOfWeek,
    required String startTime,
    required String endTime,
    int slotCapacity = 1,
  }) async {
    await _dio.post('/doctors/$doctorId/availability', data: {
      'day_of_week': dayOfWeek,
      'start_time': startTime,
      'end_time': endTime,
      'slot_capacity': slotCapacity,
    });
  }
}
