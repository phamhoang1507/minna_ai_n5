import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minna_ai_n5/core/service/streak_service.dart';

final streakServiceProvider = Provider<StreakService>((ref) {
  return StreakService();
});
