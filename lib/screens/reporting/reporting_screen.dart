import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/error_view.dart';
import '../../core/widgets/loading_view.dart';
import '../../core/widgets/section_card.dart';
import '../../cubits/reporting_cubit.dart';
import '../../repositories/reporting_repository.dart';

class ReportingScreen extends StatelessWidget {
  const ReportingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ReportingCubit(ReportingRepository())..loadDailyReport(),
      child: Scaffold(
        appBar: AppBar(title: const Text('التقارير')),
        body: BlocBuilder<ReportingCubit, ReportingState>(
          builder: (context, state) {
            if (state.status == ReportingStatus.loading || state.status == ReportingStatus.initial) {
              return const LoadingView();
            }
            if (state.status == ReportingStatus.error) {
              return ErrorView(
                message: state.errorMessage ?? 'حصل خطأ في تحميل التقرير',
                onRetry: () => context.read<ReportingCubit>().loadDailyReport(),
              );
            }
            final report = state.dailyReport ?? {};
            return RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () => context.read<ReportingCubit>().loadDailyReport(),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  SectionCard(
                    title: 'تقرير اليوم',
                    child: Column(
                      children: report.entries.map((entry) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(entry.key, style: const TextStyle(color: AppColors.textSecondary)),
                              Text('${entry.value}', style: const TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  if (report.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 40),
                      child: Center(
                        child: Text('مفيش بيانات تقرير النهاردة', style: TextStyle(color: AppColors.textSecondary)),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
