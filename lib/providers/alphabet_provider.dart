import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minna_ai_n5/repository/alphabet_repository.dart';
import '../models/alphabet_model.dart';

final alphabetRepositoryProvider =
    Provider((ref) => AlphabetRepository());

final hiraganaProvider =
    FutureProvider<List<AlphabetModel>>((ref) {
  return ref.read(alphabetRepositoryProvider).loadHiragana();
});

final katakanaProvider =
    FutureProvider<List<AlphabetModel>>((ref) {
  return ref.read(alphabetRepositoryProvider).loadKatakana();
});
