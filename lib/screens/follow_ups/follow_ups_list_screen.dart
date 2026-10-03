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
import '../../cubits/follow_ups_cubit.dart';
import '../../repositories/follow_ups_repository.dart';

class FollowUpsListScreen extends StatelessWidget {
  const FollowUpsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => FollowUpsCubit(FollowUpsRepository())..loadFollowUps(),
      child: const _FollowUpsView(),
    );
  }
}

class _FollowUpsView extends StatelessWidget {
  const _FollowUpsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('المتابعات')),
      body: BlocConsumer<FollowUpsCubit, FollowUpsState>(
        listener: (context, state) {
          if (state.errorMessage != null && !state.isSubmitting) {
            AppDialogs.showError(context, state.errorMessage!);
          }
        },
        builder: (context, state) {
          if (state.status == FollowUpsStatus.loading || state.status == FollowUpsStatus.initial) {
            return const LoadingView();
          }
          if (state.status == FollowUpsStatus.error) {
            return ErrorView(
              message: state.errorMessage ?? 'حصل خطأ',
              onRetry: () => context.read<FollowUpsCubit>().loadFollowUps(),
            );
          }
          if (state.followUps.isEmpty) {
            return const EmptyView(message: 'مفيش متابعات معلّقة', icon: Icons.notifications_none_rounded);
          }
          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () => context.read<FollowUpsCubit>().loadFollowUps(),
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 90),
              itemCount: state.followUps.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final item = state.followUps[index];
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
                            child: Text(
                              EnumLabels.label(EnumLabels.followUpType, item.type),
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          StatusBadge(
                            label: EnumLabels.label(EnumLabels.followUpStatus, item.status),
                            color: EnumLabels.statusColor(item.status),
                          ),
                        ],
                      ),
                      if (item.message != null && item.message!.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(item.message!, style: const TextStyle(color: AppColors.textSecondary)),
                      ],
                      const SizedBox(height: 6),
                      Text(DateHelper.formatDateTime(item.createdAt),
                          style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                      if (item.status == 'PENDING') ...[
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () =>
                                    context.read<FollowUpsCubit>().updateStatus(id: item.id, status: 'RESOLVED'),
                                child: const Text('تم الحل'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(foregroundColor: AppColors.danger),
                                onPressed: () =>
                                    context.read<FollowUpsCubit>().updateStatus(id: item.id, status: 'CANCELLED'),
                                child: const Text('إلغاء'),
                              ),
                            ),
                          ],
                        ),
                      ],
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
}
