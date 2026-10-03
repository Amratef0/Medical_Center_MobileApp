import '../core/network/api_client.dart';
import '../core/network/list_response_parser.dart';
import '../models/patient_model.dart';
import '../models/medical_history_model.dart';

/// كل اللي يخص المرضى، نفس /patients بتاعة الباك اند.
class PatientsRepository {
  final _dio = ApiClient().dio;

  Future<List<PatientModel>> getPatients({int page = 1, int limit = 20, String? search}) async {
    final response = await _dio.get('/patients', queryParameters: {
      'page': page,
      'limit': limit,
      if (search != null && search.isNotEmpty) 'search': search,
    });
    final list = extractListData(response.data);
    return list.map((e) => PatientModel.fromJson(e)).toList();
  }

  Future<PatientModel> getPatientById(String id) async {
    final response = await _dio.get('/patients/$id');
    return PatientModel.fromJson(response.data);
  }

  Future<PatientModel> createPatient({
    required String firstName,
    required String lastName,
    String? gender,
    String? dateOfBirth,
    String? address,
    String? phone,
    String? whatsappNumber,
    String? emergencyContact,
    String? email,
    String? notes,
  }) async {
    final response = await _dio.post('/patients', data: {
      'first_name': firstName,
      'last_name': lastName,
      if (gender != null) 'gender': gender,
      if (dateOfBirth != null) 'date_of_birth': dateOfBirth,
      if (address != null) 'address': address,
      if (phone != null) 'phone': phone,
      if (whatsappNumber != null) 'whatsapp_number': whatsappNumber,
      if (emergencyContact != null) 'emergency_contact': emergencyContact,
      if (email != null) 'email': email,
      if (notes != null) 'notes': notes,
    });
    return PatientModel.fromJson(response.data);
  }

  Future<PatientModel> updatePatient({
    required String id,
    required String firstName,
    required String lastName,
    String? gender,
    String? phone,
    String? whatsappNumber,
    String? email,
    String? address,
    String? status,
    String? notes,
  }) async {
    final response = await _dio.put('/patients/$id', data: {
      'first_name': firstName,
      'last_name': lastName,
      if (gender != null) 'gender': gender,
      if (phone != null) 'phone': phone,
      if (whatsappNumber != null) 'whatsapp_number': whatsappNumber,
      if (email != null) 'email': email,
      if (address != null) 'address': address,
      if (status != null) 'status': status,
      if (notes != null) 'notes': notes,
    });
    return PatientModel.fromJson(response.data);
  }

  Future<void> deletePatient(String id) async {
    await _dio.delete('/patients/$id');
  }

  Future<MedicalHistoryModel?> getMedicalHistory(String patientId) async {
    try {
      final response = await _dio.get('/patients/$patientId/medical-history');
      if (response.data == null) return null;
      return MedicalHistoryModel.fromJson(response.data);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveMedicalHistory({
    required String patientId,
    String? allergies,
    String? chronicDiseases,
    String? medications,
    String? surgeries,
    String? notes,
  }) async {
    await _dio.post('/patients/$patientId/medical-history', data: {
      if (allergies != null) 'allergies': allergies,
      if (chronicDiseases != null) 'chronic_diseases': chronicDiseases,
      if (medications != null) 'medications': medications,
      if (surgeries != null) 'surgeries': surgeries,
      if (notes != null) 'notes': notes,
    });
  }
}
