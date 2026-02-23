import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minna_ai_n5/models/chat_role.dart';
import 'package:minna_ai_n5/providers/ai_provider.dart';

class AiChatScreen extends ConsumerWidget {
  const AiChatScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messages = ref.watch(aiChatProvider);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(title: const Text('AI Hội thoại')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                reverse: true,
                padding: const EdgeInsets.all(8),
                itemCount: messages.length,
                itemBuilder: (_, i) {
                  final msg = messages[messages.length - 1 - i];
                  return Align(
                    alignment: msg.role == ChatRole.user
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.all(12),
                      constraints: const BoxConstraints(maxWidth: 280),
                      decoration: BoxDecoration(
                        color: msg.role == ChatRole.user
                            ? Colors.blue[100]
                            : Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(msg.text),
                    ),
                  );
                },
              ),
            ),
            _InputBox(ref),
          ],
        ),
      ),
    );
  }
}

class _InputBox extends StatefulWidget {
  final WidgetRef ref;
  const _InputBox(this.ref);

  @override
  State<_InputBox> createState() => _InputBoxState();
}

class _InputBoxState extends State<_InputBox> {
  final controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                minLines: 1,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Nhập tiếng Nhật...',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.send),
              onPressed: () {
                final text = controller.text.trim();
                if (text.isEmpty) return;

                widget.ref
                    .read(aiChatProvider.notifier)
                    .send(text);

                controller.clear();
              },
            ),
          ],
        ),
      ),
    );
  }
}

