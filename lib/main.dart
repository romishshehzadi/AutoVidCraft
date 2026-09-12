import 'package:flutter/material.dart';
import 'Screens/AuthScreen.dart';
import 'Screens/overviewScreen.dart';
import 'Screens/Splash.dart';
import 'Screens/Dashboard.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';

void main()async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp( MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(
        onComplete: () {
          // Navigate to onboarding after splash
          Navigator.of(navigatorKey.currentContext!).pushReplacement(
            MaterialPageRoute(
              builder: (_) =>  OnboardingWrapper(),
            ),
          );
        },
      ),
      navigatorKey: navigatorKey,
    );
  }
}

// Global navigator key
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// Wrapper for OnboardingScreen to handle onComplete
class OnboardingWrapper extends StatelessWidget {
  OnboardingWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return OnboardingScreens(

    );
  }
}


