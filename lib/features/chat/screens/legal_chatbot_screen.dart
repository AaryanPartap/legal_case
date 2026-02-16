import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:legal_case_manager/services/chatbot_service.dart';

class LegalChatbotScreen extends StatefulWidget {
  const LegalChatbotScreen({super.key});

  @override
  State<LegalChatbotScreen> createState() => _LegalChatbotScreenState();
}

class _LegalChatbotScreenState extends State<LegalChatbotScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;

  // ✅ Constraint Logic: Pre-defined keywords for validation
  final List<String> _allowedTopics = [
    'law', 'constitution', 'finance', 'advocacy', 'lawyer', 'court', 'judge',
    'legal', 'article', 'section', 'ipc', 'case', 'hearing', 'prison', 'rights'
  ];

  // Inside _LegalChatbotScreenState
  void _handleSend() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({"role": "user", "content": text});
      _isLoading = true;
    });
    _controller.clear();

    // ✅ Use the service to get the response
    String response = await ChatbotService.getAIResponse(text);

    setState(() {
      _isLoading = false;
      _messages.add({"role": "bot", "content": response});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Legal AI Assistant"), backgroundColor: Colors.blue),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, i) {
                final isUser = _messages[i]['role'] == 'user';
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.blue : Colors.grey[300],
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      _messages[i]['content']!,
                      style: TextStyle(color: isUser ? Colors.white : Colors.black),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_isLoading) const LinearProgressIndicator(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(hintText: "Ask about law, courts, or finance..."),
                  ),
                ),
                IconButton(icon: const Icon(Icons.send, color: Colors.blue), onPressed: _handleSend),
              ],
            ),
          ),
        ],
      ),
    );
  }
}