import 'package:flutter/material.dart';
//import '../../auth/screens/login_screen.dart';
import '../../auth/screens/entry_choice_screen.dart';


class LawyerSelectionScreen extends StatelessWidget {
  const LawyerSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F6FA),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 30),

              // Illustration
              // Expanded(
              //   flex: 5,
              //   child: Image.asset(
              //     'assets/images/image 1.png',
              //     fit: BoxFit.contain,
              //   ),
              // ),

              Expanded(
                flex: 5,
                child: Center(
                  child: SizedBox(
                    width: 280, // 👈 reduce width
                    child: Image.asset(
                      'assets/images/image 1.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Text
              const Text(
                'Choose the best verified lawyer profiles in your area based on qualifications, experience, and reviews.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 24),

              // Page indicators (Step 3 active)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _indicator(isActive: false),
                  _indicator(isActive: false),
                  _indicator(isActive: true),
                ],
              ),

              const Spacer(),

              // Next Button (final onboarding step)
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0B2B45),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const EntryChoiceScreen(),

                      ),
                    );
                  },
                  child: const Text(
                    'Next',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _indicator({required bool isActive}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 24 : 10,
      height: 4,
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF0B2B45) : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
