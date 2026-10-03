import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/enum_labels.dart';
import '../../core/widgets/empty_view.dart';
import '../../core/widgets/error_view.dart';
import '../../core/widgets/loading_view.dart';
import '../../core/widgets/status_badge.dart';
import '../../cubits/patients_cubit.dart';
import '../../models/patient_model.dart';
import '../../repositories/patients_repository.dart';
import '../../routes/app_routes.dart';

class PatientsListScreen extends StatelessWidget {
  const PatientsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PatientsCubit(PatientsRepository())..loadPatients(),
      child: const _PatientsListView(),
    );
  }
}

class _PatientsListView extends StatefulWidget {
  const _PatientsListView();

  @override
  State<_PatientsListView> createState() => _PatientsListViewState();
}

class _PatientsListViewState extends State<_PatientsListView> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('المرضى')),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () async {
          await Navigator.pushNamed(context, AppRoutes.patientForm);
          if (context.mounted) context.read<PatientsCubit>().refresh();
        },
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'ابحث بالاسم، الكود، أو التليفون...',
                prefixIcon: Icon(Icons.search_rounded),
              ),
              onSubmitted: (value) => context.read<PatientsCubit>().loadPatients(search: value),
            ),
          ),
          Expanded(
            child: BlocBuilder<PatientsCubit, PatientsState>(
              builder: (context, state) {
                if (state.status == PatientsStatus.loading || state.status == PatientsStatus.initial) {
                  return const LoadingView();
                }
                if (state.status == PatientsStatus.error) {
                  return ErrorView(
                    message: state.errorMessage ?? 'حصل خطأ',
                    onRetry: () => context.read<PatientsCubit>().loadPatients(),
                  );
                }
                if (state.patients.isEmpty) {
                  return const EmptyView(message: 'مفيش مرضى مسجلين لسه', icon: Icons.people_outline_rounded);
                }
                return RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () => context.read<PatientsCubit>().refresh(),
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 90),
                    itemCount: state.patients.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) => _PatientTile(patient: state.patients[index]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _PatientTile extends StatelessWidget {
  const _PatientTile({required this.patient});

  final PatientModel patient;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () async {
        await Navigator.pushNamed(context, AppRoutes.patientDetail, arguments: patient.id);
        if (context.mounted) context.read<PatientsCubit>().refresh();
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.bgLayer1,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: AppColors.primary.withValues(alpha: 0.15),
              child: Text(
                patient.firstName.isNotEmpty ? patient.firstName[0] : '؟',
                style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(patient.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(
                    '${patient.patientCode} ${patient.phone != null ? '• ${patient.phone}' : ''}',
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  ),
                ],
              ),
            ),
            StatusBadge(
              label: EnumLabels.label(EnumLabels.patientStatus, patient.status),
              color: EnumLabels.statusColor(patient.status),
            ),
          ],
        ),
      ),
    );
  }
}
