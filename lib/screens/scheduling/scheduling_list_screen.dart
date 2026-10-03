import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/app_dialogs.dart';
import '../../core/utils/date_helper.dart';
import '../../core/widgets/empty_view.dart';
import '../../core/widgets/error_view.dart';
import '../../core/widgets/loading_view.dart';
import '../../cubits/scheduling_cubit.dart';
import '../../repositories/scheduling_repository.dart';
import '../../routes/app_routes.dart';

class SchedulingListScreen extends StatelessWidget {
  const SchedulingListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SchedulingCubit(SchedulingRepository())..loadSlots(),
      child: Scaffold(
        appBar: AppBar(title: const Text('الجدولة')),
        floatingActionButton: FloatingActionButton(
          backgroundColor: AppColors.primary,
          onPressed: () async {
            final cubit = context.read<SchedulingCubit>();
            await Navigator.pushNamed(context, AppRoutes.slotForm);
            cubit.refresh();
          },
          child: const Icon(Icons.add),
        ),
        body: BlocConsumer<SchedulingCubit, SchedulingState>(
          listener: (context, state) {
            if (state.errorMessage != null && !state.isSubmitting) {
              AppDialogs.showError(context, state.errorMessage!);
            }
          },
          builder: (context, state) {
            if (state.status == SchedulingStatus.loading || state.status == SchedulingStatus.initial) {
              return const LoadingView();
            }
            if (state.status == SchedulingStatus.error) {
              return ErrorView(
                message: state.errorMessage ?? 'حصل خطأ',
                onRetry: () => context.read<SchedulingCubit>().refresh(),
              );
            }
            if (state.slots.isEmpty) {
              return const EmptyView(message: 'مفيش مواعيد متاحة', icon: Icons.event_busy_rounded);
            }
            return RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () => context.read<SchedulingCubit>().refresh(),
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 90),
                itemCount: state.slots.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final slot = state.slots[index];
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
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${DateHelper.formatTime(slot.startTime)} - ${DateHelper.formatTime(slot.endTime)}',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    DateHelper.formatDate(slot.startTime),
                                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'الحجوزات: ${slot.bookedCount} / ${slot.capacity}',
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
                                  context.read<SchedulingCubit>().deleteSlot(slot.id);
                                }
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            if (slot.remainingCapacity > 0)
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => context.read<SchedulingCubit>().bookSlot(slot.id),
                                  child: const Text('احجز مكان'),
                                ),
                              ),
                            if (slot.bookedCount > 0) ...[
                              if (slot.remainingCapacity > 0) const SizedBox(width: 8),
                              Expanded(
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(foregroundColor: AppColors.danger),
                                  onPressed: () => context.read<SchedulingCubit>().cancelBooking(slot.id),
                                  child: const Text('إلغاء حجز'),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
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
