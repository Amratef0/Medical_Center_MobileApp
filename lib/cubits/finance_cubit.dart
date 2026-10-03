import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/network/api_error.dart';
import '../models/invoice_model.dart';
import '../models/payment_model.dart';
import '../repositories/finance_repository.dart';

enum FinanceStatus { initial, loading, loaded, error }

class FinanceState {
  const FinanceState({
    this.status = FinanceStatus.initial,
    this.payments = const [],
    this.invoices = const [],
    this.errorMessage,
    this.isSubmitting = false,
  });

  final FinanceStatus status;
  final List<PaymentModel> payments;
  final List<InvoiceModel> invoices;
  final String? errorMessage;
  final bool isSubmitting;

  FinanceState copyWith({
    FinanceStatus? status,
    List<PaymentModel>? payments,
    List<InvoiceModel>? invoices,
    String? errorMessage,
    bool? isSubmitting,
  }) {
    return FinanceState(
      status: status ?? this.status,
      payments: payments ?? this.payments,
      invoices: invoices ?? this.invoices,
      errorMessage: errorMessage,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}

/// المسؤول عن شاشة "المالية": المدفوعات والفواتير مع بعض.
class FinanceCubit extends Cubit<FinanceState> {
  FinanceCubit(this._repository) : super(const FinanceState());

  final FinanceRepository _repository;

  Future<void> loadAll() async {
    emit(state.copyWith(status: FinanceStatus.loading, errorMessage: null));
    try {
      final payments = await _repository.getPayments();
      final invoices = await _repository.getInvoices();
      emit(state.copyWith(
        status: FinanceStatus.loaded,
        payments: payments,
        invoices: invoices,
      ));
    } catch (e) {
      emit(state.copyWith(status: FinanceStatus.error, errorMessage: extractErrorMessage(e)));
    }
  }

  Future<bool> createPayment({
    required String patientId,
    String? patientPackageId,
    required double amount,
    double discount = 0,
  }) async {
    emit(state.copyWith(isSubmitting: true, errorMessage: null));
    try {
      await _repository.createPayment(
        patientId: patientId,
        patientPackageId: patientPackageId,
        amount: amount,
        discount: discount,
      );
      emit(state.copyWith(isSubmitting: false));
      await loadAll();
      return true;
    } catch (e) {
      emit(state.copyWith(isSubmitting: false, errorMessage: extractErrorMessage(e)));
      return false;
    }
  }

  Future<bool> createInvoice({
    required String patientId,
    required double subtotal,
    double discount = 0,
  }) async {
    emit(state.copyWith(isSubmitting: true, errorMessage: null));
    try {
      await _repository.createInvoice(patientId: patientId, subtotal: subtotal, discount: discount);
      emit(state.copyWith(isSubmitting: false));
      await loadAll();
      return true;
    } catch (e) {
      emit(state.copyWith(isSubmitting: false, errorMessage: extractErrorMessage(e)));
      return false;
    }
  }

  Future<bool> markInvoicePaid(String id) async {
    emit(state.copyWith(isSubmitting: true, errorMessage: null));
    try {
      await _repository.markInvoicePaid(id);
      emit(state.copyWith(isSubmitting: false));
      await loadAll();
      return true;
    } catch (e) {
      emit(state.copyWith(isSubmitting: false, errorMessage: extractErrorMessage(e)));
      return false;
    }
  }
}
