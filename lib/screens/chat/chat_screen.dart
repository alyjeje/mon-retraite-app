import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:intl/intl.dart';
import '../../core/theme/theme.dart';

/// Écran de chat avec l'assistant épargne retraite - dash_chat_2
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  // Utilisateurs
  final ChatUser _currentUser = ChatUser(
    id: '1',
    firstName: 'Utilisateur',
  );

  final ChatUser _aiUser = ChatUser(
    id: '2',
    firstName: 'Assistant',
    profileImage: 'ai_avatar', // Marqueur pour afficher l'avatar personnalisé
  );

  final List<ChatMessage> _messages = [];
  bool _isTyping = false;

  // Configuration du backend
  static const String _backendUrl = 'https://chi-meters-bills-command.trycloudflare.com';

  @override
  void initState() {
    super.initState();
    // Message de bienvenue
    _messages.insert(
      0,
      ChatMessage(
        text: "Bonjour ! Je suis votre assistant virtuel spécialisé dans l'épargne retraite. "
            "Je peux vous aider à comprendre les différents types de PER, la fiscalité, "
            "les trimestres de retraite et bien plus encore.\n\n"
            "Comment puis-je vous aider aujourd'hui ?",
        user: _aiUser,
        createdAt: DateTime.now(),
      ),
    );
  }

  Future<void> _handleSendPressed(ChatMessage message) async {
    // Ajouter le message de l'utilisateur
    setState(() {
      _messages.insert(0, message);
      _isTyping = true;
    });

    // DashChat utilise une liste inversée, les nouveaux messages apparaissent automatiquement en bas

    try {
      final response = await http.post(
        Uri.parse('$_backendUrl/chat'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'message': message.text}),
      ).timeout(const Duration(seconds: 120));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final aiResponse = ChatMessage(
          text: data['response'] ?? "Désolé, je n'ai pas pu générer de réponse.",
          user: _aiUser,
          createdAt: DateTime.now(),
          customProperties: {
            'sources': (data['sources'] as List<dynamic>?)?.cast<String>(),
          },
        );

        setState(() {
          _messages.insert(0, aiResponse);
          _isTyping = false;
        });
      } else {
        _showErrorMessage("Une erreur s'est produite. Veuillez réessayer.");
      }
    } catch (e) {
      _showErrorMessage(
        "Impossible de contacter le serveur. Vérifiez que le backend est démarré.",
      );
    }
  }

  void _showErrorMessage(String errorText) {
    setState(() {
      _messages.insert(
        0,
        ChatMessage(
          text: errorText,
          user: _aiUser,
          createdAt: DateTime.now(),
          customProperties: {'isError': true},
        ),
      );
      _isTyping = false;
    });
  }

  void _copyMessage(ChatMessage message) {
    Clipboard.setData(ClipboardData(text: message.text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Message copié'),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: _buildAppBar(isDark),
      body: Column(
        children: [
          // Disclaimer permanent
          _buildDisclaimer(isDark),

          // Chat
          Expanded(
            child: DashChat(
              currentUser: _currentUser,
              onSend: _handleSendPressed,
              messages: _messages,
              typingUsers: _isTyping ? [_aiUser] : [],
              inputOptions: InputOptions(
                inputDecoration: InputDecoration(
                  hintText: 'Posez votre question...',
                  hintStyle: AppTypography.bodyMedium.copyWith(
                    color: isDark
                        ? AppColors.textTertiaryDark
                        : AppColors.textTertiaryLight,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(
                      color: isDark ? AppColors.borderDark : AppColors.borderLight,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(
                      color: isDark ? AppColors.borderDark : AppColors.borderLight,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: const BorderSide(color: AppColors.primary, width: 2),
                  ),
                  filled: true,
                  fillColor: isDark
                      ? AppColors.inputBackgroundDark
                      : AppColors.inputBackgroundLight,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                inputTextStyle: AppTypography.bodyMedium.copyWith(
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
                sendButtonBuilder: (onSend) => _buildSendButton(onSend, isDark),
              ),
              messageOptions: MessageOptions(
                showTime: true,
                timeFormat: DateFormat('HH:mm'),
                currentUserContainerColor: AppColors.primary,
                currentUserTextColor: Colors.white,
                containerColor: isDark ? AppColors.cardDark : AppColors.cardLight,
                textColor: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
                messagePadding: const EdgeInsets.all(12),
                borderRadius: 16,
                onLongPressMessage: _copyMessage,
                messageDecorationBuilder: (message, previousMessage, nextMessage) {
                  final isUser = message.user.id == _currentUser.id;
                  final isError = message.customProperties?['isError'] == true;

                  return BoxDecoration(
                    color: isUser
                        ? AppColors.primary
                        : isError
                            ? (isDark ? AppColors.errorLightDark : AppColors.errorLight)
                            : (isDark ? AppColors.cardDark : AppColors.cardLight),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isUser ? 16 : 4),
                      bottomRight: Radius.circular(isUser ? 4 : 16),
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
                  );
                },
                messageTextBuilder: (message, previousMessage, nextMessage) {
                  final isError = message.customProperties?['isError'] == true;
                  final sources = message.customProperties?['sources'] as List<String>?;
                  final isUser = message.user.id == _currentUser.id;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message.text,
                        style: AppTypography.bodyMedium.copyWith(
                          color: isUser
                              ? Colors.white
                              : isError
                                  ? AppColors.errorTextOnLight
                                  : (isDark
                                      ? AppColors.textPrimaryDark
                                      : AppColors.textPrimaryLight),
                        ),
                      ),
                      if (sources != null && sources.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Sources: ${sources.join(", ")}',
                          style: AppTypography.caption.copyWith(
                            color: isDark
                                ? AppColors.textTertiaryDark
                                : AppColors.textTertiaryLight,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ],
                  );
                },
                avatarBuilder: (user, onAvatarTap, onAvatarLongPress) {
                  if (user.id == _aiUser.id) {
                    return _buildAIAvatar(isDark);
                  }
                  return const SizedBox.shrink();
                },
              ),
              messageListOptions: const MessageListOptions(),
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isDark) {
    return AppBar(
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
          _buildAIAvatar(isDark),
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
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _isTyping ? 'En train d\'écrire...' : 'En ligne',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.success,
                      ),
                    ),
                  ],
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
    );
  }

  Widget _buildAIAvatar(bool isDark) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Icon(
        Icons.smart_toy_outlined,
        color: Colors.white,
        size: 22,
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

  Widget _buildSendButton(Function() onSend, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(left: 8),
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: _isTyping ? AppColors.mutedLight : AppColors.primary,
        shape: BoxShape.circle,
        boxShadow: _isTyping
            ? null
            : [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: IconButton(
        onPressed: _isTyping ? null : onSend,
        icon: Icon(
          _isTyping ? Icons.hourglass_empty : Icons.send,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }
}
