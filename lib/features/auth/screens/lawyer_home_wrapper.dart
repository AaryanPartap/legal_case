import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:legal_case_manager/features/lawyer/screens/lawyer_dashboard.dart';
import 'package:legal_case_manager/features/auth/screens/lawyer_verification_screen.dart';

class LawyerHomeWrapper extends StatelessWidget {
  const LawyerHomeWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final String uid = FirebaseAuth.instance.currentUser!.uid;

    return StreamBuilder<DocumentSnapshot>(
      // ✅ This stream stays active and "listens" for your manual status change in Firebase
      stream: FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Scaffold(body: Center(child: Text("Profile not found")));
        }

        var userData = snapshot.data!.data() as Map<String, dynamic>;
        String status = userData['status'] ?? 'pending';

        // ✅ DYNAMIC UI SWITCH
        if (status == 'verified') {
          return const LawyerDashboardScreen();
        } else {
          return const LawyerVerificationScreen();
        }
      },
    );
  }
}