import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:legal_case_manager/common/widgets/dashboard_widgets.dart';
import 'package:legal_case_manager/features/profile/screens/profile_screen.dart';
import 'package:legal_case_manager/features/lawyer/screens/lawyer_list_screen.dart';
import 'package:legal_case_manager/services/screens/service_category_screen.dart';
import '../../chat/screens/chat_screen.dart'; // Import ChatScreen

class ClientDashboardScreen extends StatelessWidget {
  const ClientDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F6FA),
      bottomNavigationBar: _bottomNav(context),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            /// HEADER + SEARCH
            const DashboardHeader(),
            const SizedBox(height: 20),

            /// BANNER
            _banner(),
            const SizedBox(height: 24),

            /// SERVICES
            _sectionTitle('Services'),
            _servicesGrid(),
            const SizedBox(height: 24),

            /// LAWYER CATEGORIES
            _sectionTitle('Lawyers'),
            _lawyerCategoryGrid(context),
            const SizedBox(height: 24),

            /// YOUR CONVERSATIONS SECTION
            _sectionTitle('Your Conversations'),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('booking_requests')
                  .where('clientId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Text('No conversations found', textAlign: TextAlign.center),
                  );
                }
                final requests = snapshot.data!.docs;
                final uniqueLawyerIds = <String>{};
                final filteredLawyers = requests.where((doc) {
                  final lawyerId = (doc.data() as Map<String, dynamic>)['lawyerId'];
                  return uniqueLawyerIds.add(lawyerId); // Only returns true if ID was not already in the set
                }).toList();

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredLawyers.length,
                  itemBuilder: (context, i) {
                    final data = filteredLawyers[i].data() as Map<String, dynamic>;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Colors.blue,
                          child: Icon(Icons.person, color: Colors.white),
                        ),
                        title: Text(
                          data['lawyerName'] ?? 'Lawyer',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: const Text('Tap to chat'),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChatScreen(
                              otherUserId: data['lawyerId'],
                              otherUserName: data['lawyerName'] ?? 'Lawyer',
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // ================= BANNER =================
  Widget _banner() {
    return Container(
      height: 130,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Find Best Lawyers\nwith us',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Image.asset(
            'assets/images/layer1.png',
            height: 90,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => const Icon(Icons.image, size: 50, color: Colors.white),
          ),
        ],
      ),
    );
  }

  // ================= SECTION TITLE =================
  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // ================= SERVICES GRID =================
  Widget _servicesGrid() {
    final services = [
      ('Business Setup', Icons.bar_chart),
      ('Documentation', Icons.description),
      ('Disputes', Icons.gavel),
      ('Consultant', Icons.headset_mic),
      ('Legal Advice', Icons.chat),
      ('Legal Info', Icons.account_balance),
      ('Cross Border', Icons.public),
      ('Legal Aid', Icons.balance),
      ('Traffic Laws', Icons.traffic),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0B2B45),
        borderRadius: BorderRadius.circular(20),
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: services.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
        ),
        itemBuilder: (context, i) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ServiceCategoryScreen(
                    title: services[i].$1,
                  ),
                ),
              );
            },
            child: Column(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: Colors.white,
                  child: Icon(
                    services[i].$2,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  services[i].$1,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ================= LAWYER CATEGORY GRID =================
  Widget _lawyerCategoryGrid(BuildContext context) {
    final categories = [
      {'title': 'Criminal', 'image': 'assets/images/criminal.png', 'key': 'criminal'},
      {'title': 'Civil', 'image': 'assets/images/civil.png', 'key': 'civil'},
      {'title': 'Corporate', 'image': 'assets/images/corporate.png', 'key': 'corporate'},
      {'title': 'Public Interest', 'image': 'assets/images/public.png', 'key': 'public'},
      {'title': 'Immigration', 'image': 'assets/images/immigration.png', 'key': 'immigration'},
      {'title': 'Property', 'image': 'assets/images/property.png', 'key': 'property'},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: categories.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.85,
      ),
      itemBuilder: (context, i) {
        final item = categories[i];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => LawyerListScreen(
                  specialization: item['key']!,
                  title: '${item['title']} Lawyers',
                ),
              ),
            );
          },
          child: Column(
            children: [
              Container(
                height: 80,
                width: 80,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(10),
                child: Image.asset(
                  item['image']!,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.person, color: Colors.blue),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                item['title']!,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ================= BOTTOM NAV =================
  Widget _bottomNav(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 0,
      onTap: (index) {
        if (index == 2) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProfileScreen()),
          );
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.grid_view), label: 'Categories'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
    );
  }
}