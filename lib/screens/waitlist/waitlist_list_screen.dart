import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/app_dialogs.dart';
import '../../core/utils/date_helper.dart';
import '../../core/widgets/empty_view.dart';
import '../../core/widgets/error_view.dart';
import '../../core/widgets/loading_view.dart';
import '../../cubits/waitlist_cubit.dart';
import '../../models/patient_model.dart';
import '../../repositories/patients_repository.dart';
import '../../repositories/waitlist_repository.dart';

class WaitlistListScreen extends StatelessWidget {
  const WaitlistListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => WaitlistCubit(WaitlistRepository())..loadWaitlist(),
      child: const _WaitlistView(),
    );
  }
}

class _WaitlistView extends StatelessWidget {
  const _WaitlistView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('قائمة الانتظار')),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => _showAddSheet(context),
        child: const Icon(Icons.add),
      ),
      body: BlocConsumer<WaitlistCubit, WaitlistState>(
        listener: (context, state) {
          if (state.errorMessage != null && !state.isSubmitting) {
            AppDialogs.showError(context, state.errorMessage!);
          }
        },
        builder: (context, state) {
          if (state.status == WaitlistStatus.loading || state.status == WaitlistStatus.initial) {
            return const LoadingView();
          }
          if (state.status == WaitlistStatus.error) {
            return ErrorView(
              message: state.errorMessage ?? 'حصل خطأ',
              onRetry: () => context.read<WaitlistCubit>().loadWaitlist(),
            );
          }
          if (state.items.isEmpty) {
            return const EmptyView(message: 'قائمة الانتظار فاضية', icon: Icons.list_alt_rounded);
          }
          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () => context.read<WaitlistCubit>().loadWaitlist(),
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 90),
              itemCount: state.items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final item = state.items[index];
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
                            Text(item.patientName ?? 'مريض', style: const TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(
                              item.preferredDate != null
                                  ? 'المعاد المفضل: ${DateHelper.formatDate(item.preferredDate)}'
                                  : 'بدون معاد محدد',
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline_rounded, color: AppColors.danger),
                        onPressed: () async {
                          final confirmed = await AppDialogs.confirmDelete(context);
                          if (confirmed && context.mounted) {
                            context.read<WaitlistCubit>().removeFromWaitlist(item.id);
                          }
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _showAddSheet(BuildContext context) {
    final cubit = context.read<WaitlistCubit>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.bgLayer1,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => BlocProvider.value(value: cubit, child: const _AddWaitlistSheet()),
    );
  }
}

class _AddWaitlistSheet extends StatefulWidget {
  const _AddWaitlistSheet();

  @override
  State<_AddWaitlistSheet> createState() => _AddWaitlistSheetState();
}

class _AddWaitlistSheetState extends State<_AddWaitlistSheet> {
  final _patientsRepository = PatientsRepository();
  final _notesController = TextEditingController();

  List<PatientModel> _patients = [];
  bool _loading = true;
  String? _patientId;
  DateTime? _preferredDate;

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
    _notesController.dispose();
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
                  const Text('إضافة لقائمة الانتظار', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: _patientId,
                    decoration: const InputDecoration(labelText: 'المريض'),
                    isExpanded: true,
                    items: _patients.map((p) => DropdownMenuItem(value: p.id, child: Text(p.fullName))).toList(),
                    onChanged: (v) => setState(() => _patientId = v),
                  ),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null) setState(() => _preferredDate = picked);
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(labelText: 'المعاد المفضل'),
                      child: Text(_preferredDate == null ? 'اختر تاريخ' : DateHelper.formatDate(_preferredDate)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _notesController,
                    decoration: const InputDecoration(labelText: 'ملاحظات'),
                  ),
                  const SizedBox(height: 20),
                  BlocBuilder<WaitlistCubit, WaitlistState>(
                    builder: (context, state) {
                      return ElevatedButton(
                        onPressed: state.isSubmitting || _patientId == null
                            ? null
                            : () async {
                                final success = await context.read<WaitlistCubit>().addToWaitlist(
                                      patientId: _patientId!,
                                      preferredDate: _preferredDate?.toIso8601String(),
                                      notes: _notesController.text.trim(),
                                    );
                                if (success && context.mounted) Navigator.pop(context);
                              },
                        child: state.isSubmitting
                            ? const SizedBox(
                                height: 20, width: 20,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : const Text('إضافة'),
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }
}
