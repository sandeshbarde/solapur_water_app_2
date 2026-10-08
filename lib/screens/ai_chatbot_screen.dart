import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_colors.dart';
import '../l10n/app_localizations.dart';
import '../main.dart';
import '../services/api_client.dart';
import '../widgets/responsive_layout.dart';

/// Screen: JalAI Citizen Assistant
/// Clean conversational interface with REST backend integration and offline fallback.
class AIChatbotScreen extends StatefulWidget {
  const AIChatbotScreen({super.key});

  @override
  State<AIChatbotScreen> createState() => _AIChatbotScreenState();
}

class _AIChatbotScreenState extends State<AIChatbotScreen> {
  final TextEditingController _msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _messages = [];
  bool _isTyping = false;
  bool _hasStartedChat = false;

  final List<String> _suggestedPrompts = [
    'When will water come today?',
    'What is Ujani Dam live level?',
    'How do I report low pressure or leak?',
    'What is today\'s water quality index?',
  ];

  @override
  void initState() {
    super.initState();
    _messages.add({
      'isBot': true,
      'text': 'Namaste! I am JalAI, your Solapur Smart Water Assistant. How can I help you today?',
      'time': 'Just now',
    });
  }

  @override
  void dispose() {
    _msgController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage(String text) async {
    final query = text.trim();
    if (query.isEmpty) return;

    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    final langCode = localeProvider.locale.languageCode;

    setState(() {
      _hasStartedChat = true;
      _messages.add({
        'isBot': false,
        'text': query,
        'time': 'Now',
      });
      _isTyping = true;
    });
    _msgController.clear();
    _scrollToBottom();

    String botReply = '';
    try {
      final response = await ApiClient.post('/chat', body: {
        'message': query,
        'lang': langCode,
      }, requiresAuth: false);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        botReply = data['reply'] ?? '';
      }
    } catch (e) {
      // Offline fallback
      botReply = _getOfflineFallback(query, langCode);
    }

    if (botReply.isEmpty) {
      botReply = _getOfflineFallback(query, langCode);
    }

    if (!mounted) return;
    setState(() {
      _isTyping = false;
      _messages.add({
        'isBot': true,
        'text': botReply,
        'time': 'Now',
      });
    });
    _scrollToBottom();
  }

  String _getOfflineFallback(String query, String lang) {
    final q = query.toLowerCase();
    if (q.contains('ujani') || q.contains('dam') || q.contains('धरण') || q.contains('बांध')) {
      return (lang == 'mr')
          ? 'उजनी धरणामध्ये सध्या ८८.४% उपयुक्त पाणीसाठा उपलब्ध आहे. (ऑफलाइन माहिती)'
          : 'Ujani Dam live storage is currently at 88.4%. (Offline information)';
    }
    if (q.contains('timing') || q.contains('schedule') || q.contains('time') || q.contains('वेळ')) {
      return (lang == 'mr')
          ? 'सोलापूर शहरातील पाणीपुरवठा सकाळी ०६:०० ते ०८:३० दरम्यान होतो.'
          : 'Regular Solapur water supply runs between 06:00 AM and 08:30 AM.';
    }
    if (q.contains('leak') || q.contains('report') || q.contains('गळती') || q.contains('तक्रार')) {
      return (lang == 'mr')
          ? 'त्वरित तक्रार नोंदवण्यासाठी होम स्क्रीनवरील "Report Issue" बटण वापरा. आपल्याला २५ पॉईंट्स मिळतील!'
          : 'Use the "Report Issue" button on Home to report leaks with photos & GPS. You get 25 points!';
    }
    return (lang == 'mr')
        ? 'मी जल-एआय आहे. कृपया पाणीपुरवठा वेळ, धरण पातळी किंवा तक्रार नोंदणीबद्दल विचारा.'
        : 'I am JalAI. Ask me about supply timings, dam level, water quality, or complaints.';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accent = AppColors.accent(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
              ),
              child: const Icon(Icons.smart_toy_outlined, color: AppColors.primary, size: 22),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('JalAI', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(
                  'Your Water Assistant',
                  style: TextStyle(color: accent, fontSize: 11, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Clear Chat',
            onPressed: () => setState(() {
              _messages.clear();
              _hasStartedChat = false;
              _messages.add({
                'isBot': true,
                'text': 'Namaste! I am JalAI. How can I help you today?',
                'time': 'Just now',
              });
            }),
          ),
        ],
      ),
      body: SafeArea(
        child: ResponsiveContainer(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              // Chat Message List
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: _messages.length + (_isTyping ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == _messages.length && _isTyping) {
                      return Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.surface2Dark : const Color(0xFFE8F1FC),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary)),
                              SizedBox(width: 8),
                              Text('JalAI is thinking...', style: TextStyle(fontSize: 12, color: AppColors.primary)),
                            ],
                          ),
                        ),
                      );
                    }

                    final msg = _messages[index];
                    final isBot = msg['isBot'] as bool;
                    final text = msg['text'] as String;

                    return Align(
                      alignment: isBot ? Alignment.centerLeft : Alignment.centerRight,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.82),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: isBot
                              ? (isDark ? AppColors.surface2Dark : const Color(0xFFE8F1FC))
                              : AppColors.primary,
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(16),
                            topRight: const Radius.circular(16),
                            bottomLeft: isBot ? const Radius.circular(4) : const Radius.circular(16),
                            bottomRight: isBot ? const Radius.circular(16) : const Radius.circular(4),
                          ),
                          border: isBot
                              ? Border.all(color: isDark ? AppColors.borderDark : const Color(0xFFD0E4FA))
                              : null,
                        ),
                        child: Text(
                          text,
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.4,
                            color: isBot
                                ? (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)
                                : Colors.white,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // 4 Pill Chips
              Container(
                height: 48,
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: _suggestedPrompts.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    final prompt = _suggestedPrompts[i];
                    return InkWell(
                      onTap: () => _sendMessage(prompt),
                      borderRadius: BorderRadius.circular(999),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.surface2Dark : const Color(0xFFE8F1FC),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: isDark ? AppColors.borderDark : const Color(0xFFCCE2FA)),
                        ),
                        child: Text(
                          prompt,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Input Bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.surface(context),
                  border: Border(top: BorderSide(color: AppColors.border(context))),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.surface2Dark : AppColors.cardLight,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border(context)),
                        ),
                        child: TextField(
                          controller: _msgController,
                          textInputAction: TextInputAction.send,
                          onSubmitted: _sendMessage,
                          decoration: const InputDecoration(
                            hintText: 'Type your question...',
                            contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.send, color: Colors.white, size: 20),
                        onPressed: () => _sendMessage(_msgController.text),
                      ),
                    ),
                  ],
                ),
              ),

              // Disclaimer
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 4),
                color: isDark ? AppColors.bgDark : const Color(0xFFF0F4F8),
                child: const Text(
                  'JalAI can make mistakes. For emergencies call SMC Helpline: 0217-2740300',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 10, color: Color(0xFF8FA8C0)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
