import 'package:flutter/material.dart';
import 'package:legal_case_manager/features/auth/screens/lawyer_login_screen.dart';
import 'package:legal_case_manager/features/lawyer/screens/lawyer_dashboard.dart';

class LawyerSignupScreen extends StatelessWidget {
  const LawyerSignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F6FA),
      body: SafeArea(
        child: SingleChildScrollView( // ✅ FIX
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// BACK BUTTON
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const LawyerLoginScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              /// ILLUSTRATION
              Center(
                child: Image.asset(
                  'assets/images/client_signup.png',
                  height: 160,
                ),
              ),

              const SizedBox(height: 24),

              /// TITLE
              const Center(
                child: Text(
                  'Lawyer Sign Up',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 32),

              _inputField(hint: 'Full Name'),
              const SizedBox(height: 16),

              _inputField(hint: 'Email'),
              const SizedBox(height: 16),

              _inputField(hint: 'Bar Council ID'),
              const SizedBox(height: 16),

              _inputField(hint: 'Password', isPassword: true),
              const SizedBox(height: 16),

              _inputField(hint: 'Confirm Password', isPassword: true),
              const SizedBox(height: 24),

              /// SIGN UP BUTTON
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
                        builder: (_) => const LawyerDashboardScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    'Sign Up',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24), // extra bottom spacing
            ],
          ),
        ),
      ),
    );
  }

  /// INPUT FIELD
  Widget _inputField({
    required String hint,
    bool isPassword = false,
  }) {
    return TextField(
      obscureText: isPassword,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        suffixIcon: isPassword ? const Icon(Icons.visibility_off) : null,
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
