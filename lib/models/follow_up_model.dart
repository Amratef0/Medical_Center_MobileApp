/// نموذج مهمة المتابعة - نفس follow-up.entity.ts
class FollowUpModel {
  FollowUpModel({
    required this.id,
    required this.patientId,
    this.type,
    this.message,
    required this.status,
    this.createdAt,
  });

  final String id;
  final String patientId;
  final String? type;
  final String? message;
  final String status;
  final DateTime? createdAt;

  factory FollowUpModel.fromJson(Map<String, dynamic> json) {
    return FollowUpModel(
      id: json['id'] ?? '',
      patientId: json['patient_id'] ?? '',
      type: json['type'],
      message: json['message'],
      status: json['status'] ?? 'PENDING',
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
    );
  }
}
