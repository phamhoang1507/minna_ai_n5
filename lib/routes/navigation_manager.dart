// navigation_manager.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NavigationManager {
  // Singleton
  static final NavigationManager _instance = NavigationManager._internal();
  factory NavigationManager() => _instance;
  NavigationManager._internal();

  // System
  static const String splash = 'splash';
  static const String splashPath = '/splash';

  // Auth
  static const String welcome = 'welcome';
  static const String welcomePath = '/welcome';

  static const String login = 'login';
  static const String loginPath = '/login';

  static const String register = 'register';
  static const String registerPath = '/register';

  static const String forgetPassword = 'forgetPassword';
  static const String forgetPasswordPath = '/forget-password';

  // Protected
  static const String home = 'home';
  static const String homePath = '/home';

  static const String alphabet = 'alphabet';
  static const String alphabetPath = '/alphabet';

  static const String vocabulary = 'vocabulary';
  static const String vocabularyPath = '/vocabulary';
  static const String vocabularyDetailPath = '/vocabulary/:id';

  static const String ai = 'ai';
  static const String aiPath = '/ai';
  
  static const String hiragana = 'hiragana';
  static const String alphabetHiraganaPath = '/alphabet/hiragana';

  static const String katakana = 'katakana';
  static const String alphabetKatakanaPath = '/alphabet/katakana';

  static const String settings = 'settings';
  static const String settingsPath = '/settings';

  // Navigation methods
  void toHome(BuildContext context) => context.go(homePath);
  void toAlphabetMenu(BuildContext context) => context.push(alphabetPath);
  void toVocabularytMenu(BuildContext context) => context.push(vocabularyPath);
  void toAiChat(BuildContext context) => context.push(aiPath);
  void toVocabularytDetail(BuildContext context, int lessonNumber) => context.push('/vocabulary/$lessonNumber');
  void toAlphabetHiragana(BuildContext context) =>
      context.push(alphabetHiraganaPath);
  void toAlphabetKatakana(BuildContext context) =>
      context.push(alphabetKatakanaPath);
  void toLogin(BuildContext context) => context.go(loginPath);
  void toWelcome(BuildContext context) => context.go(welcomePath);
  void toSettings(BuildContext context) => context.go(settingsPath);
}

// Extension để dùng dễ dàng: context.nav.toHome()
extension NavigationManagerExtension on BuildContext {
  NavigationManager get nav => NavigationManager();
}
