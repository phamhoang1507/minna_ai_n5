import 'package:flutter_riverpod/legacy.dart';
import 'package:minna_ai_n5/core/service/ai_service.dart';
import 'package:minna_ai_n5/models/chat_role.dart';

final aiChatProvider = StateNotifierProvider<AiChatNotifier, List<ChatMessage>>(
  (ref) => AiChatNotifier(AiService()),
);

class AiChatNotifier extends StateNotifier<List<ChatMessage>> {
  final AiService aiService;

  AiChatNotifier(this.aiService) : super([]);

  Future<void> send(String text) async {
    state = [...state, ChatMessage(role: ChatRole.user, text: text)];

    final reply = await aiService.sendMessage(text);

    state = [...state, ChatMessage(role: ChatRole.ai, text: reply)];
  }
}
