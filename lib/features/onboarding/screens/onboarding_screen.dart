import 'package:flutter/material.dart' show BorderRadius, BoxDecoration, BoxFit, BuildContext, Center, Color, Colors, Column, Container, EdgeInsets, ElevatedButton, Expanded, FontWeight, Image, MainAxisAlignment, MaterialPageRoute, Navigator, Padding, RoundedRectangleBorder, Row, SafeArea, Scaffold, SizedBox, Spacer, StatelessWidget, Text, TextAlign, TextStyle, Widget;
import 'consultant_input_screen.dart';


class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

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

              // Illustration (NOT full screen)
              Expanded(
                flex: 5,
                child: Center(
                  child: SizedBox(
                    width: 280, // 👈 reduce width
                    child: Image.asset(
                      'assets/images/Character.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),


              const SizedBox(height: 20),

              // Text
              const Text(
                'Find all types of legal services in one app, with an easy process and multiple benefits.',
                textAlign: TextAlign.center,

                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 24),

              // Page indicators
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _indicator(isActive: true),
                  _indicator(isActive: false),
                  _indicator(isActive: false),
                ],
              ),

              const Spacer(),

              // Get Started Button
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
                          builder: (_) => const ConsultantInputScreen(),

                      ),
                    );
                  },
                  child: const Text(
                    'Get Started',
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
