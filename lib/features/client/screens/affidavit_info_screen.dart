import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class AffidavitInfoScreen extends StatelessWidget {
  const AffidavitInfoScreen({super.key});

  final List<Map<String, String>> affidavits = const [
    {'name': 'Address Proof Affidavit', 'file': 'address_affidavit.pdf'},
    {'name': 'Name Change Affidavit', 'file': 'name_change.pdf'},
    {'name': 'Income Certificate Affidavit', 'file': 'income_affidavit.pdf'},
    {'name': 'Gap Certificate Affidavit', 'file': 'gap_cert.pdf'},
  ];

  Future<void> _handleFileAction(BuildContext context, String fileName, bool isShare) async {
    try {
      // 1. Load the file from the local assets folder
      final byteData = await rootBundle.load('assets/doc/$fileName');

      // 2. Create a temporary file
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsBytes(byteData.buffer.asUint8List());

      // ✅ FIX: Check if the widget is still in the tree before using context
      if (!context.mounted) return;

      if (isShare) {
        // ✅ Trigger the native share sheet
        await Share.shareXFiles([XFile(file.path)], text: 'Download this Affidavit template.');
      } else {
        // ✅ Success snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$fileName ready to share/save'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text("Legal Affidavits", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: affidavits.length,
        itemBuilder: (context, index) {
          final item = affidavits[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                // Using withOpacity for broader compatibility
                decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    shape: BoxShape.circle
                ),
                child: const Icon(Icons.picture_as_pdf, color: Colors.red, size: 24),
              ),
              title: Text(item['name']!, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text("PDF Template • ${item['file']}", style: const TextStyle(fontSize: 12)),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.share_outlined, color: Colors.blue),
                    onPressed: () => _handleFileAction(context, item['file']!, true),
                  ),
                  IconButton(
                    icon: const Icon(Icons.download_for_offline_outlined, color: Colors.green),
                    onPressed: () => _handleFileAction(context, item['file']!, false),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}