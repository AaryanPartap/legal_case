import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'edit_profile_screen.dart';
import 'notification_settings_screen.dart';
import '../../../common/state/avatar_cache.dart';


class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  int _completionPercent(Map<String, dynamic> data) {
    int total = 4;
    int filled = 0;

    if ((data['name'] ?? '').toString().isNotEmpty) filled++;
    if ((data['email'] ?? '').toString().isNotEmpty) filled++;
    if ((data['role'] ?? '').toString().isNotEmpty) filled++;
    if (data['role'] == 'lawyer' &&
        (data['barCouncilId'] ?? '').toString().isNotEmpty) {
      filled++;
    }

    return ((filled / total) * 100).toInt();
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F6FA),
      body: SafeArea(
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final data = snapshot.data!.data() as Map<String, dynamic>;
            final name = data['name'] ?? 'User';
            final email = data['email'] ?? '';
            final role = data['role'] ?? 'client';
            final verified = data['verified'] == true;
            final completion = _completionPercent(data);

            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                /// BACK
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),

                /// AVATAR
                Center(
                  child: CircleAvatar(
                    radius: 45,
                    backgroundColor: Colors.blue,
                    backgroundImage: AvatarCache.image != null
                        ? FileImage(AvatarCache.image!)
                        : null,
                    child: AvatarCache.image == null
                        ? Text(
                      name[0].toUpperCase(),
                      style: const TextStyle(
                        fontSize: 32,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                        : null,
                  ),

                ),

                const SizedBox(height: 12),

                /// NAME + BADGE
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (role == 'lawyer' && verified)
                        const Padding(
                          padding: EdgeInsets.only(left: 6),
                          child: Icon(
                            Icons.verified,
                            color: Colors.green,
                            size: 20,
                          ),
                        ),
                    ],
                  ),
                ),

                Center(
                  child: Text(
                    email,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),

                const SizedBox(height: 20),

                /// COMPLETION
                Text('Profile Completion: $completion%'),
                const SizedBox(height: 6),
                LinearProgressIndicator(
                  value: completion / 100,
                  backgroundColor: Colors.grey.shade300,
                  color: Colors.green,
                ),

                const SizedBox(height: 24),

                _menuItem(
                  Icons.edit,
                  'Edit Profile',
                      () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const EditProfileScreen(),
                    ),
                  ),
                ),

                _menuItem(
                  Icons.notifications,
                  'Notification Settings',
                      () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const NotificationSettingsScreen(),
                    ),
                  ),
                ),

                _menuItem(
                  Icons.logout,
                  'Logout',
                      () async {
                    await FirebaseAuth.instance.signOut();
                    Navigator.popUntil(context, (r) => r.isFirst);
                  },
                ),

                _menuItem(
                  Icons.delete_forever,
                  'Delete Account',
                      () async {
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(uid)
                        .delete();
                    await FirebaseAuth.instance.currentUser!.delete();
                  },
                  danger: true,
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _menuItem(
      IconData icon,
      String title,
      VoidCallback onTap, {
        bool danger = false,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            children: [
              Icon(icon, color: danger ? Colors.red : Colors.black),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  color: danger ? Colors.red : Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
