import 'package:partner_app/routes/app_routes.dart';
import 'package:partner_app/core/constants/app_strings.dart';
import 'package:partner_app/widgets/connectivity_banner.dart';
import 'package:flutter/material.dart';
import 'package:partner_app/core/services/route_observer_service.dart';
import 'dart:async';
import 'package:app_links/app_links.dart';
import 'main.dart'; // Import to access navigatorKey
import 'package:partner_app/core/services/idle_timeout_service.dart';
import 'package:partner_app/core/services/session_expiry_service.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  StreamSubscription? _linkSubscription;
  late AppLinks _appLinks;

  @override
  void initState() {
    super.initState();
    _appLinks = AppLinks();
    _initDeepLinks();

    // Initialize idle timeout after first frame to ensure context is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        IdleTimeoutService.instance.initialize(
          context,
          RouteObserverService().routeObserver,
        );
      } catch (e) {
        debugPrint('IdleTimeout init error: $e');
      }

      // Initialize SessionExpiryService with a Navigator context for navigation
      Future<void>.delayed(const Duration(milliseconds: 100), () {
        try {
          final ctx = navigatorKey.currentContext;
          if (ctx != null) {
            SessionExpiryService.instance.initialize(ctx);
          }
        } catch (e) {
          debugPrint('SessionExpiry init error: $e');
        }
      });
    });
  }

  void _initDeepLinks() {
    // TODO: Implement deep link handling
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      navigatorKey: navigatorKey,
      navigatorObservers: [RouteObserverService().routeObserver],
      onGenerateRoute: AppRoutes.generateRoute,
      initialRoute: AppRoutes.splash,
      builder: (context, child) {
        return Stack(
          children: [
            child!,
            const ConnectivityBanner(),
          ],
        );
      },
    );
  }
}
