/// نموذج الدفعة - نفس payment.entity.ts
class PaymentModel {
  PaymentModel({
    required this.id,
    required this.patientId,
    this.packageId,
    this.patientPackageId,
    required this.amount,
    required this.discount,
    this.discountType,
    required this.status,
    required this.approvalStatus,
    this.createdAt,
  });

  final String id;
  final String patientId;
  final String? packageId;
  final String? patientPackageId;
  final double amount;
  final double discount;
  final String? discountType;
  final String status;
  final String approvalStatus;
  final DateTime? createdAt;

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'] ?? '',
      patientId: json['patient_id'] ?? '',
      packageId: json['package_id'],
      patientPackageId: json['patient_package_id'],
      amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0,
      discount: double.tryParse(json['discount']?.toString() ?? '0') ?? 0,
      discountType: json['discount_type'],
      status: json['status'] ?? 'PENDING',
      approvalStatus: json['approval_status'] ?? 'PENDING',
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
    );
  }
}
