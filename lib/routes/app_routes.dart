import 'package:flutter/material.dart';
import 'package:partner_app/screens/welcome/welcome_screen.dart';
import 'package:partner_app/screens/auth/login_screen.dart';
import 'package:partner_app/screens/auth/register_screen.dart';
import 'package:partner_app/screens/auth/forgot_password.dart';
import 'package:partner_app/screens/auth/otp_verification.dart';
import 'package:partner_app/screens/auth/change_password_screen.dart';
import 'package:partner_app/screens/dashboard/dashboard_screen.dart';
import 'package:partner_app/screens/settings/settings_screen.dart';
import 'package:partner_app/screens/welcome/welcome_success_screen.dart';
import 'package:partner_app/screens/splash/splash_screen.dart';
import 'package:partner_app/screens/profile_setup/profile_setup_step1.dart';
import 'package:partner_app/screens/profile_setup/profile_setup_step2.dart';
import 'package:partner_app/screens/profile_setup/profile_setup_step3.dart';

class AppRoutes {
  // Route names
  static const String splash = '/';
  static const String welcome = '/welcome';
  static const String welcomeSuccess = '/welcome-success';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String otpVerification = '/otp-verification';
  static const String home = '/home';
  static const String dashboard = '/dashboard';
  static const String booking = '/booking';
  static const String earning = '/earning';
  static const String add = '/add';
  static const String bookings = '/bookings';
  static const String addBooking = '/add-booking';
  static const String manageServices = '/manage-services';
  static const String payouts = '/payouts';
  static const String reviews = '/reviews';
  static const String patientList = '/patients';
  static const String addPatient = '/add-patient';
  static const String editPatient = '/edit-patient';
  static const String patientDetail = '/patient-detail';
  static const String templates = '/templates';
  static const String addTemplate = '/add-template';
  static const String editTemplate = '/edit-template';
  static const String transcription = '/transcription';
  static const String visitSummary = '/visit-summary';
  static const String settings = '/settings';
  static const String profile = '/profile';
  static const String changePassword = '/change-password';
  static const String profileStep1 = '/profile-setup-step1';
  static const String profileStep2 = '/profile-setup-step2';
  static const String profileStep3 = '/profile-setup-step3';

  // Route generator
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return MaterialPageRoute(
          builder: (_) => const SplashScreen(),
          settings: settings,
        );

      case AppRoutes.welcome:
        return MaterialPageRoute(
          builder: (_) => WelcomeScreen(),
          settings: settings,
        );

      case AppRoutes.welcomeSuccess:
        return MaterialPageRoute(
          builder: (_) => const WelcomeSuccessScreen(),
          settings: settings,
        );

      case AppRoutes.login:
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
          settings: settings,
        );

      case AppRoutes.register:
        return MaterialPageRoute(
          builder: (_) => const RegisterScreen(),
          settings: settings,
        );

      case AppRoutes.forgotPassword:
        return MaterialPageRoute(
          builder: (_) => const ForgotPasswordScreen(),
          settings: settings,
        );

      case AppRoutes.otpVerification:
        return MaterialPageRoute(
          builder: (_) => const OtpVerificationScreen(),
          settings: settings,
        );

      case AppRoutes.changePassword:
        return MaterialPageRoute(
          builder: (_) => const ChangePasswordScreen(),
          settings: settings,
        );

      case AppRoutes.profileStep1:
        return MaterialPageRoute(
          builder: (_) => const ProfileSetupStep1Screen(),
          settings: settings,
        );

      case AppRoutes.profileStep2:
        return MaterialPageRoute(
          builder: (_) => const ProfileSetupStep2Screen(),
          settings: settings,
        );

      case AppRoutes.profileStep3:
        return MaterialPageRoute(
          builder: (_) => const ProfileSetupStep3Screen(),
          settings: settings,
        );

      case AppRoutes.dashboard:
      case AppRoutes.home:
        return MaterialPageRoute(
          builder: (_) => const DashboardScreen(),
          settings: settings,
        );

      case AppRoutes.bookings:
      case AppRoutes.booking:
        return MaterialPageRoute(
          builder: (_) => const _PlaceholderScreen(title: 'Bookings'),
          settings: settings,
        );

      case AppRoutes.addBooking:
        return MaterialPageRoute(
          builder: (_) => const _PlaceholderScreen(title: 'Add Booking'),
          settings: settings,
        );

      case AppRoutes.manageServices:
        return MaterialPageRoute(
          builder: (_) => const _PlaceholderScreen(title: 'Manage Services'),
          settings: settings,
        );

      case AppRoutes.payouts:
      case AppRoutes.earning:
        return MaterialPageRoute(
          builder: (_) => const _PlaceholderScreen(title: 'Payouts'),
          settings: settings,
        );

      case AppRoutes.reviews:
        return MaterialPageRoute(
          builder: (_) => const _PlaceholderScreen(title: 'Reviews'),
          settings: settings,
        );

      case AppRoutes.add:
        return MaterialPageRoute(
          builder: (_) => const _PlaceholderScreen(title: 'Add Services'),
          settings: settings,
        );

      case AppRoutes.settings:
        return MaterialPageRoute(
          builder: (_) => const SettingsScreen(),
          settings: settings,
        );

      default:
        return MaterialPageRoute(
          builder: (_) =>
              const Scaffold(body: Center(child: Text('Route not found'))),
          settings: settings,
        );
    }
  }

  // Navigation helpers
  static void navigateToLogin(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(context, login, (route) => false);
  }

  static void navigateToDashboard(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(context, dashboard, (route) => false);
  }

  static void navigateToWelcome(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(context, welcome, (route) => false);
  }

  static Future<T?> navigateTo<T extends Object?>(
      BuildContext context, String routeName,
      {Object? arguments}) {
    return Navigator.pushNamed<T>(
      context,
      routeName,
      arguments: arguments,
    );
  }
}

class _PlaceholderScreen extends StatelessWidget {
  final String title;

  const _PlaceholderScreen({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Text(title),
      ),
    );
  }
}
