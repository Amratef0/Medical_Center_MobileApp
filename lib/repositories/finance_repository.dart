import '../core/network/api_client.dart';
import '../core/network/list_response_parser.dart';
import '../models/invoice_model.dart';
import '../models/payment_model.dart';

/// كل اللي يخص المالية، نفس /finance بتاعة الباك اند.
class FinanceRepository {
  final _dio = ApiClient().dio;

  Future<List<PaymentModel>> getPayments() async {
    final response = await _dio.get('/finance/payments');
    final list = extractListData(response.data);
    return list.map((e) => PaymentModel.fromJson(e)).toList();
  }

  Future<PaymentModel> createPayment({
    required String patientId,
    String? packageId,
    String? patientPackageId,
    required double amount,
    double discount = 0,
    String? discountType,
  }) async {
    final response = await _dio.post('/finance/payments', data: {
      'patient_id': patientId,
      if (packageId != null) 'package_id': packageId,
      if (patientPackageId != null) 'patient_package_id': patientPackageId,
      'amount': amount,
      'discount': discount,
      if (discountType != null) 'discount_type': discountType,
    });
    return PaymentModel.fromJson(response.data);
  }

  Future<List<InvoiceModel>> getInvoices() async {
    final response = await _dio.get('/finance/invoices');
    final list = extractListData(response.data);
    return list.map((e) => InvoiceModel.fromJson(e)).toList();
  }

  Future<InvoiceModel> createInvoice({
    required String patientId,
    required double subtotal,
    double discount = 0,
  }) async {
    final response = await _dio.post('/finance/invoices', data: {
      'patient_id': patientId,
      'subtotal': subtotal,
      'discount': discount,
    });
    return InvoiceModel.fromJson(response.data);
  }

  Future<void> markInvoicePaid(String id) async {
    await _dio.patch('/finance/invoices/$id/mark-paid');
  }

  Future<void> cancelInvoice(String id) async {
    await _dio.patch('/finance/invoices/$id/cancel');
  }

  Future<Map<String, dynamic>> getPatientSummary(String patientId) async {
    final response = await _dio.get('/finance/patients/$patientId/summary');
    return response.data as Map<String, dynamic>;
  }
}
