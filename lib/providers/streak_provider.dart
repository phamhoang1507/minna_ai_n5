import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/streak/streak_service.dart';

final streakServiceProvider = Provider<StreakService>((ref) {
  return StreakService();
});
