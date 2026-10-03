/// نموذج خطة العلاج - نفس treatment-plan.entity.ts
class TreatmentPlanModel {
  TreatmentPlanModel({
    required this.id,
    required this.patientId,
    this.doctorId,
    required this.totalSessions,
    this.frequency,
    required this.status,
    this.patientName,
    this.doctorName,
  });

  final String id;
  final String patientId;
  final String? doctorId;
  final int totalSessions;
  final String? frequency;
  final String status;
  final String? patientName;
  final String? doctorName;

  factory TreatmentPlanModel.fromJson(Map<String, dynamic> json) {
    return TreatmentPlanModel(
      id: json['id'] ?? '',
      patientId: json['patient_id'] ?? '',
      doctorId: json['doctor_id'],
      totalSessions: json['total_sessions'] ?? 0,
      frequency: json['frequency'],
      status: json['status'] ?? 'ACTIVE',
      patientName: json['patient'] != null
          ? '${json['patient']['first_name'] ?? ''} ${json['patient']['last_name'] ?? ''}'.trim()
          : null,
      doctorName: json['doctor'] != null ? json['doctor']['name'] : null,
    );
  }
}
