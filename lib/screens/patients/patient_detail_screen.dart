import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/app_dialogs.dart';
import '../../core/utils/date_helper.dart';
import '../../core/utils/enum_labels.dart';
import '../../core/widgets/error_view.dart';
import '../../core/widgets/info_row.dart';
import '../../core/widgets/loading_view.dart';
import '../../core/widgets/section_card.dart';
import '../../core/widgets/status_badge.dart';
import '../../cubits/patient_detail_cubit.dart';
import '../../cubits/patients_cubit.dart';
import '../../cubits/medical_documents_cubit.dart';
import '../../models/medical_history_model.dart';
import '../../repositories/medical_documents_repository.dart';
import '../../repositories/packages_repository.dart';
import '../../repositories/patients_repository.dart';
import '../../repositories/sessions_repository.dart';
import '../../repositories/treatment_plans_repository.dart';
import '../../routes/app_routes.dart';

class PatientDetailScreen extends StatelessWidget {
  const PatientDetailScreen({super.key, required this.patientId});

  final String patientId;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => PatientDetailCubit(
            patientsRepository: PatientsRepository(),
            sessionsRepository: SessionsRepository(),
            treatmentPlansRepository: TreatmentPlansRepository(),
            packagesRepository: PackagesRepository(),
          )..loadPatientDetails(patientId),
        ),
        BlocProvider(create: (_) => PatientsCubit(PatientsRepository())),
        BlocProvider(
          create: (_) => MedicalDocumentsCubit(MedicalDocumentsRepository())..loadDocuments(patientId),
        ),
      ],
      child: _PatientDetailView(patientId: patientId),
    );
  }
}

class _PatientDetailView extends StatelessWidget {
  const _PatientDetailView({required this.patientId});

