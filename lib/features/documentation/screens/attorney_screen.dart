import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AttorneyScreen extends StatelessWidget {
  const AttorneyScreen({super.key});

  final List<Map<String, String>> notices = const [
    {
      'title': 'Legal Notice Format – India',
      'url': 'https://www.legalserviceindia.com/legal/article-192-legal-notice.html'
    },
    {
      'title': 'Consumer Legal Notice',
      'url': 'https://consumerhelpline.gov.in/'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Legal Notices')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: notices.length,
        itemBuilder: (_, i) {
          return ListTile(
            title: Text(notices[i]['title']!),
            trailing: const Icon(Icons.download),
            onTap: () async {
              final url = Uri.parse(notices[i]['url']!);
              await launchUrl(url);
            },
          );
        },
      ),
    );
  }
}
