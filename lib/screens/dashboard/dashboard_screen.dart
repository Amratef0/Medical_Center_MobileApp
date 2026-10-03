import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/main_drawer.dart';
import '../../cubits/auth_cubit.dart';
import '../../cubits/reporting_cubit.dart';
import '../../repositories/reporting_repository.dart';
import '../../routes/app_routes.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ReportingCubit(ReportingRepository())..loadDailyReport(),
      child: Scaffold(
        appBar: AppBar(title: const Text('لوحة التحكم')),
        drawer: const MainDrawer(),
        body: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () => context.read<ReportingCubit>().loadDailyReport(),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _WelcomeCard(),
              const SizedBox(height: 20),
              const Text('نظرة سريعة على اليوم',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 10),
              const _TodayStatsGrid(),
              const SizedBox(height: 24),
              const Text('الوصول السريع', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 10),
              const _QuickAccessGrid(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _WelcomeCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthCubit>().state.user;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryDark, AppColors.teal],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('أهلا بيك، ${user?.name ?? ''} 👋',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17)),
          const SizedBox(height: 4),
          const Text('يلا نشوف شغل النهاردة إيه', style: TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }
}

class _TodayStatsGrid extends StatelessWidget {
  const _TodayStatsGrid();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReportingCubit, ReportingState>(
      builder: (context, state) {
        if (state.status == ReportingStatus.loading) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 30),
            child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
          );
        }
        final report = state.dailyReport ?? {};
        // بنقرا القيم بحذر لأننا مش متأكدين 100% من شكل الـ response بالظبط،
        // فلو أي قيمة مش موجودة بنعرض صفر بدل ما نعمل كراش.
        final totalSessions = report['total_sessions'] ?? report['sessions_count'] ?? '-';
        final attended = report['attended'] ?? report['attended_count'] ?? '-';
        final missed = report['missed'] ?? report['missed_count'] ?? '-';
        final revenue = report['revenue'] ?? report['total_revenue'] ?? '-';

        return GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: [
            _StatCard(label: 'جلسات النهاردة', value: '$totalSessions', color: AppColors.primary, icon: Icons.event_note_rounded),
            _StatCard(label: 'حضروا', value: '$attended', color: AppColors.success, icon: Icons.check_circle_rounded),
            _StatCard(label: 'غابوا', value: '$missed', color: AppColors.danger, icon: Icons.cancel_rounded),
            _StatCard(label: 'الإيراد', value: '$revenue', color: AppColors.teal, icon: Icons.attach_money_rounded),
          ],
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value, required this.color, required this.icon});

  final String label;
  final String value;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgLayer1,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        ],
      ),
    );
  }
}

class _QuickAccessGrid extends StatelessWidget {
  const _QuickAccessGrid();

  @override
  Widget build(BuildContext context) {
    final items = [
      (Icons.people_alt_rounded, 'المرضى', AppRoutes.patients),
      (Icons.event_available_rounded, 'الجلسات', AppRoutes.sessions),
      (Icons.calendar_month_rounded, 'الجدولة', AppRoutes.scheduling),
      (Icons.medical_services_rounded, 'الأطباء', AppRoutes.doctors),
      (Icons.card_giftcard_rounded, 'الباقات', AppRoutes.packages),
      (Icons.attach_money_rounded, 'المالية', AppRoutes.finance),
    ];

    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 0.95,
      children: items.map((item) {
        return InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => Navigator.pushNamed(context, item.$3),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.bgLayer1,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(item.$1, color: AppColors.primary, size: 26),
                const SizedBox(height: 8),
                Text(item.$2, style: const TextStyle(fontSize: 12)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
