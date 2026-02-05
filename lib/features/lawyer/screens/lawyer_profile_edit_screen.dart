import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../../../common/widgets/dashboard_widgets.dart';
import '../../../features/lawyer/screens/lawyer_profile_view_screen.dart';

class LawyerProfileEditScreen extends StatefulWidget {
  final String lawyerId;

  const LawyerProfileEditScreen({super.key, required this.lawyerId});

  @override
  State<LawyerProfileEditScreen> createState() =>
      _LawyerProfileEditScreenState();
}

class _LawyerProfileEditScreenState
    extends State<LawyerProfileEditScreen> {
  double? officeLat;
  double? officeLng;
  String? officeAddress;

  Future<void> _detectAndSaveLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission =
    await Geolocator.requestPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) return;

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    final url = Uri.parse(
      'https://nominatim.openstreetmap.org/reverse'
          '?format=json&lat=${position.latitude}&lon=${position.longitude}'
          '&zoom=18&addressdetails=1',
    );

    final response = await http.get(
      url,
      headers: {'User-Agent': 'legal_case_manager'},
    );

    final data = json.decode(response.body);
    final address = data['display_name'];

    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.lawyerId)
        .update({
      'officeLat': position.latitude,
      'officeLng': position.longitude,
      'officeAddress': address,
    });

    setState(() {
      officeLat = position.latitude;
      officeLng = position.longitude;
      officeAddress = address;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Profile')),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(widget.lawyerId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const CircularProgressIndicator();

          final data = snapshot.data!.data() as Map<String, dynamic>;

          officeLat = data['officeLat'];
          officeLng = data['officeLng'];
          officeAddress = data['officeAddress'];

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(data['name'], style: const TextStyle(fontSize: 20)),
              const SizedBox(height: 12),

              OutlinedButton.icon(
                icon: const Icon(Icons.my_location),
                label: Text(
                  officeAddress == null
                      ? 'Add Office Location'
                      : 'Update Office Location',
                ),
                onPressed: _detectAndSaveLocation,
              ),

              if (officeAddress != null)
                Text('Saved Address:\n$officeAddress'),
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
