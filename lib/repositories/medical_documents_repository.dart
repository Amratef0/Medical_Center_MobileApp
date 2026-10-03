import '../core/network/api_client.dart';
import '../core/network/list_response_parser.dart';
import '../models/medical_document_model.dart';

/// كل اللي يخص المستندات الطبية (روشتات/أشعة/تقارير)، نفس /medical-documents.
class MedicalDocumentsRepository {
  final _dio = ApiClient().dio;

  Future<List<MedicalDocumentModel>> getDocumentsByPatient(String patientId) async {
    final response = await _dio.get('/medical-documents/patient/$patientId');
    final list = extractListData(response.data);
    return list.map((e) => MedicalDocumentModel.fromJson(e)).toList();
  }

  Future<MedicalDocumentModel> createDocument({
    required String patientId,
    String? doctorId,
    required String type,
    required String title,
    String? content,
    String? notes,
  }) async {
    final response = await _dio.post('/medical-documents', data: {
      'patient_id': patientId,
      if (doctorId != null) 'doctor_id': doctorId,
      'type': type,
      'title': title,
      if (content != null) 'content': content,
      if (notes != null) 'notes': notes,
    });
    return MedicalDocumentModel.fromJson(response.data);
  }

  Future<void> deleteDocument(String id) async {
    await _dio.delete('/medical-documents/$id');
  }
}
