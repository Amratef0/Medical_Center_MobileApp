/// نموذج المستند الطبي - نفس medical-document.entity.ts
class MedicalDocumentModel {
  MedicalDocumentModel({
    required this.id,
    required this.patientId,
    this.doctorId,
    required this.type,
    required this.title,
    this.content,
    this.documentDate,
    this.notes,
  });

  final String id;
  final String patientId;
  final String? doctorId;
  final String type;
  final String title;
  final String? content;
  final String? documentDate;
  final String? notes;

  factory MedicalDocumentModel.fromJson(Map<String, dynamic> json) {
    return MedicalDocumentModel(
      id: json['id'] ?? '',
      patientId: json['patient_id'] ?? '',
      doctorId: json['doctor_id'],
      type: json['type'] ?? 'REPORT',
      title: json['title'] ?? '',
      content: json['content'],
      documentDate: json['document_date'],
      notes: json['notes'],
    );
  }
}
