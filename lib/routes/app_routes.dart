import 'package:flutter/material.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/patients/patients_list_screen.dart';
import '../screens/patients/patient_form_screen.dart';
import '../screens/patients/patient_detail_screen.dart';
import '../screens/doctors/doctors_list_screen.dart';
import '../screens/doctors/doctor_form_screen.dart';
import '../screens/sessions/sessions_list_screen.dart';
import '../screens/sessions/session_form_screen.dart';
import '../screens/scheduling/scheduling_list_screen.dart';
import '../screens/scheduling/slot_form_screen.dart';
import '../screens/treatment_plans/treatment_plans_list_screen.dart';
import '../screens/packages/packages_list_screen.dart';
import '../screens/finance/finance_screen.dart';
import '../screens/follow_ups/follow_ups_list_screen.dart';
import '../screens/waitlist/waitlist_list_screen.dart';
import '../screens/users/users_list_screen.dart';
import '../screens/reporting/reporting_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../models/patient_model.dart';
import '../models/doctor_model.dart';
import '../screens/doctors/doctor_availability_screen.dart';

/// كل أسماء الشاشات في مكان واحد عشان مانكتبش النصوص يدوي في كل مكان.
class AppRoutes {
  AppRoutes._();

  static const splash = '/';
  static const login = '/login';
  static const dashboard = '/dashboard';

  static const patients = '/patients';
  static const patientForm = '/patients/form';
  static const patientDetail = '/patients/detail';

  static const doctors = '/doctors';
  static const doctorForm = '/doctors/form';
  static const doctorAvailability = '/doctors/availability';

  static const sessions = '/sessions';
  static const sessionForm = '/sessions/form';

  static const scheduling = '/scheduling';
  static const slotForm = '/scheduling/form';

  static const treatmentPlans = '/treatment-plans';
  static const packages = '/packages';
  static const finance = '/finance';
  static const followUps = '/follow-ups';
  static const waitlist = '/waitlist';
  static const users = '/users';
  static const reporting = '/reporting';
  static const profile = '/profile';
}

/// هنا بنحدد أي widget يتفتح مع كل route، وبنمرر أي arguments لو محتاجينها.
Route<dynamic> onGenerateRoute(RouteSettings settings) {
  switch (settings.name) {
    case AppRoutes.splash:
      return MaterialPageRoute(builder: (_) => const SplashScreen());
    case AppRoutes.login:
      return MaterialPageRoute(builder: (_) => const LoginScreen());
    case AppRoutes.dashboard:
      return MaterialPageRoute(builder: (_) => const DashboardScreen());

    case AppRoutes.patients:
      return MaterialPageRoute(builder: (_) => const PatientsListScreen());
    case AppRoutes.patientForm:
      final patient = settings.arguments as PatientModel?;
      return MaterialPageRoute(builder: (_) => PatientFormScreen(existingPatient: patient));
    case AppRoutes.patientDetail:
      final patientId = settings.arguments as String;
      return MaterialPageRoute(builder: (_) => PatientDetailScreen(patientId: patientId));

    case AppRoutes.doctors:
      return MaterialPageRoute(builder: (_) => const DoctorsListScreen());
    case AppRoutes.doctorForm:
      final doctor = settings.arguments as DoctorModel?;
      return MaterialPageRoute(builder: (_) => DoctorFormScreen(existingDoctor: doctor));
    case AppRoutes.doctorAvailability:
      final args = settings.arguments as DoctorModel;
      return MaterialPageRoute(builder: (_) => DoctorAvailabilityScreen(doctor: args));

    case AppRoutes.sessions:
      return MaterialPageRoute(builder: (_) => const SessionsListScreen());
    case AppRoutes.sessionForm:
      return MaterialPageRoute(builder: (_) => const SessionFormScreen());

    case AppRoutes.scheduling:
      return MaterialPageRoute(builder: (_) => const SchedulingListScreen());
    case AppRoutes.slotForm:
      return MaterialPageRoute(builder: (_) => const SlotFormScreen());

    case AppRoutes.treatmentPlans:
      return MaterialPageRoute(builder: (_) => const TreatmentPlansListScreen());
    case AppRoutes.packages:
      return MaterialPageRoute(builder: (_) => const PackagesListScreen());
    case AppRoutes.finance:
      return MaterialPageRoute(builder: (_) => const FinanceScreen());
    case AppRoutes.followUps:
      return MaterialPageRoute(builder: (_) => const FollowUpsListScreen());
    case AppRoutes.waitlist:
      return MaterialPageRoute(builder: (_) => const WaitlistListScreen());
    case AppRoutes.users:
      return MaterialPageRoute(builder: (_) => const UsersListScreen());
    case AppRoutes.reporting:
      return MaterialPageRoute(builder: (_) => const ReportingScreen());
    case AppRoutes.profile:
      return MaterialPageRoute(builder: (_) => const ProfileScreen());

    default:
      return MaterialPageRoute(
        builder: (_) => const Scaffold(body: Center(child: Text('الصفحة غير موجودة'))),
      );
  }
}
