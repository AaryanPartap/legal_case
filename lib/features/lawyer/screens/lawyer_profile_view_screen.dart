import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../chat/screens/chat_screen.dart';

class LawyerProfileViewScreen extends StatelessWidget {
  final String lawyerId;

  const LawyerProfileViewScreen({super.key, required this.lawyerId});

  // --- MAP & DIRECTION HELPERS ---
  String _getOSMMapUrl(double lat, double lng) {
    return 'https://staticmap.openstreetmap.de/staticmap.php?center=$lat,$lng&zoom=16&size=600x300&markers=$lat,$lng,ol-marker';
  }

  Future<void> _openGoogleMaps(double lat, double lng) async {
    final uri = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$lat,$lng');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(lawyerId).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final data = snapshot.data!.data() as Map<String, dynamic>?;
        if (data == null) return const Scaffold(body: Center(child: Text("Lawyer not found")));

        final String name = data['name'] ?? 'Lawyer';
        final String specialization = data['specialization'] ?? 'General';
        final String about = data['about'] ?? 'No description available';
        final int experience = data['experience'] ?? 0;
        final int cases = data['cases'] ?? 0;
        final dynamic rating = data['rating'] ?? 0.0;

        final double? lat = data['officeLat']?.toDouble();
        final double? lng = data['officeLng']?.toDouble();
        final String? officeAddress = data['officeAddress'];

        return Scaffold(
          backgroundColor: const Color(0xFFEFF6FF),
          appBar: AppBar(
            title: Text(name),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            elevation: 0,
          ),

          // Chat FAB
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              // Navigates to the same synchronized chat room
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChatScreen(
                    otherUserId: lawyerId, // Lawyer's ID
                    otherUserName: name,    // Lawyer's Name
                  ),
                ),
              );
            },
            backgroundColor: Colors.blue,
            child: const Icon(Icons.chat, color: Colors.white),
          ),

          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ===== PROFILE HEADER CARD =====
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDDEEFF),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.blue.shade100,
                        child: Text(name.isNotEmpty ? name[0].toUpperCase() : 'L',
                            style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.blue)),
                      ),
                      const SizedBox(height: 12),
                      Text(name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      Text('$specialization Lawyer', style: const TextStyle(color: Colors.blueGrey, fontSize: 14)),

                      const SizedBox(height: 16),

                      // Stat Chips from Profile Screen
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _statChip('$cases+', 'Cases'),
                          _statChip('$experience+', 'Exp'),
                          _statChip(rating.toString(), 'Rating'),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ===== ABOUT SECTION =====
                _sectionTitle('About'),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                  child: Text(about, style: const TextStyle(fontSize: 14, color: Colors.black87)),
                ),

                const SizedBox(height: 24),

                // ===== LOCATION SECTION (Direction Mechanism) =====
                if (lat != null && lng != null) ...[
                  _sectionTitle('Office Location'),
                  GestureDetector(
                    onTap: () => _openGoogleMaps(lat, lng),
                    child: Container(
                      height: 180,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.grey[200],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Stack(
                          children: [
                            Image.network(
                              _getOSMMapUrl(lat, lng),
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (ctx, err, stack) => const Center(child: Icon(Icons.map)),
                            ),
                            // Direction Overlay
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: Container(
                                margin: const EdgeInsets.all(10),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.location_on, color: Colors.red, size: 20),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(officeAddress ?? 'View directions',
                                          style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis),
                                    ),
                                    const Icon(Icons.directions, color: Colors.blue, size: 20),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 30),

                // ===== FINAL ACTION BUTTONS =====
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        ),
                        onPressed: () => _bookLawyer(context, data),
                        child: const Text("Book Now", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          side: const BorderSide(color: Colors.blue),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        ),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Portfolio view coming soon")));
                        },
                        child: const Text("Portfolio", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 100), // Space for FAB
              ],
            ),
          ),
        );
      },
    );
  }

  // Helper for Experience/Rating Chips
  Widget _statChip(String value, String label) {
    return Column(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: Colors.blue,
          child: Text(value, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.blueGrey)),
      ],
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 4),
      child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue)),
    );
  }

  void _showChatPopup(BuildContext context, String lawyerName) {
    final TextEditingController messageController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 20, right: 20, top: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Message $lawyerName", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            TextField(
              controller: messageController,
              autofocus: true,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: "Describe your case briefly...",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.grey.shade100,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, padding: const EdgeInsets.all(15)),
                onPressed: () {
                  if (messageController.text.trim().isNotEmpty) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Message sent! Lawyer will reply shortly.")));
                  }
                },
                child: const Text("Send Message", style: TextStyle(color: Colors.white)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _bookLawyer(BuildContext context, Map<String, dynamic> lawyerData) async {
    final user = FirebaseAuth.instance.currentUser!;
    try {
      await FirebaseFirestore.instance.collection('booking_requests').add({
        'clientId': user.uid,
        'lawyerId': lawyerId,
        'lawyerName': lawyerData['name'],
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Booking Request Sent!"), backgroundColor: Colors.green));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red));
      }
    }
  }
}