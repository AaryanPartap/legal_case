import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'edit_profile_screen.dart';
import 'notification_settings_screen.dart';
import '../../../common/state/avatar_cache.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  final Color primaryDark = const Color(0xFF0F172A);
  final Color accentBlue = const Color(0xFF2563EB);
  final Color backgroundSlate = const Color(0xFFF8FAFC);

  int _completionPercent(Map<String, dynamic> data) {
    int total = 3; // Client requirements
    int filled = 0;

    if ((data['name'] ?? '').isNotEmpty) filled++;
    if ((data['email'] ?? '').isNotEmpty) filled++;
    if ((data['role'] ?? '').isNotEmpty) filled++;

    if (data['role'] == 'lawyer') {
      total = 5; // Name, Email, Role, BarId, OfficeAddress
      if ((data['barCouncilId'] ?? '').isNotEmpty) filled++;
      if ((data['officeAddress'] ?? '').isNotEmpty) filled++;
    }

    return ((filled / total) * 100).toInt();
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      backgroundColor: backgroundSlate,
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
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

          return CustomScrollView(
            slivers: [
              // --- MODERN HEADER WITH GRADIENT ---
              SliverAppBar(
                expandedHeight: 220,
                backgroundColor: primaryDark,
                pinned: true,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [primaryDark, const Color(0xFF1E293B)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),
                        _buildAvatar(name),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (role == 'lawyer' && verified)
                              const Padding(
                                padding: EdgeInsets.only(left: 6),
                                child: Icon(Icons.verified, color: Colors.green, size: 20),
                              ),
                          ],
                        ),
                        Text(
                          email,
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.6),
                              fontSize: 14
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // --- PROFILE CONTENT ---
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Completion Card
                    _buildCompletionCard(completion),
                    const SizedBox(height: 24),

                    _sectionTitle('Account Management'),
                    _menuItem(Icons.edit_outlined, 'Edit Profile', () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen()));
                    }),
                    _menuItem(Icons.notifications_none_outlined, 'Notification Settings', () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationSettingsScreen()));
                    }),

                    const SizedBox(height: 24),
                    _sectionTitle('Security & Support'),
                    _menuItem(Icons.logout, 'Logout', () async {
                      await FirebaseAuth.instance.signOut();
                      Navigator.popUntil(context, (r) => r.isFirst);
                    }),
                    const SizedBox(height: 10),
                    _menuItem(
                        Icons.delete_forever_outlined,
                        'Delete Account',
                            () async {
                          // Keep your existing delete logic here
                        },
                        danger: true
                    ),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAvatar(String name) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 4),
      ),
      child: CircleAvatar(
        radius: 45,
        backgroundColor: accentBlue,
        backgroundImage: AvatarCache.image != null ? FileImage(AvatarCache.image!) : null,
        child: AvatarCache.image == null
            ? Text(
          name.isNotEmpty ? name[0].toUpperCase() : 'U',
          style: const TextStyle(fontSize: 32, color: Colors.white, fontWeight: FontWeight.bold),
        )
            : null,
      ),
    );
  }

  Widget _buildCompletionCard(int completion) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4)
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Profile Completion', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              Text('$completion%', style: TextStyle(color: accentBlue, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: completion / 100,
              minHeight: 8,
              backgroundColor: Colors.grey.shade100,
              color: accentBlue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade500,
            letterSpacing: 1.1
        ),
      ),
    );
  }

  Widget _menuItem(IconData icon, String title, VoidCallback onTap, {bool danger = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.05)),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: danger ? Colors.red : primaryDark),
        title: Text(
          title,
          style: TextStyle(
            color: danger ? Colors.red : primaryDark,
            fontWeight: FontWeight.w500,
            fontSize: 15,
          ),
        ),
        trailing: Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 20),
      ),
    );
  }
}