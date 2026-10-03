/// نموذج الفاتورة - نفس invoice.entity.ts
class InvoiceModel {
  InvoiceModel({
    required this.id,
    required this.invoiceNumber,
    required this.patientId,
    this.paymentId,
    required this.subtotal,
    required this.discount,
    required this.totalAmount,
    required this.status,
    this.issuedAt,
    this.paidAt,
  });

  final String id;
  final String invoiceNumber;
  final String patientId;
  final String? paymentId;
  final double subtotal;
  final double discount;
  final double totalAmount;
  final String status;
  final DateTime? issuedAt;
  final DateTime? paidAt;

  factory InvoiceModel.fromJson(Map<String, dynamic> json) {
    return InvoiceModel(
      id: json['id'] ?? '',
      invoiceNumber: json['invoice_number'] ?? '',
      patientId: json['patient_id'] ?? '',
      paymentId: json['payment_id'],
      subtotal: double.tryParse(json['subtotal']?.toString() ?? '0') ?? 0,
      discount: double.tryParse(json['discount']?.toString() ?? '0') ?? 0,
      totalAmount: double.tryParse(json['total_amount']?.toString() ?? '0') ?? 0,
      status: json['status'] ?? 'PENDING',
      issuedAt: json['issued_at'] != null ? DateTime.tryParse(json['issued_at']) : null,
      paidAt: json['paid_at'] != null ? DateTime.tryParse(json['paid_at']) : null,
    );
  }
}
