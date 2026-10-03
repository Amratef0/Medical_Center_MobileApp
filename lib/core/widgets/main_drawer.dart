import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cubits/auth_cubit.dart';
import '../../routes/app_routes.dart';
import '../theme/app_colors.dart';

/// نفس مجموعات القائمة الجانبية بتاعة الموقع (DashboardLayout.jsx) بالظبط.
class MainDrawer extends StatelessWidget {
  const MainDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthCubit>().state.user;

    return Drawer(
      backgroundColor: AppColors.bgLayer3,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 22,
                    backgroundColor: AppColors.primary,
                    child: Icon(Icons.local_hospital_rounded, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('MCSOS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text(
                          user?.name ?? '',
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _navTile(context, Icons.dashboard_rounded, 'لوحة التحكم', AppRoutes.dashboard),
                  _sectionLabel('المرضى'),
                  _navTile(context, Icons.people_alt_rounded, 'المرضى', AppRoutes.patients),
                  _navTile(context, Icons.list_alt_rounded, 'قائمة الانتظار', AppRoutes.waitlist),
                  _sectionLabel('الأطباء'),
                  _navTile(context, Icons.medical_services_rounded, 'الأطباء', AppRoutes.doctors),
                  _sectionLabel('الجدولة والعلاج'),
                  _navTile(context, Icons.calendar_month_rounded, 'الجدولة', AppRoutes.scheduling),
                  _navTile(context, Icons.event_available_rounded, 'الجلسات', AppRoutes.sessions),
                  _navTile(context, Icons.assignment_rounded, 'خطط العلاج', AppRoutes.treatmentPlans),
                  _sectionLabel('الباقات والمالية'),
                  _navTile(context, Icons.card_giftcard_rounded, 'الباقات', AppRoutes.packages),
                  _navTile(context, Icons.attach_money_rounded, 'المالية', AppRoutes.finance),
                  _sectionLabel('المتابعة'),
                  _navTile(context, Icons.message_rounded, 'المتابعات', AppRoutes.followUps),
                  _sectionLabel('عام'),
                  _navTile(context, Icons.bar_chart_rounded, 'التقارير', AppRoutes.reporting),
                  _navTile(context, Icons.admin_panel_settings_rounded, 'المستخدمون', AppRoutes.users),
                  _navTile(context, Icons.person_rounded, 'الملف الشخصي', AppRoutes.profile),
                ],
              ),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.logout_rounded, color: AppColors.danger),
              title: const Text('تسجيل الخروج', style: TextStyle(color: AppColors.danger)),
              onTap: () async {
                Navigator.pop(context);
                await context.read<AuthCubit>().logout();
                if (context.mounted) {
                  Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.login, (r) => false);
                }
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.textMuted,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _navTile(BuildContext context, IconData icon, String label, String route) {
    return ListTile(
      leading: Icon(icon, size: 22, color: AppColors.textSecondary),
      title: Text(label, style: const TextStyle(fontSize: 14)),
      onTap: () {
        Navigator.pop(context); // نقفل الـ drawer
        if (route == AppRoutes.dashboard) return;
        Navigator.pushNamed(context, route);
      },
    );
  }
}
