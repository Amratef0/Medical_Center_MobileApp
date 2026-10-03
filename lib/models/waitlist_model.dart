/// نموذج عنصر قائمة الانتظار - نفس waitlist.entity.ts
class WaitlistModel {
  WaitlistModel({
    required this.id,
    required this.patientId,
    this.serviceId,
    this.doctorId,
    this.preferredDate,
    this.preferredTime,
    this.notes,
    this.patientName,
  });

  final String id;
  final String patientId;
  final String? serviceId;
  final String? doctorId;
  final DateTime? preferredDate;
  final String? preferredTime;
  final String? notes;
  final String? patientName;

  factory WaitlistModel.fromJson(Map<String, dynamic> json) {
    return WaitlistModel(
      id: json['id'] ?? '',
      patientId: json['patient_id'] ?? '',
      serviceId: json['service_id'],
      doctorId: json['doctor_id'],
      preferredDate:
          json['preferred_date'] != null ? DateTime.tryParse(json['preferred_date']) : null,
      preferredTime: json['preferred_time'],
      notes: json['notes'],
      patientName: json['patient'] != null
          ? '${json['patient']['first_name'] ?? ''} ${json['patient']['last_name'] ?? ''}'.trim()
          : null,
    );
  }
}
