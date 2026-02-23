import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VocabImporter {
  // static const String audioBaseUrl = 'https://cdn.minnaai5.com';

  static Future<void> importLesson0() async {
    for (int a = 0; a <= 25; a++) {
      try {
        // 1️⃣ Load JSON
        String b = '$a';
        if (a < 10 && a!=0) {
          b = '0$a';
        }
        final jsonString = await rootBundle.loadString(
          'assets/jsons/vocabulary/lesson_$b.json',
        );

        final Map<String, dynamic> data = json.decode(jsonString);
        final int lesson = data['lesson'];
        final String title = data['title'];
        final List words = data['words'];

        final firestore = FirebaseFirestore.instance;

        // 2️⃣ Create lesson document
        final lessonRef = firestore
            .collection('vocabularies')
            .doc('lesson_$lesson');

        await lessonRef.set({
          'lesson': lesson,
          'title': title,
          'total_words': words.length,
          'updated_at': FieldValue.serverTimestamp(),
        });

        // 3️⃣ Import words subcollection
        for (final word in words) {
          final wordData = {
            'id': word['id'],
            'kana': word['kana'],
            'kanji': word['kanji'] == '' ? null : word['kanji'],
            'romaji': word['romaji'],

            'meaning_en': word['meaning_en'],
            'meaning_vi': word['meaning_vi'],

            'type_en': word['type_en'],
            'type_vi': word['type_vi'],

            'audio_url': word['audio'],
          };

          await lessonRef.collection('words').doc(word['id']).set(wordData);

          print('✅ Imported ${word['id']}');
        }

        print('🎉 IMPORT LESSON $lesson DONE');
      } catch (e) {
        print('❌ Import error: $e');
      }
    }
    print('🎉 ALL 26 LESSONS IMPORTED SUCCESSFULLY');
  }
}
