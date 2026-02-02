import 'package:flutter/material.dart';
import 'package:legal_case_manager/common/widgets/dashboard_widgets.dart';

class LawyerDashboardScreen extends StatelessWidget {
  const LawyerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F6FA),
      bottomNavigationBar: _bottomNav(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [
              const DashboardHeader(),
              const SizedBox(height: 20),

              /// BANNER
              Container(
                height: 130,
                decoration: BoxDecoration(
                  color: const Color(0xFF0B2B45),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: const [
                    Expanded(
                      child: Text(
                        'Manage Clients\nGrow Your Practice',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Icon(Icons.balance, size: 70, color: Colors.white),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              _sectionTitle('Your Actions'),
              _lawyerActions(),
            ],
          ),
        ),
      ),
    );
  }

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

  Widget _lawyerActions() {
    final actions = [
      ('New Requests', Icons.inbox),
      ('Active Cases', Icons.folder),
      ('Schedule', Icons.calendar_month),
      ('Earnings', Icons.account_balance_wallet),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: actions.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
      ),
      itemBuilder: (_, i) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(actions[i].$2, size: 36, color: Colors.blue),
            const SizedBox(height: 10),
            Text(actions[i].$1),
          ],
        ),
      ),
    );
  }

  Widget _bottomNav() {
    return BottomNavigationBar(
      currentIndex: 0,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
        BottomNavigationBarItem(icon: Icon(Icons.assignment), label: ''),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
      ],
    );
  }
}
