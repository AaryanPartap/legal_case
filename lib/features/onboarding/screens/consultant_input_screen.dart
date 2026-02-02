import 'package:flutter/material.dart';
//import '../../auth/screens/login_screen.dart';
import 'lawyer_selection_screen.dart';

class ConsultantInputScreen extends StatelessWidget {
  const ConsultantInputScreen({super.key});

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

              // 🔥 Illustration Area (COMPOSED FROM TWO IMAGES)
              Expanded(
                flex: 5,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Top-right image (human + documents)
                    Positioned(
                      top: 120,
                      right: 30,
                      child: Image.asset(
                        'assets/images/Frame (1).png',
                        width: 220,
                        fit: BoxFit.contain,
                      ),
                    ),

                    // Bottom-left image (robot)
                    Positioned(
                      top: 220,
                      left: 30,

                      child: Image.asset(
                        'assets/images/Frame.png',
                        width: 160,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Description Text
              const Text(
                'Enter the name of your city and the type of consultant you’re looking for, and our AI bot will select the best candidate for your task.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,

                  letterSpacing: 0,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 24),

              // Page Indicators (Step 2 active)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _indicator(isActive: false),
                  _indicator(isActive: true),
                  _indicator(isActive: false),
                ],
              ),

              const Spacer(),

              // Next Button
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
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const LawyerSelectionScreen(),

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
