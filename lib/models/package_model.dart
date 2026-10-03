/// نموذج الباقة - نفس package.entity.ts
class PackageModel {
  PackageModel({
    required this.id,
    required this.name,
    this.description,
    required this.totalSessions,
    this.expiryDays,
    this.price,
    required this.isCustom,
    required this.isActive,
  });

  final String id;
  final String name;
  final String? description;
  final int totalSessions;
  final int? expiryDays;
  final double? price;
  final bool isCustom;
  final bool isActive;

  factory PackageModel.fromJson(Map<String, dynamic> json) {
    return PackageModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      totalSessions: json['total_sessions'] ?? 0,
      expiryDays: json['expiry_days'],
      price: json['price'] != null ? double.tryParse(json['price'].toString()) : null,
      isCustom: json['is_custom'] ?? false,
      isActive: json['is_active'] ?? true,
    );
  }
}

/// نموذج باقة مربوطة بمريض معيّن - نفس patient-package.entity.ts
class PatientPackageModel {
  PatientPackageModel({
    required this.id,
    required this.patientId,
    required this.packageId,
    required this.status,
    required this.remainingSessions,
    this.startDate,
    this.endDate,
    this.packageName,
  });

  final String id;
  final String patientId;
  final String packageId;
  final String status;
  final int remainingSessions;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? packageName;

  factory PatientPackageModel.fromJson(Map<String, dynamic> json) {
    return PatientPackageModel(
      id: json['id'] ?? '',
      patientId: json['patient_id'] ?? '',
      packageId: json['package_id'] ?? '',
      status: json['status'] ?? 'ACTIVE',
      remainingSessions: json['remaining_sessions'] ?? 0,
      startDate: json['start_date'] != null ? DateTime.tryParse(json['start_date']) : null,
      endDate: json['end_date'] != null ? DateTime.tryParse(json['end_date']) : null,
      packageName: json['package'] != null ? json['package']['name'] : null,
    );
  }
}
