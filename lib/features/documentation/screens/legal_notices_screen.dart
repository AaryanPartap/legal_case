import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class LegalNoticesScreen extends StatelessWidget {
  const LegalNoticesScreen({super.key});

  Future<void> _openLink(String url) async {
    final uri = Uri.parse(url);

    if (!await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    )) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Legal Notices')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _docTile(
            title: 'Legal Notice Format – India',
            url:
            'https://www.legalserviceindia.com/legal/article-192-legal-notice.html',
          ),
          _docTile(
            title: 'Consumer Legal Notice',
            url:
            'https://consumerhelpline.gov.in/',
          ),
        ],
      ),
    );
  }

  Widget _docTile({required String title, required String url}) {
    return Card(
      child: ListTile(
        title: Text(title),
        trailing: const Icon(Icons.open_in_new),
        onTap: () => _openLink(url),
      ),
    );
  }
}
