import 'package:flutter/material.dart';
import 'package:partner_app/screens/welcome/welcome_screen.dart';
import 'package:partner_app/screens/auth/login_screen.dart';
import 'package:partner_app/screens/auth/register_screen.dart';
import 'package:partner_app/screens/dashboard/dashboard_screen.dart';
import 'package:partner_app/screens/settings/settings_screen.dart';
import 'package:partner_app/screens/welcome/welcome_success_screen.dart';
import 'package:partner_app/screens/splash/splash_screen.dart';

class AppRoutes {
  // Route names
  static const String splash = '/';
  static const String welcome = '/welcome';
  static const String welcomeSuccess = '/welcome-success';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String dashboard = '/dashboard';
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
      
      case AppRoutes.dashboard:
        return MaterialPageRoute(
          builder: (_) => const DashboardScreen(),
          settings: settings,
        );
      
      case AppRoutes.settings:
        return MaterialPageRoute(
          builder: (_) => const SettingsScreen(),
          settings: settings,
        );
      
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(
              child: Text('Route not found'),
            ),
          ),
          settings: settings,
        );
    }
  }

  // Navigation helpers
  static void navigateToLogin(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      login,
      (route) => false,
    );
  }

  static void navigateToDashboard(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      dashboard,
      (route) => false,
    );
  }

  static void navigateToWelcome(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      welcome,
      (route) => false,
    );
  }
}
