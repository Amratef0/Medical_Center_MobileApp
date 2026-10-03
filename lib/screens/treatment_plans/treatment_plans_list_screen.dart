import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/app_dialogs.dart';
import '../../core/utils/enum_labels.dart';
import '../../core/widgets/empty_view.dart';
import '../../core/widgets/error_view.dart';
import '../../core/widgets/loading_view.dart';
import '../../core/widgets/status_badge.dart';
import '../../cubits/treatment_plans_cubit.dart';
import '../../models/doctor_model.dart';
import '../../models/patient_model.dart';
import '../../repositories/doctors_repository.dart';
import '../../repositories/patients_repository.dart';
import '../../repositories/treatment_plans_repository.dart';

class TreatmentPlansListScreen extends StatelessWidget {
  const TreatmentPlansListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TreatmentPlansCubit(TreatmentPlansRepository())..loadPlans(),
      child: const _TreatmentPlansView(),
    );
  }
}

class _TreatmentPlansView extends StatelessWidget {
  const _TreatmentPlansView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('خطط العلاج')),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => _showAddPlanSheet(context),
        child: const Icon(Icons.add),
      ),
      body: BlocConsumer<TreatmentPlansCubit, TreatmentPlansState>(
        listener: (context, state) {
          if (state.errorMessage != null && !state.isSubmitting) {
            AppDialogs.showError(context, state.errorMessage!);
          }
        },
        builder: (context, state) {
          if (state.status == TreatmentPlansStatus.loading || state.status == TreatmentPlansStatus.initial) {
            return const LoadingView();
          }
          if (state.status == TreatmentPlansStatus.error) {
            return ErrorView(
              message: state.errorMessage ?? 'حصل خطأ',
              onRetry: () => context.read<TreatmentPlansCubit>().loadPlans(),
            );
          }
          if (state.plans.isEmpty) {
            return const EmptyView(message: 'مفيش خطط علاج لسه', icon: Icons.assignment_outlined);
          }
          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () => context.read<TreatmentPlansCubit>().loadPlans(),
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 90),
              itemCount: state.plans.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final plan = state.plans[index];
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
                            Text(plan.patientName ?? 'مريض', style: const TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(
                              '${plan.totalSessions} جلسة${plan.frequency != null ? ' - ${plan.frequency}' : ''}',
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                            ),
                            if (plan.doctorName != null)
                              Text('د. ${plan.doctorName}',
                                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                          ],
                        ),
                      ),
                      StatusBadge(label: plan.status, color: EnumLabels.statusColor(plan.status)),
                      IconButton(
                        icon: const Icon(Icons.delete_outline_rounded, color: AppColors.danger),
                        onPressed: () async {
                          final confirmed = await AppDialogs.confirmDelete(context);
                          if (confirmed && context.mounted) {
                            context.read<TreatmentPlansCubit>().deletePlan(plan.id);
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

  void _showAddPlanSheet(BuildContext context) {
    final cubit = context.read<TreatmentPlansCubit>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.bgLayer1,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => BlocProvider.value(
        value: cubit,
        child: const _AddPlanSheet(),
      ),
    );
  }
}

class _AddPlanSheet extends StatefulWidget {
  const _AddPlanSheet();

  @override
  State<_AddPlanSheet> createState() => _AddPlanSheetState();
}

class _AddPlanSheetState extends State<_AddPlanSheet> {
  final _patientsRepository = PatientsRepository();
  final _doctorsRepository = DoctorsRepository();
  final _sessionsController = TextEditingController(text: '10');
  final _frequencyController = TextEditingController();

  List<PatientModel> _patients = [];
  List<DoctorModel> _doctors = [];
  bool _loading = true;
  String? _patientId;
  String? _doctorId;

  @override
  void initState() {
    super.initState();
    _loadOptions();
  }

  Future<void> _loadOptions() async {
    final patients = await _patientsRepository.getPatients(limit: 100);
    final doctors = await _doctorsRepository.getDoctors(limit: 100);
    if (mounted) setState(() { _patients = patients; _doctors = doctors; _loading = false; });
  }

  @override
  void dispose() {
    _sessionsController.dispose();
    _frequencyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16, right: 16, top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: _loading
          ? const SizedBox(height: 200, child: LoadingView())
          : SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('خطة علاج جديدة', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: _patientId,
                    decoration: const InputDecoration(labelText: 'المريض'),
                    isExpanded: true,
                    items: _patients.map((p) => DropdownMenuItem(value: p.id, child: Text(p.fullName))).toList(),
                    onChanged: (v) => setState(() => _patientId = v),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _doctorId,
                    decoration: const InputDecoration(labelText: 'الدكتور المسؤول'),
                    isExpanded: true,
                    items: _doctors.map((d) => DropdownMenuItem(value: d.id, child: Text(d.name))).toList(),
                    onChanged: (v) => setState(() => _doctorId = v),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _sessionsController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'عدد الجلسات'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _frequencyController,
                    decoration: const InputDecoration(labelText: 'التكرار (مثلا: مرتين أسبوعيا)'),
                  ),
                  const SizedBox(height: 20),
                  BlocBuilder<TreatmentPlansCubit, TreatmentPlansState>(
                    builder: (context, state) {
                      return ElevatedButton(
                        onPressed: state.isSubmitting || _patientId == null
                            ? null
                            : () async {
                                final success = await context.read<TreatmentPlansCubit>().createPlan(
                                      patientId: _patientId!,
                                      doctorId: _doctorId,
                                      totalSessions: int.tryParse(_sessionsController.text) ?? 10,
                                      frequency: _frequencyController.text.trim(),
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
