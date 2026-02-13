import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:legal_case_manager/features/auth/screens/lawyer_login_screen.dart';
import 'package:legal_case_manager/services/auth_service.dart';

class LawyerSignupScreen extends StatefulWidget {
  const LawyerSignupScreen({super.key});

  @override
  State<LawyerSignupScreen> createState() => _LawyerSignupScreenState();
}

class _LawyerSignupScreenState extends State<LawyerSignupScreen> {
  // ✅ Added Form Key for global validation
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _barIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  String? _selectedSpecialization;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _barIdController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // ================= SIGNUP LOGIC =================
  Future<void> _handleSignup() async {
    // ✅ Trigger professional validation check
    if (!_formKey.currentState!.validate()) {
      return; // Stop execution if form is invalid
    }

    try {
      await AuthService().signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        role: 'lawyer',
        name: _nameController.text.trim(),
        barCouncilId: _barIdController.text.trim(),
        specialization: _selectedSpecialization,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lawyer signup successful')),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LawyerLoginScreen()),
      );
    } on FirebaseAuthException catch (e) {
      _showError(e.message ?? 'Signup failed');
    }
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F6FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form( // ✅ Wrap inputs in a Form widget
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: Image.asset(
                    'assets/images/client_signup.png',
                    height: 160,
                  ),
                ),
                const SizedBox(height: 24),
                const Center(
                  child: Text(
                    'Lawyer Sign Up',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 32),

                // Name Field with Length Constraint
                _inputField(
                  hint: 'Full Name',
                  controller: _nameController,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return 'Full name is required';
                    if (value.trim().length < 3) return 'Name must be at least 3 characters';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Email Field with Regex Validation
                _inputField(
                  hint: 'Email',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Email is required';
                    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                    if (!emailRegex.hasMatch(value)) return 'Enter a valid email address';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Bar ID Field
                _inputField(
                  hint: 'Bar Council ID',
                  controller: _barIdController,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return 'Bar Council ID is required';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Specialization with Null Check
                DropdownButtonFormField<String>(
                  value: _selectedSpecialization,
                  items: const [
                    DropdownMenuItem(value: 'criminal', child: Text('Criminal Lawyer')),
                    DropdownMenuItem(value: 'civil', child: Text('Civil Lawyer')),
                    DropdownMenuItem(value: 'corporate', child: Text('Corporate Lawyer')),
                    DropdownMenuItem(value: 'Public', child: Text('Public Lawyer')),
                    DropdownMenuItem(value: 'Immigration', child: Text('Immigration Lawyer')),
                    DropdownMenuItem(value: 'Property', child: Text('Property Lawyer')),
                  ],
                  onChanged: (v) => setState(() => _selectedSpecialization = v),
                  validator: (value) => value == null ? 'Please select a specialization' : null,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    labelText: 'Specialization',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  ),
                ),
                const SizedBox(height: 16),

                // Password with Complexity Constraint
                _inputField(
                  hint: 'Password',
                  controller: _passwordController,
                  isPassword: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Password is required';
                    if (value.length < 6) return 'Password must be at least 6 characters';
                    return null;
                  },
                  toggle: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
                const SizedBox(height: 16),

                // Confirm Password Check
                _inputField(
                  hint: 'Confirm Password',
                  controller: _confirmPasswordController,
                  isPassword: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Please confirm your password';
                    if (value != _passwordController.text) return 'Passwords do not match';
                    return null;
                  },
                  toggle: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0B2B45),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
                    ),
                    onPressed: _handleSignup,
                    child: const Text(
                      'Sign Up',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ================= UPDATED INPUT FIELD =================
  Widget _inputField({
    required String hint,
    required TextEditingController controller,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator, // ✅ Added Validator parameter
    VoidCallback? toggle,
  }) {
    return TextFormField( // ✅ Transitioned to TextFormField
      controller: controller,
      obscureText: isPassword ? _obscurePassword : false,
      keyboardType: keyboardType,
      validator: validator, // ✅ Attached professional validation logic
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        suffixIcon: toggle != null
            ? IconButton(
          icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
          onPressed: toggle,
        )
            : null,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        // Error styling for professional appearance
        errorStyle: const TextStyle(color: Colors.red, fontSize: 12),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
      ),
    );
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Signup Error'),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
        ],
      ),
    );
  }
}