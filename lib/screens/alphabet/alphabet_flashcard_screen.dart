import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/streak_provider.dart';

class AlphabetFlashcardScreen extends ConsumerStatefulWidget {
  const AlphabetFlashcardScreen({super.key});

  @override
  ConsumerState<AlphabetFlashcardScreen> createState() =>
      _AlphabetFlashcardScreenState();
}

class _AlphabetFlashcardScreenState
    extends ConsumerState<AlphabetFlashcardScreen> {

  bool _streakMarkedToday = false;

  @override
  void initState() {
    super.initState();

    /// Đánh dấu streak khi user bắt đầu học
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_streakMarkedToday) {
        ref.read(streakServiceProvider).markStudiedToday();
        _streakMarkedToday = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hiragana')),
      body: const Center(
        child: Text('Flashcard here'),
      ),
    );
  }
}
