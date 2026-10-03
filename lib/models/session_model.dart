/// نموذج الجلسة - نفس session.entity.ts في الباك اند.
class SessionModel {
  SessionModel({
    required this.id,
    required this.patientId,
    this.doctorId,
    this.serviceId,
    this.slotId,
    this.treatmentPlanId,
    this.patientPackageId,
    required this.sessionType,
    required this.sessionDate,
    required this.status,
    required this.isDeducted,
    this.doctorNotes,
    this.receptionNotes,
    this.absenceReason,
    this.patientName,
    this.doctorName,
  });

  final String id;
  final String patientId;
  final String? doctorId;
  final String? serviceId;
  final String? slotId;
  final String? treatmentPlanId;
  final String? patientPackageId;
  final String sessionType;
  final DateTime sessionDate;
  final String status;
  final bool isDeducted;
  final String? doctorNotes;
  final String? receptionNotes;
  final String? absenceReason;

  /// دي مش موجودة في الـ entity الأصلي، بس ممكن تيجي embedded من الـ API
  /// (join مع المريض/الدكتور)، فبنقراها لو موجودة عشان نعرضها بسهولة.
  final String? patientName;
  final String? doctorName;

  factory SessionModel.fromJson(Map<String, dynamic> json) {
    return SessionModel(
      id: json['id'] ?? '',
      patientId: json['patient_id'] ?? '',
      doctorId: json['doctor_id'],
      serviceId: json['service_id'],
      slotId: json['slot_id'],
      treatmentPlanId: json['treatment_plan_id'],
      patientPackageId: json['patient_package_id'],
      sessionType: json['session_type'] ?? 'TREATMENT',
      sessionDate: DateTime.tryParse(json['session_date'] ?? '') ?? DateTime.now(),
      status: json['status'] ?? 'SCHEDULED',
      isDeducted: json['is_deducted'] ?? false,
      doctorNotes: json['doctor_notes'],
      receptionNotes: json['reception_notes'],
      absenceReason: json['absence_reason'],
      patientName: json['patient'] != null
          ? '${json['patient']['first_name'] ?? ''} ${json['patient']['last_name'] ?? ''}'.trim()
          : null,
      doctorName: json['doctor'] != null ? json['doctor']['name'] : null,
    );
  }
}
