// app_routes.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:minna_ai_n5/providers/auth_init_provider.dart';
import 'package:minna_ai_n5/routes/navigation_manager.dart';
import 'package:minna_ai_n5/screens/alphabet/alphabet_flashcard_screen.dart';
import 'package:minna_ai_n5/screens/alphabet/alphabet_menu_screen.dart';
import 'package:minna_ai_n5/screens/home/home_screen.dart';
import 'package:minna_ai_n5/screens/splash/splash_screen.dart';

// Tạo GoRouter dưới dạng Provider để có thể watch auth state
final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authInitProvider);

  return GoRouter(
    initialLocation:
        NavigationManager.splashPath, // Bắt đầu từ splash để check auth
    redirect: (context, state) {
      // Nếu đang loading auth → ở lại splash
      if (authState.isLoading || authState.hasError) {
        return NavigationManager.splashPath;
      }

      final user = authState.value; // FirebaseUser hoặc null

      final isLoggedIn = user != null;
      final isOnSplash = state.uri.path == NavigationManager.splashPath;
      final isOnAuthScreen = [
        NavigationManager.welcomePath,
        NavigationManager.loginPath,
        NavigationManager.registerPath,
        NavigationManager.forgetPasswordPath,
      ].contains(state.uri.path);

      // Nếu chưa đăng nhập và không đang ở màn auth → chuyển về login/welcome
      if (!isLoggedIn && !isOnAuthScreen && !isOnSplash) {
        return NavigationManager.loginPath; // hoặc welcomePath tùy bạn
      }

      // Nếu đã đăng nhập nhưng đang ở màn auth → chuyển về home
      if (isLoggedIn && isOnAuthScreen) {
        return NavigationManager.homePath;
      }

      // Nếu đang ở splash và đã có kết quả auth → cho đi tiếp
      if (isOnSplash) {
        return isLoggedIn
            ? NavigationManager.homePath
            : NavigationManager.loginPath;
      }

      // Không redirect
      return null;
    },
    routes: [
      // Splash (loading auth)
      GoRoute(
        path: NavigationManager.splashPath,
        name: NavigationManager.splash,
        builder: (context, state) => const SplashScreen(),
      ),

      // Auth routes (không cần login)
      // GoRoute(
      //   path: NavigationManager.welcomePath,
      //   name: NavigationManager.welcome,
      //   builder: (context, state) => const WelcomeScreen(), // Nếu có
      // ),
      // GoRoute(
      //   path: NavigationManager.loginPath,
      //   name: NavigationManager.login,
      //   builder: (context, state) => const LoginScreen(),
      // ),
      // Thêm register, forget nếu cần...

      // Protected routes (cần đăng nhập)
      GoRoute(
        path: NavigationManager.homePath,
        name: NavigationManager.home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: NavigationManager.alphabetPath,
        name: NavigationManager.alphabet,
        builder: (context, state) => const AlphabetMenuScreen(),
      ),
      GoRoute(
        path: NavigationManager.alphabetHiraganaPath,
        name: NavigationManager.hiragana,
        builder: (context, state) =>
            const AlphabetFlashcardScreen(type: AlphabetType.hiragana),
      ),
      GoRoute(
        path: NavigationManager.alphabetKatakanaPath,
        name: NavigationManager.katakana,
        builder: (context, state) =>
            const AlphabetFlashcardScreen(type: AlphabetType.katakana),
      ),
    ],
    errorBuilder: (context, state) =>
        Scaffold(body: Center(child: Text('Page not found: ${state.uri}'))),
  );
});
