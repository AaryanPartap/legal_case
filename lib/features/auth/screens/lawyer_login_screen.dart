import 'package:flutter/material.dart';
import 'package:legal_case_manager/features/auth/screens/client_auth_choice_screen.dart';
import 'package:legal_case_manager/features/auth/screens/entry_choice_screen.dart';
import 'package:legal_case_manager/features/lawyer/screens/lawyer_dashboard.dart';
import 'package:legal_case_manager/services/google_auth_service.dart';


class LawyerLoginScreen extends StatefulWidget {
  const LawyerLoginScreen({super.key});

  @override
  State<LawyerLoginScreen> createState() => _LawyerLoginScreenState();
}

class _LawyerLoginScreenState extends State<LawyerLoginScreen> {
  bool _loading = false;

  Future<void> _handleGoogleLogin() async {
    setState(() => _loading = true);

    try {
      final user = await GoogleAuthService().signInWithGoogle();

      if (!mounted) return;

      if (user != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Welcome ${user.email}')),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const LawyerDashboardScreen(),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Google Sign-In failed')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F6FA),
      body: SafeArea(
        child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const EntryChoiceScreen(),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),

              Image.asset(
                'assets/images/client_login.png',
                height: 160,
              ),

              const SizedBox(height: 24),

              const Text(
                'Lawyer Login',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 32),

              _inputField('Email'),
              const SizedBox(height: 16),
              _inputField('Password', obscure: true),

              const SizedBox(height: 16),

              _primaryButton('Login', onTap: () {}),

              const SizedBox(height: 24),

              const Row(
                children: [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text('Or continue with'),
                  ),
                  Expanded(child: Divider()),
                ],
              ),

              const SizedBox(height: 16),

              _googleButton(),
            ],
          ),
        ),
      ),
      ),
    );
  }

  Widget _inputField(String hint, {bool obscure = false}) {
    return TextField(
      obscureText: obscure,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _primaryButton(String text, {required VoidCallback onTap}) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0B2B45),
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _googleButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton.icon(
        onPressed: _loading ? null : _handleGoogleLogin,
        icon: Image.asset('assets/images/google.png', height: 20),
        label: _loading
            ? const SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        )
            : const Text('Continue with Gmail'),
        style: OutlinedButton.styleFrom(
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
        ),
      ),
    );
  }
}
