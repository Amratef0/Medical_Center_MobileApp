import '../core/network/api_client.dart';

/// كل اللي يخص التقارير، نفس /reports بتاعة الباك اند.
class ReportingRepository {
  final _dio = ApiClient().dio;

  Future<Map<String, dynamic>> getDailyReport({String? date}) async {
    final response = await _dio.get('/reports/daily', queryParameters: {
      if (date != null) 'date': date,
    });
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getDoctorUtilization() async {
    final response = await _dio.get('/reports/doctor-utilization');
    return response.data is Map<String, dynamic>
        ? response.data
        : {'items': response.data};
  }

  Future<Map<String, dynamic>> getConversionRate() async {
    final response = await _dio.get('/reports/conversion-rate');
    return response.data as Map<String, dynamic>;
  }
}
