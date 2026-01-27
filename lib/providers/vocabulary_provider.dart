import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:minna_ai_n5/models/vocabulary_word.dart';

final vocabularyLessonProvider =
    FutureProvider.family<List<VocabularyWord>, int>((ref, lessonNumber) async {
      try {
        print('🔥 Load lesson $lessonNumber from Firestore');

        final snapshot = await FirebaseFirestore.instance
            .collection('vocabularies')
            .doc('lesson_$lessonNumber')
            .collection('words')
            .orderBy('id')
            .get();

        final words = snapshot.docs
            .map((doc) => VocabularyWord.fromJson(doc.data()))
            .toList();

        print('✅ Loaded ${words.length} words');
        return words;
      } catch (e, st) {
        print('❌ Error loading lesson $lessonNumber');
        print(e);
        print(st);
        return [];
      }
    });
