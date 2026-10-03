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
import '../../cubits/sessions_cubit.dart';
import '../../repositories/sessions_repository.dart';
import '../../routes/app_routes.dart';

class SessionsListScreen extends StatelessWidget {
  const SessionsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SessionsCubit(SessionsRepository())..loadSessions(),
      child: const _SessionsListView(),
    );
  }
}

class _SessionsListView extends StatelessWidget {
  const _SessionsListView();

  static const _statusFilters = [
    (null, 'الكل'),
    ('SCHEDULED', 'محجوزة'),
    ('ATTENDED', 'حضر'),
    ('MISSED', 'غاب'),
    ('CANCELED', 'ملغية'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الجلسات')),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () async {
          final cubit = context.read<SessionsCubit>();
          await Navigator.pushNamed(context, AppRoutes.sessionForm);
          cubit.refresh();
        },
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 46,
            child: BlocBuilder<SessionsCubit, SessionsState>(
              builder: (context, state) {
                return ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  children: _statusFilters.map((filter) {
                    final selected = state.statusFilter == filter.$1;
                    return Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: ChoiceChip(
                        label: Text(filter.$2),
                        selected: selected,
                        onSelected: (_) => context.read<SessionsCubit>().loadSessions(status: filter.$1),
                        selectedColor: AppColors.primary,
                        labelStyle: TextStyle(color: selected ? Colors.white : AppColors.textPrimary),
                        backgroundColor: AppColors.bgLayer1,
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
          Expanded(
            child: BlocConsumer<SessionsCubit, SessionsState>(
              listener: (context, state) {
                if (state.errorMessage != null && !state.isSubmitting) {
                  AppDialogs.showError(context, state.errorMessage!);
                }
              },
              builder: (context, state) {
                if (state.status == SessionsStatus.loading || state.status == SessionsStatus.initial) {
                  return const LoadingView();
                }
                if (state.status == SessionsStatus.error) {
                  return ErrorView(
                    message: state.errorMessage ?? 'حصل خطأ',
                    onRetry: () => context.read<SessionsCubit>().refresh(),
                  );
                }
                if (state.sessions.isEmpty) {
                  return const EmptyView(message: 'مفيش جلسات', icon: Icons.event_busy_rounded);
                }
                return RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () => context.read<SessionsCubit>().refresh(),
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 90),
                    itemCount: state.sessions.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final session = state.sessions[index];
                      return InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () => _showStatusSheet(context, session.id, session.status),
                        child: Container(
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
                                  Text(
                                    session.patientName ?? 'مريض',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${DateHelper.formatDateTime(session.sessionDate)} • ${EnumLabels.label(EnumLabels.sessionType, session.sessionType)}',
                                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                                  ),
                                  if (session.doctorName != null)
                                    Text('د. ${session.doctorName}',
                                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                                ],
                              ),
                            ),
                            StatusBadge(
                              label: EnumLabels.label(EnumLabels.sessionStatus, session.status),
                              color: EnumLabels.statusColor(session.status),
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
        ],
      ),
    );
  }

  void _showStatusSheet(BuildContext context, String sessionId, String currentStatus) {
    final cubit = context.read<SessionsCubit>();
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgLayer1,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('تحديث حالة الجلسة', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              ListTile(
                leading: const Icon(Icons.check_circle_rounded, color: AppColors.success),
                title: const Text('حضر'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  cubit.updateSessionStatus(id: sessionId, status: 'ATTENDED');
                },
              ),
              ListTile(
                leading: const Icon(Icons.cancel_rounded, color: AppColors.danger),
                title: const Text('غاب'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  cubit.updateSessionStatus(id: sessionId, status: 'MISSED');
                },
              ),
              ListTile(
                leading: const Icon(Icons.block_rounded, color: AppColors.textSecondary),
                title: const Text('إلغاء الجلسة'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  cubit.updateSessionStatus(id: sessionId, status: 'CANCELED');
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}
