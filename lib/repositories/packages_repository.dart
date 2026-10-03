import '../core/network/api_client.dart';
import '../core/network/list_response_parser.dart';
import '../models/package_model.dart';

/// كل اللي يخص الباقات، نفس /packages بتاعة الباك اند.
class PackagesRepository {
  final _dio = ApiClient().dio;

  Future<List<PackageModel>> getPackages() async {
    final response = await _dio.get('/packages');
    final list = extractListData(response.data);
    return list.map((e) => PackageModel.fromJson(e)).toList();
  }

  Future<PackageModel> createPackage({
    required String name,
    String? description,
    required int totalSessions,
    int? expiryDays,
    double? price,
  }) async {
    final response = await _dio.post('/packages', data: {
      'name': name,
      if (description != null) 'description': description,
      'total_sessions': totalSessions,
      if (expiryDays != null) 'expiry_days': expiryDays,
      if (price != null) 'price': price,
    });
    return PackageModel.fromJson(response.data);
  }

  Future<void> deletePackage(String id) async {
    await _dio.delete('/packages/$id');
  }

  Future<PatientPackageModel> assignPackageToPatient({
    required String patientId,
    required String packageId,
  }) async {
    final response = await _dio.post('/packages/assign', data: {
      'patient_id': patientId,
      'package_id': packageId,
    });
    return PatientPackageModel.fromJson(response.data);
  }

  Future<List<PatientPackageModel>> getPatientPackages(String patientId) async {
    final response = await _dio.get('/patient-packages/patient/$patientId');
    final list = extractListData(response.data);
    return list.map((e) => PatientPackageModel.fromJson(e)).toList();
  }
}
