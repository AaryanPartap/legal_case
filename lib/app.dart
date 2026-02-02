import 'package:flutter/material.dart';
import 'package:legal_case_manager/features/onboarding/screens/onboarding_flow_screen.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/onboarding/screens/onboarding_screen.dart';


class LegalCaseApp extends StatelessWidget {
  const LegalCaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Legal Case Manager',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
      ),
      home: const OnboardingFlowScreen(),

    );
  }
}
