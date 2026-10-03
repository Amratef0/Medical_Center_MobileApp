import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/app_dialogs.dart';
import '../../core/utils/date_helper.dart';
import '../../core/utils/enum_labels.dart';
import '../../core/widgets/empty_view.dart';
import '../../core/widgets/error_view.dart';
import '../../core/widgets/loading_view.dart';
import '../../core/widgets/status_badge.dart';
import '../../cubits/finance_cubit.dart';
import '../../models/patient_model.dart';
import '../../repositories/finance_repository.dart';
import '../../repositories/patients_repository.dart';

class FinanceScreen extends StatelessWidget {
  const FinanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => FinanceCubit(FinanceRepository())..loadAll(),
      child: const _FinanceView(),
    );
  }
}

class _FinanceView extends StatelessWidget {
  const _FinanceView();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('المالية'),
          bottom: const TabBar(
            indicatorColor: AppColors.primary,
            tabs: [Tab(text: 'المدفوعات'), Tab(text: 'الفواتير')],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: AppColors.primary,
          onPressed: () => _showAddPaymentSheet(context),
          child: const Icon(Icons.add),
        ),
        body: TabBarView(
          children: [
            BlocConsumer<FinanceCubit, FinanceState>(
              listener: (context, state) {
                if (state.errorMessage != null && !state.isSubmitting) {
                  AppDialogs.showError(context, state.errorMessage!);
                }
              },
              builder: (context, state) {
                if (state.status == FinanceStatus.loading || state.status == FinanceStatus.initial) {
                  return const LoadingView();
                }
                if (state.status == FinanceStatus.error) {
                  return ErrorView(
                    message: state.errorMessage ?? 'حصل خطأ',
                    onRetry: () => context.read<FinanceCubit>().loadAll(),
                  );
                }
                if (state.payments.isEmpty) {
                  return const EmptyView(message: 'مفيش مدفوعات لسه', icon: Icons.payments_outlined);
                }
                return RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () => context.read<FinanceCubit>().loadAll(),
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 90),
                    itemCount: state.payments.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final payment = state.payments[index];
                      return Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.bgLayer1,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${payment.amount} ج.م', style: const TextStyle(fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 4),
                                  Text(
                                    DateHelper.formatDateTime(payment.createdAt),
                                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                            StatusBadge(
                              label: EnumLabels.label(EnumLabels.paymentStatus, payment.status),
                              color: EnumLabels.statusColor(payment.status),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
            ),
            BlocBuilder<FinanceCubit, FinanceState>(
              builder: (context, state) {
                if (state.status == FinanceStatus.loading || state.status == FinanceStatus.initial) {
                  return const LoadingView();
                }
                if (state.invoices.isEmpty) {
                  return const EmptyView(message: 'مفيش فواتير لسه', icon: Icons.receipt_long_outlined);
                }
                return RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () => context.read<FinanceCubit>().loadAll(),
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 90),
                    itemCount: state.invoices.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final invoice = state.invoices[index];
                      return Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.bgLayer1,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('فاتورة ${invoice.invoiceNumber}',
                                      style: const TextStyle(fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 4),
                                  Text('${invoice.totalAmount} ج.م',
                                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                                ],
                              ),
                            ),
                            StatusBadge(
                              label: EnumLabels.label(EnumLabels.invoiceStatus, invoice.status),
                              color: EnumLabels.statusColor(invoice.status),
                            ),
                            if (invoice.status == 'PENDING')
                              IconButton(
                                icon: const Icon(Icons.check_circle_outline_rounded, color: AppColors.success),
                                onPressed: () => context.read<FinanceCubit>().markInvoicePaid(invoice.id),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAddPaymentSheet(BuildContext context) {
    final cubit = context.read<FinanceCubit>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.bgLayer1,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => BlocProvider.value(value: cubit, child: const _AddPaymentSheet()),
    );
  }
}

class _AddPaymentSheet extends StatefulWidget {
  const _AddPaymentSheet();

  @override
  State<_AddPaymentSheet> createState() => _AddPaymentSheetState();
}

class _AddPaymentSheetState extends State<_AddPaymentSheet> {
  final _patientsRepository = PatientsRepository();
  final _amountController = TextEditingController();
  final _discountController = TextEditingController(text: '0');

  List<PatientModel> _patients = [];
  bool _loading = true;
  String? _patientId;

  @override
  void initState() {
    super.initState();
    _loadPatients();
  }

  Future<void> _loadPatients() async {
    final patients = await _patientsRepository.getPatients(limit: 100);
    if (mounted) setState(() { _patients = patients; _loading = false; });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _discountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: MediaQuery.of(context).viewInsets.bottom + 16),
      child: _loading
          ? const SizedBox(height: 200, child: LoadingView())
          : SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('دفعة جديدة', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: _patientId,
                    decoration: const InputDecoration(labelText: 'المريض'),
                    isExpanded: true,
                    items: _patients.map((p) => DropdownMenuItem(value: p.id, child: Text(p.fullName))).toList(),
                    onChanged: (v) => setState(() => _patientId = v),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'المبلغ'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _discountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'الخصم'),
                  ),
                  const SizedBox(height: 20),
                  BlocBuilder<FinanceCubit, FinanceState>(
                    builder: (context, state) {
                      return ElevatedButton(
                        onPressed: state.isSubmitting || _patientId == null
                            ? null
                            : () async {
                                final success = await context.read<FinanceCubit>().createPayment(
                                      patientId: _patientId!,
                                      amount: double.tryParse(_amountController.text) ?? 0,
                                      discount: double.tryParse(_discountController.text) ?? 0,
                                    );
                                if (success && context.mounted) Navigator.pop(context);
                              },
                        child: state.isSubmitting
                            ? const SizedBox(
                                height: 20, width: 20,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : const Text('إضافة الدفعة'),
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }
}
