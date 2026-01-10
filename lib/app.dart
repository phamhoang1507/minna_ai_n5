import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minna_ai_n5/routes/app_routes.dart';
class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider); // ← Lấy router từ provider

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Minna AI N5',
      routerConfig: router,
      theme: ThemeData(useMaterial3: true),
      supportedLocales: const [Locale('vi'), Locale('en')],
    );
  }
}
