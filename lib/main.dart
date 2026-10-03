import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/network/api_client.dart';
import 'core/theme/app_theme.dart';
import 'cubits/auth_cubit.dart';
import 'repositories/auth_repository.dart';
import 'routes/app_routes.dart';

void main() {
  runApp(const McsosApp());
}

class McsosApp extends StatelessWidget {
  const McsosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      // الـ AuthCubit متاح لكل الابليكيشن عشان نعرف حالة تسجيل الدخول
      // في أي شاشة (زي الـ Drawer اللي بيعرض اسم اليوزر).
      create: (_) => AuthCubit(AuthRepository())..checkAuthStatus(),
      child: MaterialApp(
        title: 'MCSOS',
        debugShowCheckedModeBanner: false,
        navigatorKey: navigatorKey,
        theme: AppTheme.theme,
        locale: const Locale('ar'),
        supportedLocales: const [Locale('ar'), Locale('en')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        builder: (context, child) {
          // نجبر اتجاه النص يكون من اليمين لليسار في كل الابليكيشن.
          return Directionality(textDirection: TextDirection.rtl, child: child!);
        },
        initialRoute: AppRoutes.splash,
        onGenerateRoute: onGenerateRoute,
      ),
    );
  }
}
