import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/user_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userDoc = ref.watch(userDocProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          userDoc.when(
            data: (doc) {
              final streak = doc['streak'] ?? 0;
              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Center(child: Text('🔥 $streak')),
              );
            },
            loading: () => const SizedBox(),
            error: (_, __) => const SizedBox(),
          ),
        ],
      ),
      body: const Center(
        child: Text('Welcome'),
      ),
    );
  }
}
