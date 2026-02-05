import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NewRequestsScreen extends StatelessWidget {
  const NewRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lawyerId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Requests'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('booking_requests')
            .where('lawyerId', isEqualTo: lawyerId)
            .where('status', isEqualTo: 'pending')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          // ⏳ Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // ❌ Error
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }

          // 📭 Empty
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No new requests'));
          }

          final requests = snapshot.data!.docs;

          return ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, i) {
              final doc = requests[i];
              final data = doc.data() as Map<String, dynamic>;

              final clientName = data['clientName'] ?? 'Client';
              final specialization =
              (data['specialization'] ?? '').toString().toUpperCase();

              return Card(
                margin:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue,
                    child: Text(
                      clientName[0].toUpperCase(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(
                    clientName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(specialization),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      /// ✅ ACCEPT
                      IconButton(
                        icon: const Icon(Icons.check_circle,
                            color: Colors.green),
                        onPressed: () async {
                          await doc.reference
                              .update({'status': 'accepted'});

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Request accepted'),
                            ),
                          );
                        },
                      ),

                      /// ❌ REJECT
                      IconButton(
                        icon:
                        const Icon(Icons.cancel, color: Colors.redAccent),
                        onPressed: () async {
                          await doc.reference
                              .update({'status': 'rejected'});

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Request rejected'),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
