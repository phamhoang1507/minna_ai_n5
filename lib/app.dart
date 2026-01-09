import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/auth_init_provider.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/error/error_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Consumer(
          builder: (context, ref, _) {
            final authState = ref.watch(authInitProvider);

            return authState.when(
              data: (_) => const HomeScreen(),
              loading: () => const SplashScreen(),
              // error: (_, __) => const ErrorScreen(),
              error: (error, stack) {
                debugPrint('AUTH ERROR: $error');
                debugPrintStack(stackTrace: stack);
                return const ErrorScreen();
              },
            );
          },
        ),
      ),
    );
  }
}