  final String patientId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تفاصيل المريض'),
        actions: [
          BlocBuilder<PatientDetailCubit, PatientDetailState>(
            builder: (context, state) {
              if (state.patient == null) return const SizedBox.shrink();
              return PopupMenuButton<String>(
                onSelected: (value) async {
                  if (value == 'edit') {
                    await Navigator.pushNamed(context, AppRoutes.patientForm, arguments: state.patient);
                    if (context.mounted) {
                      context.read<PatientDetailCubit>().loadPatientDetails(patientId);
                    }
                  } else if (value == 'delete') {
                    final confirmed = await AppDialogs.confirmDelete(context,
                        message: 'متأكد إنك عايز تحذف المريض ده وكل بياناته؟');
                    if (confirmed && context.mounted) {
                      final ok = await context.read<PatientsCubit>().deletePatient(patientId);
                      if (ok && context.mounted) Navigator.pop(context);
                    }
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'edit', child: Text('تعديل')),
                  PopupMenuItem(value: 'delete', child: Text('حذف')),
                ],
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<PatientDetailCubit, PatientDetailState>(
        builder: (context, state) {
          if (state.status == PatientDetailStatus.loading || state.status == PatientDetailStatus.initial) {
            return const LoadingView();
          }
          if (state.status == PatientDetailStatus.error || state.patient == null) {
            return ErrorView(
              message: state.errorMessage ?? 'حصل خطأ في تحميل بيانات المريض',
              onRetry: () => context.read<PatientDetailCubit>().loadPatientDetails(patientId),
            );
          }

          final patient = state.patient!;
          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () => context.read<PatientDetailCubit>().loadPatientDetails(patientId),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                SectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(patient.fullName,
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          ),
                          StatusBadge(
                            label: EnumLabels.label(EnumLabels.patientStatus, patient.status),
                            color: EnumLabels.statusColor(patient.status),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      InfoRow(label: 'الكود', value: patient.patientCode),
                      InfoRow(label: 'التليفون', value: patient.phone ?? '-'),
                      InfoRow(label: 'الواتساب', value: patient.whatsappNumber ?? '-'),
                      InfoRow(label: 'البريد', value: patient.email ?? '-'),
                      InfoRow(label: 'العنوان', value: patient.address ?? '-'),
                      InfoRow(label: 'تاريخ التسجيل', value: DateHelper.formatDate(patient.registrationDate)),
                      if (patient.notes != null && patient.notes!.isNotEmpty)
                        InfoRow(label: 'ملاحظات', value: patient.notes!),
                    ],
                  ),
                ),
                SectionCard(
                  title: 'الجلسات (${state.sessions.length})',
                  child: state.sessions.isEmpty
                      ? const Text('لا يوجد جلسات لسه', style: TextStyle(color: AppColors.textSecondary))
                      : Column(
                          children: state.sessions.take(5).map((session) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(DateHelper.formatDateTime(session.sessionDate)),
                                  ),
                                  StatusBadge(
                                    label: EnumLabels.label(EnumLabels.sessionStatus, session.status),
                                    color: EnumLabels.statusColor(session.status),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                ),
                SectionCard(
                  title: 'خطط العلاج (${state.treatmentPlans.length})',
                  child: state.treatmentPlans.isEmpty
                      ? const Text('لا يوجد خطط علاج', style: TextStyle(color: AppColors.textSecondary))
                      : Column(
                          children: state.treatmentPlans.map((plan) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Row(
                                children: [
                                  Expanded(child: Text('${plan.totalSessions} جلسة - ${plan.doctorName ?? ''}')),
                                  StatusBadge(label: plan.status, color: EnumLabels.statusColor(plan.status)),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                ),
                SectionCard(
                  title: 'الباقات (${state.patientPackages.length})',
                  child: state.patientPackages.isEmpty
                      ? const Text('لا يوجد باقات', style: TextStyle(color: AppColors.textSecondary))
                      : Column(
                          children: state.patientPackages.map((pkg) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text('${pkg.packageName ?? 'باقة'} - متبقي ${pkg.remainingSessions} جلسة'),
                                  ),
                                  StatusBadge(
                                    label: EnumLabels.label(EnumLabels.patientPackageStatus, pkg.status),
                                    color: EnumLabels.statusColor(pkg.status),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                ),
                _MedicalHistorySection(history: state.medicalHistory),
                const _MedicalDocumentsSection(),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// قسم التاريخ الطبي: حساسيات، أمراض مزمنة، أدوية، عمليات، ملاحظات.
/// المستخدم يقدر يعدّل ويحفظ من نفس الشاشة.
class _MedicalHistorySection extends StatefulWidget {
  const _MedicalHistorySection({required this.history});

  final MedicalHistoryModel? history;

  @override
  State<_MedicalHistorySection> createState() => _MedicalHistorySectionState();
}

class _MedicalHistorySectionState extends State<_MedicalHistorySection> {
  late final TextEditingController _allergiesController;
  late final TextEditingController _chronicController;
  late final TextEditingController _medicationsController;
  late final TextEditingController _surgeriesController;
  late final TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _allergiesController = TextEditingController(text: widget.history?.allergies ?? '');
    _chronicController = TextEditingController(text: widget.history?.chronicDiseases ?? '');
    _medicationsController = TextEditingController(text: widget.history?.medications ?? '');
    _surgeriesController = TextEditingController(text: widget.history?.surgeries ?? '');
    _notesController = TextEditingController(text: widget.history?.notes ?? '');
  }

  @override
  void dispose() {
    _allergiesController.dispose();
    _chronicController.dispose();
    _medicationsController.dispose();
    _surgeriesController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'التاريخ الطبي',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _allergiesController,
            decoration: const InputDecoration(labelText: 'الحساسيات'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _chronicController,
            decoration: const InputDecoration(labelText: 'الأمراض المزمنة'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _medicationsController,
            decoration: const InputDecoration(labelText: 'الأدوية الحالية'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _surgeriesController,
            decoration: const InputDecoration(labelText: 'العمليات السابقة'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _notesController,
            maxLines: 2,
            decoration: const InputDecoration(labelText: 'ملاحظات'),
          ),
          const SizedBox(height: 12),
          BlocBuilder<PatientDetailCubit, PatientDetailState>(
            builder: (context, state) {
              return Align(
                alignment: Alignment.centerLeft,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.save_outlined, size: 18),
                  label: state.isSavingHistory ? const Text('جاري الحفظ...') : const Text('حفظ التاريخ الطبي'),
                  onPressed: state.isSavingHistory
                      ? null
                      : () async {
                          final success = await context.read<PatientDetailCubit>().saveMedicalHistory(
                                allergies: _allergiesController.text.trim(),
                                chronicDiseases: _chronicController.text.trim(),
                                medications: _medicationsController.text.trim(),
                                surgeries: _surgeriesController.text.trim(),
                                notes: _notesController.text.trim(),
                              );
                          if (!context.mounted) return;
                          if (success) {
                            AppDialogs.showSuccess(context, 'تم حفظ التاريخ الطبي');
                          } else {
                            AppDialogs.showError(context, 'حصل خطأ أثناء الحفظ');
                          }
                        },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// قسم المستندات الطبية: روشتات / أشعة / تقارير خاصة بالمريض.
class _MedicalDocumentsSection extends StatelessWidget {
  const _MedicalDocumentsSection();

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'المستندات الطبية',
      trailing: IconButton(
        icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.primary),
        onPressed: () => _showAddDocumentSheet(context),
      ),
      child: BlocConsumer<MedicalDocumentsCubit, MedicalDocumentsState>(
        listener: (context, state) {
          if (state.errorMessage != null && !state.isSubmitting) {
            AppDialogs.showError(context, state.errorMessage!);
          }
        },
        builder: (context, state) {
          if (state.status == MedicalDocumentsStatus.loading || state.status == MedicalDocumentsStatus.initial) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
            );
          }
          if (state.documents.isEmpty) {
            return const Text('لا يوجد مستندات طبية لسه', style: TextStyle(color: AppColors.textSecondary));
          }
          return Column(
            children: state.documents.map((doc) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    const Icon(Icons.description_outlined, color: AppColors.teal, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(doc.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                          Text(
                            EnumLabels.label(EnumLabels.documentType, doc.type),
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, color: AppColors.danger, size: 20),
                      onPressed: () async {
                        final confirmed = await AppDialogs.confirmDelete(context);
                        if (confirmed && context.mounted) {
                          context.read<MedicalDocumentsCubit>().deleteDocument(doc.id);
                        }
                      },
                    ),
                  ],
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  void _showAddDocumentSheet(BuildContext context) {
    final cubit = context.read<MedicalDocumentsCubit>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.bgLayer1,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => BlocProvider.value(value: cubit, child: const _AddDocumentSheet()),
    );
  }
}

class _AddDocumentSheet extends StatefulWidget {
  const _AddDocumentSheet();

  @override
  State<_AddDocumentSheet> createState() => _AddDocumentSheetState();
}

class _AddDocumentSheetState extends State<_AddDocumentSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  String _type = 'REPORT';

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: MediaQuery.of(context).viewInsets.bottom + 16),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('مستند طبي جديد', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _type,
                decoration: const InputDecoration(labelText: 'النوع'),
                items: EnumLabels.documentType.entries
                    .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
                    .toList(),
                onChanged: (v) => setState(() => _type = v!),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'العنوان'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'مطلوب' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _contentController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'التفاصيل'),
              ),
              const SizedBox(height: 20),
              BlocBuilder<MedicalDocumentsCubit, MedicalDocumentsState>(
                builder: (context, state) {
                  return ElevatedButton(
                    onPressed: state.isSubmitting
                        ? null
                        : () async {
                            if (!_formKey.currentState!.validate()) return;
                            final success = await context.read<MedicalDocumentsCubit>().createDocument(
                                  type: _type,
                                  title: _titleController.text.trim(),
                                  content: _contentController.text.trim(),
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
      ),
    );
  }
}
