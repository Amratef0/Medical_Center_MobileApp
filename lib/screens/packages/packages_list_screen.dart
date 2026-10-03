import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/app_dialogs.dart';
import '../../core/widgets/empty_view.dart';
import '../../core/widgets/error_view.dart';
import '../../core/widgets/loading_view.dart';
import '../../cubits/packages_cubit.dart';
import '../../models/patient_model.dart';
import '../../repositories/packages_repository.dart';
import '../../repositories/patients_repository.dart';

class PackagesListScreen extends StatelessWidget {
  const PackagesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PackagesCubit(PackagesRepository())..loadPackages(),
      child: const _PackagesView(),
    );
  }
}

class _PackagesView extends StatelessWidget {
  const _PackagesView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الباقات')),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => _showAddSheet(context),
        child: const Icon(Icons.add),
      ),
      body: BlocConsumer<PackagesCubit, PackagesState>(
        listener: (context, state) {
          if (state.errorMessage != null && !state.isSubmitting) {
            AppDialogs.showError(context, state.errorMessage!);
          }
        },
        builder: (context, state) {
          if (state.status == PackagesStatus.loading || state.status == PackagesStatus.initial) {
            return const LoadingView();
          }
          if (state.status == PackagesStatus.error) {
            return ErrorView(
              message: state.errorMessage ?? 'حصل خطأ',
              onRetry: () => context.read<PackagesCubit>().loadPackages(),
            );
          }
          if (state.packages.isEmpty) {
            return const EmptyView(message: 'مفيش باقات لسه', icon: Icons.card_giftcard_outlined);
          }
          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () => context.read<PackagesCubit>().loadPackages(),
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 90),
              itemCount: state.packages.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final pkg = state.packages[index];
                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.bgLayer1,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.card_giftcard_rounded, color: AppColors.teal),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(pkg.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                Text(
                                  '${pkg.totalSessions} جلسة${pkg.price != null ? ' - ${pkg.price} ج.م' : ''}',
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
                                context.read<PackagesCubit>().deletePackage(pkg.id);
                              }
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.person_add_alt_1_rounded, size: 18),
                          label: const Text('تخصيص لمريض'),
                          onPressed: () => _showAssignSheet(context, pkg.id),
                        ),
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
    final cubit = context.read<PackagesCubit>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.bgLayer1,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => BlocProvider.value(value: cubit, child: const _AddPackageSheet()),
    );
  }

  void _showAssignSheet(BuildContext context, String packageId) {
    final cubit = context.read<PackagesCubit>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.bgLayer1,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => BlocProvider.value(value: cubit, child: _AssignPackageSheet(packageId: packageId)),
    );
  }
}

class _AddPackageSheet extends StatefulWidget {
  const _AddPackageSheet();

  @override
  State<_AddPackageSheet> createState() => _AddPackageSheetState();
}

class _AddPackageSheetState extends State<_AddPackageSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _sessionsController = TextEditingController();
  final _priceController = TextEditingController();
  final _expiryController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _sessionsController.dispose();
    _priceController.dispose();
    _expiryController.dispose();
    _descriptionController.dispose();
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
              const Text('باقة جديدة', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'اسم الباقة'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'مطلوب' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _sessionsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'عدد الجلسات'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'مطلوب' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'السعر'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _expiryController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'مدة الصلاحية (أيام)'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'وصف الباقة'),
              ),
              const SizedBox(height: 20),
              BlocBuilder<PackagesCubit, PackagesState>(
                builder: (context, state) {
                  return ElevatedButton(
                    onPressed: state.isSubmitting
                        ? null
                        : () async {
                            if (!_formKey.currentState!.validate()) return;
                            final success = await context.read<PackagesCubit>().createPackage(
                                  name: _nameController.text.trim(),
                                  description: _descriptionController.text.trim(),
                                  totalSessions: int.tryParse(_sessionsController.text) ?? 0,
                                  expiryDays: int.tryParse(_expiryController.text),
                                  price: double.tryParse(_priceController.text),
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

class _AssignPackageSheet extends StatefulWidget {
  const _AssignPackageSheet({required this.packageId});

  final String packageId;

  @override
  State<_AssignPackageSheet> createState() => _AssignPackageSheetState();
}

class _AssignPackageSheetState extends State<_AssignPackageSheet> {
  final _patientsRepository = PatientsRepository();
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
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: MediaQuery.of(context).viewInsets.bottom + 16),
      child: _loading
          ? const SizedBox(height: 200, child: LoadingView())
          : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('تخصيص الباقة لمريض', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _patientId,
                  decoration: const InputDecoration(labelText: 'المريض'),
                  isExpanded: true,
                  items: _patients.map((p) => DropdownMenuItem(value: p.id, child: Text(p.fullName))).toList(),
                  onChanged: (v) => setState(() => _patientId = v),
                ),
                const SizedBox(height: 20),
                BlocBuilder<PackagesCubit, PackagesState>(
                  builder: (context, state) {
                    return ElevatedButton(
                      onPressed: state.isSubmitting || _patientId == null
                          ? null
                          : () async {
                              final success = await context.read<PackagesCubit>().assignToPatient(
                                    patientId: _patientId!,
                                    packageId: widget.packageId,
                                  );
                              if (!context.mounted) return;
                              if (success) {
                                AppDialogs.showSuccess(context, 'تم تخصيص الباقة للمريض بنجاح');
                                Navigator.pop(context);
                              }
                            },
                      child: state.isSubmitting
                          ? const SizedBox(
                              height: 20, width: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Text('تخصيص'),
                    );
                  },
                ),
              ],
            ),
    );
  }
}
