import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../../cubits/auth_cubit.dart';
import '../../routes/app_routes.dart';

/// شاشة بسيطة بتتعرض ثانية أو اتنين وهي بتتأكد لو فيه يوزر مسجل دخول قبل كده،
/// وبعدين توديه على الداشبورد أو شاشة تسجيل الدخول.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.authenticated) {
          Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.dashboard, (r) => false);
        } else if (state.status == AuthStatus.unauthenticated) {
          Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.login, (r) => false);
        }
      },
      child: const Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.local_hospital_rounded, color: AppColors.primary, size: 64),
              SizedBox(height: 16),
              Text('MCSOS', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              SizedBox(height: 24),
              CircularProgressIndicator(color: AppColors.primary),
            ],
          ),
        ),
      ),
    );
  }
}
