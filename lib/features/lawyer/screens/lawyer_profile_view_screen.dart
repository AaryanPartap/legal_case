import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../../../common/widgets/dashboard_widgets.dart';
import '../../../features/lawyer/screens/lawyer_profile_edit_screen.dart';


class LawyerProfileViewScreen extends StatelessWidget {
  final String lawyerId;

  const LawyerProfileViewScreen({super.key, required this.lawyerId});

  Future<void> _openMaps(double lat, double lng) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng',
    );
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lawyer Profile')),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(lawyerId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const CircularProgressIndicator();

          final data = snapshot.data!.data() as Map<String, dynamic>;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(data['name'], style: const TextStyle(fontSize: 20)),
              Text('${data['specialization']} Lawyer'),

              const SizedBox(height: 16),

              ElevatedButton(
                child: const Text('Book Lawyer'),
                onPressed: () async {
                  final user = FirebaseAuth.instance.currentUser!;
                  final clientDoc = await FirebaseFirestore.instance
                      .collection('users')
                      .doc(user.uid)
                      .get();

                  await FirebaseFirestore.instance
                      .collection('booking_requests')
                      .add({
                    'clientId': user.uid,
                    'clientName': clientDoc['name'],
                    'lawyerId': lawyerId,
                    'status': 'pending',
                    'createdAt': FieldValue.serverTimestamp(),
                  });
                },
              ),

              if (data['officeLat'] != null)
                ListTile(
                  leading: const Icon(Icons.location_on),
                  title: Text(data['officeAddress'] ?? ''),
                  trailing: const Icon(Icons.directions),
                  onTap: () => _openMaps(
                    data['officeLat'],
                    data['officeLng'],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}


Future<void> openLawyerProfile(
    BuildContext context,
    String lawyerId,
    ) async {
  final uid = FirebaseAuth.instance.currentUser!.uid;

  final userDoc = await FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .get();

  final role = userDoc['role'];

  if (role == 'lawyer' && uid == lawyerId) {
    // Lawyer opening own profile
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LawyerProfileEditScreen(lawyerId: lawyerId),
      ),
    );
  } else {
    // Client viewing lawyer
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LawyerProfileViewScreen(lawyerId: lawyerId),
      ),
    );
  }
}
