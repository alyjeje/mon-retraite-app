import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../core/theme/theme.dart';

/// Écran de chat avec l'assistant épargne retraite
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;

  // Configuration du backend
  static const String _backendUrl = 'http://localhost:5000';

  @override
  void initState() {
    super.initState();
    // Message de bienvenue
    _messages.add(
      ChatMessage(
        text: "Bonjour ! Je suis votre assistant virtuel spécialisé dans l'épargne retraite. "
            "Je peux vous aider à comprendre les différents types de PER, la fiscalité, "
            "les trimestres de retraite et bien plus encore.\n\n"
            "Comment puis-je vous aider aujourd'hui ?",
        isUser: false,
        timestamp: DateTime.now(),
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isLoading) return;

    // Ajouter le message de l'utilisateur
    setState(() {
      _messages.add(ChatMessage(
        text: text,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _isLoading = true;
    });

    _messageController.clear();
    _scrollToBottom();

    try {
      final response = await http.post(
        Uri.parse('$_backendUrl/chat'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'message': text}),
      ).timeout(const Duration(seconds: 120));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _messages.add(ChatMessage(
            text: data['response'] ?? "Désolé, je n'ai pas pu générer de réponse.",
            isUser: false,
            timestamp: DateTime.now(),
            sources: (data['sources'] as List<dynamic>?)?.cast<String>(),
          ));
        });
      } else {
        _showErrorMessage("Une erreur s'est produite. Veuillez réessayer.");
      }
    } catch (e) {
      _showErrorMessage(
        "Impossible de contacter le serveur. Vérifiez que le backend est démarré.",
      );
    } finally {
      setState(() => _isLoading = false);
      _scrollToBottom();
    }
  }

  void _showErrorMessage(String message) {
    setState(() {
      _messages.add(ChatMessage(
        text: message,
        isUser: false,
        timestamp: DateTime.now(),
        isError: true,
      ));
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.cardDark : AppColors.cardLight,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primaryLighter,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.smart_toy_outlined,
                color: AppColors.primary,
                size: 24,
              ),
            ),
            AppSpacing.horizontalGapSm,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Assistant Retraite',
                    style: AppTypography.labelLarge.copyWith(
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                  ),
                  Text(
                    'En ligne',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
      ),
      body: Column(
        children: [
          // Disclaimer permanent
          _buildDisclaimer(isDark),

          // Liste des messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              itemCount: _messages.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length && _isLoading) {
                  return _buildTypingIndicator(isDark);
                }
                return _buildMessageBubble(_messages[index], isDark);
              },
            ),
          ),

          // Zone de saisie
          _buildInputArea(isDark),
        ],
      ),
    );
  }

  Widget _buildDisclaimer(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.warningLightDark : AppColors.warningLight,
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            size: 16,
            color: isDark ? AppColors.warningDark : AppColors.warningTextOnLight,
          ),
          AppSpacing.horizontalGapXs,
          Expanded(
            child: Text(
              'Information générale uniquement. Pour tout conseil personnalisé, contactez votre conseiller.',
              style: AppTypography.caption.copyWith(
                color: isDark ? AppColors.warningDark : AppColors.warningTextOnLight,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message, bool isDark) {
    final isUser = message.isUser;
    final isError = message.isError;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isError ? AppColors.errorLight : AppColors.primaryLighter,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isError ? Icons.error_outline : Icons.smart_toy_outlined,
                color: isError ? AppColors.error : AppColors.primary,
                size: 18,
              ),
            ),
            AppSpacing.horizontalGapXs,
          ],
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.75,
                  ),
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: isUser
                        ? AppColors.primary
                        : isError
                            ? (isDark ? AppColors.errorLightDark : AppColors.errorLight)
                            : (isDark ? AppColors.cardDark : AppColors.cardLight),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(AppSpacing.radiusMd),
                      topRight: const Radius.circular(AppSpacing.radiusMd),
                      bottomLeft: Radius.circular(isUser ? AppSpacing.radiusMd : 4),
                      bottomRight: Radius.circular(isUser ? 4 : AppSpacing.radiusMd),
                    ),
                    border: isUser
                        ? null
                        : Border.all(
                            color: isError
                                ? AppColors.error.withValues(alpha: 0.3)
                                : (isDark
                                    ? AppColors.borderDark
                                    : AppColors.borderLight),
                          ),
                  ),
                  child: Text(
                    message.text,
                    style: AppTypography.bodyMedium.copyWith(
                      color: isUser
                          ? Colors.white
                          : isError
                              ? AppColors.error
                              : (isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimaryLight),
                    ),
                  ),
                ),
                if (message.sources != null && message.sources!.isNotEmpty) ...[
                  AppSpacing.verticalGapXxs,
                  Text(
                    'Sources: ${message.sources!.join(", ")}',
                    style: AppTypography.caption.copyWith(
                      color: isDark
                          ? AppColors.textTertiaryDark
                          : AppColors.textTertiaryLight,
                      fontSize: 10,
                    ),
                  ),
                ],
                AppSpacing.verticalGapXxs,
                Text(
                  _formatTime(message.timestamp),
                  style: AppTypography.caption.copyWith(
                    color: isDark
                        ? AppColors.textTertiaryDark
                        : AppColors.textTertiaryLight,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          if (isUser) ...[
            AppSpacing.horizontalGapXs,
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.primaryLighter,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person,
                color: AppColors.primary,
                size: 18,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTypingIndicator(bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.primaryLighter,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.smart_toy_outlined,
              color: AppColors.primary,
              size: 18,
            ),
          ),
          AppSpacing.horizontalGapXs,
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : AppColors.cardLight,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTypingDot(0),
                AppSpacing.horizontalGapXxs,
                _buildTypingDot(1),
                AppSpacing.horizontalGapXxs,
                _buildTypingDot(2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingDot(int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600 + (index * 200)),
      builder: (context, value, child) {
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.3 + (value * 0.5)),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }

  Widget _buildInputArea(bool isDark) {
    return Container(
      padding: EdgeInsets.only(
        left: AppSpacing.md,
        right: AppSpacing.md,
        top: AppSpacing.sm,
        bottom: MediaQuery.of(context).padding.bottom + AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Posez votre question...',
                hintStyle: AppTypography.bodyMedium.copyWith(
                  color: isDark
                      ? AppColors.textTertiaryDark
                      : AppColors.textTertiaryLight,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                  borderSide: BorderSide(
                    color: isDark ? AppColors.borderDark : AppColors.borderLight,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                  borderSide: BorderSide(
                    color: isDark ? AppColors.borderDark : AppColors.borderLight,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                  borderSide: BorderSide(
                    color: AppColors.primary,
                    width: 2,
                  ),
                ),
                filled: true,
                fillColor: isDark
                    ? AppColors.inputBackgroundDark
                    : AppColors.inputBackgroundLight,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
              ),
              style: AppTypography.bodyMedium.copyWith(
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
              maxLines: null,
              keyboardType: TextInputType.multiline,
            ),
          ),
          AppSpacing.horizontalGapSm,
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _isLoading ? AppColors.mutedLight : AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: _isLoading ? null : _sendMessage,
              icon: Icon(
                _isLoading ? Icons.hourglass_empty : Icons.send,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }
}

/// Modèle de message de chat
class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final List<String>? sources;
  final bool isError;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.sources,
    this.isError = false,
  });
}
