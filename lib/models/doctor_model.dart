/// نموذج الدكتور - نفس doctor.entity.ts في الباك اند.
class DoctorModel {
  DoctorModel({
    required this.id,
    required this.name,
    this.specialization,
    this.phone,
    this.email,
    required this.isActive,
  });

  final String id;
  final String name;
  final String? specialization;
  final String? phone;
  final String? email;
  final bool isActive;

  factory DoctorModel.fromJson(Map<String, dynamic> json) {
    return DoctorModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      specialization: json['specialization'],
      phone: json['phone'],
      email: json['email'],
      isActive: json['is_active'] ?? true,
    );
  }
}
