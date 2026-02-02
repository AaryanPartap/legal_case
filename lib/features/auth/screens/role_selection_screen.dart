import 'package:flutter/material.dart';
import '../../../core/constants/user_role.dart';
import '../../client/screens/client_dashboard.dart';
import '../../lawyer/screens/lawyer_dashboard.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Role')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _roleButton(
              context,
              title: 'I am a Client',
              role: UserRole.client,
            ),
            const SizedBox(height: 20),
            _roleButton(
              context,
              title: 'I am a Lawyer',
              role: UserRole.lawyer,
            ),
          ],
        ),
      ),
    );
  }

  Widget _roleButton(
      BuildContext context, {
        required String title,
        required UserRole role,
      }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) =>
              role == UserRole.client
                  ? const ClientDashboardScreen()
                  : const LawyerDashboardScreen(),
            ),
          );
        },
        child: Text(title),
      ),
    );
  }
}
