import 'package:flutter/material.dart';
import 'package:legal_case_manager/features/client/screens/client_dashboard.dart';
import '../../../common/widgets/dashboard_widgets.dart';
import 'package:legal_case_manager/features/profile/screens/profile_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:legal_case_manager/features/documentation/screens/documentation_screen.dart';

class ServiceCategoryScreen extends StatelessWidget {
  final String title;

  const ServiceCategoryScreen({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F6FA),
      bottomNavigationBar: _bottomNav(context),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const DashboardHeader(),
            const SizedBox(height: 20),

            /// CATEGORY TITLE
            Text(
              title.toUpperCase(),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),

            const SizedBox(height: 16),

            /// SUB SERVICES
            _subServicesGrid(context),

            const SizedBox(height: 24),

            /// RECOMMENDED LAWYERS
            const Text(
              'Recommended Lawyers',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            _recommendedLawyers(),
          ],
        ),
      ),
    );
  }

  // ================= SUB SERVICES =================
  Widget _subServicesGrid(BuildContext context) {
    final services = [
      {
        'title': 'Business Setup',
        'icon': 'assets/images/b1.png',
      },
      {
        'title': 'Documentation',
        'icon': 'assets/images/b2.png',
      },
      {
        'title': 'Disputes',
        'icon': 'assets/images/b3.png',
      },
      {
        'title': 'Legal Aid',
        'icon': 'assets/images/b4.png',
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: services.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.9,
      ),
      itemBuilder: (context, i) {
        final title = services[i]['title'] as String;

        return InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            if (title == 'Documentation') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const DocumentationScreen(),
                ),
              );
            }
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  services[i]['icon'] as String,
                  height: 36,
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }


  Widget _recommendedLawyers() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'lawyer')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final lawyers = snapshot.data!.docs;

        if (lawyers.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'No lawyers available yet',
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: lawyers.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 0.7,
          ),
          itemBuilder: (_, i) {
            final data = lawyers[i].data() as Map<String, dynamic>;

            final name = data['name'] ?? 'Lawyer';
            final avatarUrl = data['avatarUrl'];
            final experience = data['experience'] ?? 'Experienced';

            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  /// PROFILE IMAGE / INITIAL
                  Expanded(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                      child: avatarUrl != null && avatarUrl != ''
                          ? Image.network(
                        avatarUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      )
                          : Container(
                        color: Colors.blue,
                        alignment: Alignment.center,
                        child: Text(
                          name[0].toUpperCase(),
                          style: const TextStyle(
                            fontSize: 42,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),

                  /// INFO
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          experience,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
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
        if (index == 1) {
        Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ClientDashboardScreen()),
        );
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
        BottomNavigationBarItem(icon: Icon(Icons.grid_view), label: ''),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
      ],
    );
  }
}
