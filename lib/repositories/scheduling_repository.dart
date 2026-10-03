import '../core/network/api_client.dart';
import '../core/network/list_response_parser.dart';
import '../models/schedule_slot_model.dart';

/// كل اللي يخص جدولة المواعيد، نفس /scheduling بتاعة الباك اند.
class SchedulingRepository {
  final _dio = ApiClient().dio;

  Future<List<ScheduleSlotModel>> getSlots({String? doctorId, String? date}) async {
    final response = await _dio.get('/scheduling/slots', queryParameters: {
      if (doctorId != null) 'doctor_id': doctorId,
      if (date != null) 'date': date,
    });
    final list = extractListData(response.data);
    return list.map((e) => ScheduleSlotModel.fromJson(e)).toList();
  }

  Future<ScheduleSlotModel> createSlot({
    String? doctorId,
    String? serviceId,
    required String startTime,
    required String endTime,
    int capacity = 1,
  }) async {
    final response = await _dio.post('/scheduling/slots', data: {
      if (doctorId != null) 'doctor_id': doctorId,
      if (serviceId != null) 'service_id': serviceId,
      'start_time': startTime,
      'end_time': endTime,
      'capacity': capacity,
    });
    return ScheduleSlotModel.fromJson(response.data);
  }

  Future<void> deleteSlot(String id) async {
    await _dio.delete('/scheduling/slots/$id');
  }

  Future<void> bookSlot(String id) async {
    await _dio.patch('/scheduling/slots/$id/book');
  }

  Future<void> cancelBooking(String id) async {
    await _dio.patch('/scheduling/slots/$id/cancel-booking');
  }
}
