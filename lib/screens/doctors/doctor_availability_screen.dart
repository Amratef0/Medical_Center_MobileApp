import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/app_dialogs.dart';
import '../../core/widgets/empty_view.dart';
import '../../core/widgets/error_view.dart';
import '../../core/widgets/loading_view.dart';
import '../../cubits/doctor_availability_cubit.dart';
import '../../models/doctor_availability_model.dart';
import '../../models/doctor_model.dart';
import '../../repositories/doctors_repository.dart';

/// شاشة مواعيد عمل الدكتور: بتعرض الأيام والساعات المتاحة له، وتقدر تضيف معاد جديد.
class DoctorAvailabilityScreen extends StatelessWidget {
  const DoctorAvailabilityScreen({super.key, required this.doctor});

  final DoctorModel doctor;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DoctorAvailabilityCubit(DoctorsRepository())..loadAvailability(doctor.id),
      child: _DoctorAvailabilityView(doctor: doctor),
    );
  }
}

class _DoctorAvailabilityView extends StatelessWidget {
  const _DoctorAvailabilityView({required this.doctor});

  final DoctorModel doctor;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('مواعيد د. ${doctor.name}')),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => _showAddSheet(context),
        child: const Icon(Icons.add),
      ),
      body: BlocConsumer<DoctorAvailabilityCubit, DoctorAvailabilityState>(
        listener: (context, state) {
          if (state.errorMessage != null && !state.isSubmitting) {
            AppDialogs.showError(context, state.errorMessage!);
          }
        },
        builder: (context, state) {
          if (state.status == DoctorAvailabilityStatus.loading ||
              state.status == DoctorAvailabilityStatus.initial) {
            return const LoadingView();
          }
          if (state.status == DoctorAvailabilityStatus.error) {
            return ErrorView(
              message: state.errorMessage ?? 'حصل خطأ',
              onRetry: () => context.read<DoctorAvailabilityCubit>().loadAvailability(doctor.id),
            );
          }
          if (state.availability.isEmpty) {
            return const EmptyView(message: 'مفيش مواعيد عمل مضافة لسه', icon: Icons.schedule_rounded);
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 90),
            itemCount: state.availability.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final item = state.availability[index];
              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.bgLayer1,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.schedule_rounded, color: AppColors.teal),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.dayName, style: const TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(
                            '${item.startTime} - ${item.endTime} • سعة ${item.slotCapacity}',
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showAddSheet(BuildContext context) {
    final cubit = context.read<DoctorAvailabilityCubit>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.bgLayer1,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => BlocProvider.value(value: cubit, child: const _AddAvailabilitySheet()),
    );
  }
}

class _AddAvailabilitySheet extends StatefulWidget {
  const _AddAvailabilitySheet();

  @override
  State<_AddAvailabilitySheet> createState() => _AddAvailabilitySheetState();
}

class _AddAvailabilitySheetState extends State<_AddAvailabilitySheet> {
  int _dayOfWeek = 0;
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 17, minute: 0);
  final _capacityController = TextEditingController(text: '1');

  @override
  void dispose() {
    _capacityController.dispose();
    super.dispose();
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: MediaQuery.of(context).viewInsets.bottom + 16),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('إضافة معاد عمل', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              initialValue: _dayOfWeek,
              decoration: const InputDecoration(labelText: 'اليوم'),
              items: List.generate(
                7,
                (i) => DropdownMenuItem(value: i, child: Text(DoctorAvailabilityModel.dayNames[i])),
              ),
              onChanged: (value) => setState(() => _dayOfWeek = value!),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final picked = await showTimePicker(context: context, initialTime: _startTime);
                      if (picked != null) setState(() => _startTime = picked);
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(labelText: 'من الساعة'),
                      child: Text(_startTime.format(context)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final picked = await showTimePicker(context: context, initialTime: _endTime);
                      if (picked != null) setState(() => _endTime = picked);
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(labelText: 'إلى الساعة'),
                      child: Text(_endTime.format(context)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _capacityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'سعة كل موعد (عدد المرضى)'),
            ),
            const SizedBox(height: 20),
            BlocBuilder<DoctorAvailabilityCubit, DoctorAvailabilityState>(
              builder: (context, state) {
                return ElevatedButton(
                  onPressed: state.isSubmitting
                      ? null
                      : () async {
                          final success = await context.read<DoctorAvailabilityCubit>().addAvailability(
                                dayOfWeek: _dayOfWeek,
                                startTime: _formatTime(_startTime),
                                endTime: _formatTime(_endTime),
                                slotCapacity: int.tryParse(_capacityController.text) ?? 1,
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
