import 'package:partner_app/core/constants/api_constants.dart';
import 'package:partner_app/core/config/amplify_config_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:provider/provider.dart';
import 'package:audio_session/audio_session.dart';
import 'dart:io';

import 'app.dart';
import 'providers/auth_provider.dart';
import 'providers/navigation_provider.dart';
import 'providers/welcome_provider.dart';

// Global navigator key
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configure audio session for iOS
  if (Platform.isIOS) {
    try {
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration(
        avAudioSessionCategory: AVAudioSessionCategory.playback,
        avAudioSessionCategoryOptions: AVAudioSessionCategoryOptions.defaultToSpeaker,
        avAudioSessionMode: AVAudioSessionMode.defaultMode,
        avAudioSessionRouteSharingPolicy: AVAudioSessionRouteSharingPolicy.defaultPolicy,
        avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.none,
        androidAudioAttributes: AndroidAudioAttributes(
          contentType: AndroidAudioContentType.music,
          flags: AndroidAudioFlags.none,
          usage: AndroidAudioUsage.media,
        ),
        androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
        androidWillPauseWhenDucked: true,
      ));
      debugPrint('iOS Audio session configured successfully');
    } catch (e) {
      debugPrint('Error configuring iOS audio session: $e');
    }
  }

  // Initialize Amplify first
  try {
    await AmplifyConfigHelper.configureAmplify();
  } catch (e) {
    debugPrint('Error initializing Amplify in main(): $e');
  }

  // Initialize Stripe
  Stripe.publishableKey = ApiConstants.stripePublishableKey;
  await Stripe.instance.applySettings();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => WelcomeProvider()),
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
      ],
      child: const MyApp(),
    ),
  );
}
