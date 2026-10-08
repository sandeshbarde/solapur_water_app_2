import 'package:flutter/material.dart';
import 'ai_chatbot_screen.dart';

/// Legacy alias forwarding to canonical Aqua Civic AIChatbotScreen
class ChatbotScreen extends StatelessWidget {
  const ChatbotScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AIChatbotScreen();
  }
}
