// File: lib/routes/app_routes.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:minna_ai_n5/providers/auth_init_provider.dart';
import 'package:minna_ai_n5/routes/navigation_manager.dart';
import 'package:minna_ai_n5/screens/alphabet/alphabet_flashcard_screen.dart';
import 'package:minna_ai_n5/screens/alphabet/alphabet_menu_screen.dart';
import 'package:minna_ai_n5/screens/home/home_screen.dart';
import 'package:minna_ai_n5/screens/login/login_screen.dart';
import 'package:minna_ai_n5/screens/setting/setting_screen.dart';
import 'package:minna_ai_n5/screens/splash/splash_screen.dart';
import 'package:minna_ai_n5/screens/vocabulary/lesson_detail_screen.dart';
import 'package:minna_ai_n5/screens/vocabulary/vocabulary_screen.dart';
import 'package:minna_ai_n5/screens/welcome/welcome_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ✅ Provider kiểm tra đã xem welcome chưa
final hasSeenWelcomeProvider = FutureProvider<bool>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool('has_seen_welcome') ?? false;
});

// ✅ Provider để đánh dấu đã xem welcome
final welcomeServiceProvider = Provider<WelcomeService>((ref) {
  return WelcomeService();
});

class WelcomeService {
  Future<void> markWelcomeSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_welcome', true);
  }

  Future<void> resetWelcome() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('has_seen_welcome');
  }
}

// ✅ Router Provider với logic phân tách rõ ràng
final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  final hasSeenWelcomeAsync = ref.watch(hasSeenWelcomeProvider);

  return GoRouter(
    initialLocation: NavigationManager.welcomePath,
    redirect: (context, state) {
      return _handleRedirect(
        authState: authState,
        hasSeenWelcomeAsync: hasSeenWelcomeAsync,
        currentPath: state.uri.path,
      );
    },
    routes: _buildRoutes(),
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red),
            SizedBox(height: 16),
            Text('Page not found: ${state.uri}'),
          ],
        ),
      ),
    ),
  );
});

// ✅ Redirect logic tách riêng để dễ đọc
String? _handleRedirect({
  required AsyncValue authState,
  required AsyncValue<bool> hasSeenWelcomeAsync,
  required String currentPath,
}) {
  // 1️⃣ Đang loading auth hoặc welcome → stay on splash
  if (authState.isLoading || hasSeenWelcomeAsync.isLoading) {
    if (currentPath != NavigationManager.splashPath) {
      return NavigationManager.splashPath;
    }
    return null;
  }

  // 2️⃣ Có lỗi auth → về login
  if (authState.hasError) {
    return NavigationManager.loginPath;
  }

  final user = authState.value;
  final isLoggedIn = user != null;
  final hasSeenWelcome = hasSeenWelcomeAsync.value ?? false;

  // 3️⃣ Phân loại các nhóm màn hình
  final isOnSplash = currentPath == NavigationManager.splashPath;
  final isOnWelcome = currentPath == NavigationManager.welcomePath;
  final isOnAuthScreen = _isAuthScreen(currentPath);
  final isOnProtectedScreen = _isProtectedScreen(currentPath);

  // 4️⃣ Logic redirect theo thứ tự ưu tiên

  // Chưa xem welcome → đi đến welcome (kể cả đã login)
  // TODO: Bỏ comment khi có WelcomeScreen
  // if (!hasSeenWelcome && !isOnWelcome && !isOnSplash) {
  //   return NavigationManager.welcomePath;
  // }

  // Đang ở splash và đã load xong → redirect
  if (isOnSplash) {
    // TODO: Uncomment khi có welcome
    // if (!hasSeenWelcome) {
    //   return NavigationManager.welcomePath;
    // }
    return isLoggedIn
        ? NavigationManager.homePath
        : NavigationManager.loginPath;
  }

  // Chưa login và đang cố vào màn hình protected → về login
  if (!isLoggedIn && isOnProtectedScreen) {
    return NavigationManager.loginPath;
  }

  // Đã login và đang ở màn auth → về home
  if (isLoggedIn && isOnAuthScreen) {
    return NavigationManager.homePath;
  }

  // Không redirect
  return null;
}

// ✅ Helper functions để check loại màn hình
bool _isAuthScreen(String path) {
  return [
    NavigationManager.welcomePath,
    NavigationManager.loginPath,
    NavigationManager.registerPath,
    NavigationManager.forgetPasswordPath,
  ].contains(path);
}

bool _isProtectedScreen(String path) {
  return [
    NavigationManager.homePath,
    NavigationManager.alphabetPath,
    NavigationManager.alphabetHiraganaPath,
    NavigationManager.alphabetKatakanaPath,
    // Thêm các protected routes khác ở đây
  ].contains(path);
}

// ✅ Routes tách riêng để dễ quản lý
List<RouteBase> _buildRoutes() {
  return [
    // System Routes
    ..._systemRoutes(),

    // Auth Routes (public)
    ..._authRoutes(),

    // Protected Routes (need login)
    ..._protectedRoutes(),
  ];
}

List<RouteBase> _systemRoutes() {
  return [
    GoRoute(
      path: NavigationManager.splashPath,
      name: NavigationManager.splash,
      builder: (context, state) => const SplashScreen(),
    ),
  ];
}

List<RouteBase> _authRoutes() {
  return [
    // TODO: Uncomment khi có WelcomeScreen
    GoRoute(
      path: NavigationManager.welcomePath,
      name: NavigationManager.welcome,
      builder: (context, state) => const WelcomeScreen(),
    ),

    GoRoute(
      path: NavigationManager.loginPath,
      name: NavigationManager.login,
      builder: (context, state) => const LoginScreen(),
    ),

    // TODO: Thêm các auth routes khác
    // GoRoute(
    //   path: NavigationManager.registerPath,
    //   name: NavigationManager.register,
    //   builder: (context, state) => const RegisterScreen(),
    // ),
    // GoRoute(
    //   path: NavigationManager.forgetPasswordPath,
    //   name: NavigationManager.forgetPassword,
    //   builder: (context, state) => const ForgetPasswordScreen(),
    // ),
  ];
}

List<RouteBase> _protectedRoutes() {
  return [
    // Home
    GoRoute(
      path: NavigationManager.homePath,
      name: NavigationManager.home,
      builder: (context, state) => const HomeScreen(),
    ),

    // Alphabet
    GoRoute(
      path: NavigationManager.alphabetPath,
      name: NavigationManager.alphabet,
      builder: (context, state) => const AlphabetMenuScreen(),
    ),

    // Vocabulary
    GoRoute(
      path: NavigationManager.vocabularyPath,
      name: NavigationManager.vocabulary,
      builder: (context, state) => const VocabularyScreen(),
      routes: [
        GoRoute(
          path: ':lessonNumber',
          pageBuilder: (context, GoRouterState state) {
            final lessonNumber = state.pathParameters['lessonNumber']!;
            return MaterialPage(
              child: LessonDetailScreen(
                lessonNumber: int.parse(lessonNumber),
              ),
            );
          },
        ),
      ],
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

    // TODO: Thêm các protected routes khác
    // GoRoute(
    //   path: NavigationManager.vocabularyPath,
    //   name: NavigationManager.vocabulary,
    //   builder: (context, state) => const VocabularyScreen(),
    // ),
    // GoRoute(
    //   path: NavigationManager.grammarPath,
    //   name: NavigationManager.grammar,
    //   builder: (context, state) => const GrammarScreen(),
    // ),
    GoRoute(
      path: NavigationManager.settingsPath,
      name: NavigationManager.settings,
      builder: (context, state) => const SettingsScreen(),
    ),
  ];
}
