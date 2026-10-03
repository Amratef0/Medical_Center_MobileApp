import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/app_dialogs.dart';
import '../../core/widgets/empty_view.dart';
import '../../core/widgets/error_view.dart';
import '../../core/widgets/loading_view.dart';
import '../../cubits/doctors_cubit.dart';
import '../../repositories/doctors_repository.dart';
import '../../routes/app_routes.dart';

class DoctorsListScreen extends StatelessWidget {
  const DoctorsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DoctorsCubit(DoctorsRepository())..loadDoctors(),
      child: Scaffold(
        appBar: AppBar(title: const Text('الأطباء')),
        floatingActionButton: FloatingActionButton(
          backgroundColor: AppColors.primary,
          onPressed: () async {
            final cubit = context.read<DoctorsCubit>();
            await Navigator.pushNamed(context, AppRoutes.doctorForm);
            cubit.loadDoctors();
          },
          child: const Icon(Icons.add),
        ),
        body: BlocConsumer<DoctorsCubit, DoctorsState>(
          listener: (context, state) {
            if (state.errorMessage != null && !state.isSubmitting) {
              AppDialogs.showError(context, state.errorMessage!);
            }
          },
          builder: (context, state) {
            if (state.status == DoctorsStatus.loading || state.status == DoctorsStatus.initial) {
              return const LoadingView();
            }
            if (state.status == DoctorsStatus.error) {
              return ErrorView(
                message: state.errorMessage ?? 'حصل خطأ',
                onRetry: () => context.read<DoctorsCubit>().loadDoctors(),
              );
            }
            if (state.doctors.isEmpty) {
              return const EmptyView(message: 'مفيش أطباء مسجلين لسه', icon: Icons.medical_services_outlined);
            }
            return RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () => context.read<DoctorsCubit>().loadDoctors(),
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 90),
                itemCount: state.doctors.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final doctor = state.doctors[index];
                  return InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () async {
                      final cubit = context.read<DoctorsCubit>();
                      await Navigator.pushNamed(context, AppRoutes.doctorForm, arguments: doctor);
                      cubit.loadDoctors();
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
                        const CircleAvatar(
                          radius: 22,
                          backgroundColor: AppColors.teal,
                          child: Icon(Icons.medical_services_rounded, color: Colors.white, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(doctor.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text(
                                doctor.specialization ?? 'بدون تخصص محدد',
                                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.schedule_rounded, color: AppColors.primary),
                          tooltip: 'مواعيد العمل',
                          onPressed: () => Navigator.pushNamed(context, AppRoutes.doctorAvailability, arguments: doctor),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline_rounded, color: AppColors.danger),
                          onPressed: () async {
                            final confirmed = await AppDialogs.confirmDelete(context);
                            if (confirmed && context.mounted) {
                              context.read<DoctorsCubit>().deleteDoctor(doctor.id);
                            }
                          },
                        ),
                      ],
                    ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
