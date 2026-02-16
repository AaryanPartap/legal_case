import 'package:flutter/material.dart';
import 'package:legal_case_manager/features/chat/screens/legal_chatbot_screen.dart';

class MovableAIButton extends StatefulWidget {
  final Widget child;
  const MovableAIButton({super.key, required this.child});

  @override
  State<MovableAIButton> createState() => _MovableAIButtonState();
}

class _MovableAIButtonState extends State<MovableAIButton> {
  Offset position = const Offset(20, 500); // Initial position

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child, // The actual screen content
        Positioned(
          left: position.dx,
          top: position.dy,
          child: Draggable(
            feedback: _buildCircle(true),
            childWhenDragging: Container(),
            onDragEnd: (details) {
              setState(() {
                // Keep the button within screen bounds
                position = details.offset;
              });
            },
            child: GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LegalChatbotScreen()),
              ),
              child: _buildCircle(false),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCircle(bool isDragging) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(isDragging ? 0.5 : 1.0),
          shape: BoxShape.circle,
          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10)],
        ),
        child: const Icon(Icons.smart_toy, color: Colors.white, size: 30),
      ),
    );
  }
}