import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:legal_case_manager/app.dart';
import 'package:legal_case_manager/features/onboarding/screens/onboarding_screen.dart';
import 'firebase_options.dart';
import 'features/auth/screens/client_login_screen.dart';
import 'features/onboarding/screens/onboarding_screen.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await NotificationService.init();
  runApp(const LegalCaseApp());
}

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return const MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: OnboardingScreen(),
//     );
//   }
// }
