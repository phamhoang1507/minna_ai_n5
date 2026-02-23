import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:minna_ai_n5/models/question_modal.dart';
import 'package:minna_ai_n5/models/vocabulary_word.dart';

Future<List<QuizQuestion>> fetchRandomQuiz(List<int> lessonNumber) async {
  late List<VocabularyWord> allWords = [];
  for (var i = 0; i < lessonNumber.length; i++) {
    final snapshot = await FirebaseFirestore.instance
        .collection('vocabularies')
        .doc('lesson_${lessonNumber[i]}')
        .collection('words')
        .get();
    final words = snapshot.docs
        .map((doc) => VocabularyWord.fromMap(doc.data()))
        .toList();
    allWords.addAll(words);
  }

  allWords.shuffle();
  final random = Random();

  List<QuizQuestion> questions = [];

  for (int i = 0; i < allWords.length; i++) {
    final correctWord = allWords[i];

    // random 3 đáp án sai
    List<VocabularyWord> wrongOptions = [];

    while (wrongOptions.length < 3) {
      final candidate = allWords[random.nextInt(allWords.length)];
      if (candidate.id != correctWord.id && !wrongOptions.contains(candidate)) {
        wrongOptions.add(candidate);
      }
    }

    // chọn random loại câu hỏi
    final questionType = QuestionType.values[random.nextInt(3)];

    late List<String> options;
    late int correctIndex;
    late String questionText;
    String? audioUrl;

    switch (questionType) {
      /// JP → VI
      case QuestionType.jpToVi:
        options = [
          correctWord.meaningVi,
          ...wrongOptions.map((e) => e.meaningVi),
        ];
        options.shuffle();
        correctIndex = options.indexOf(correctWord.meaningVi);

        questionText = "Từ '${correctWord.kana}' nghĩa là gì?";
        break;

      /// VI → JP
      case QuestionType.viToJp:
        options = [correctWord.kana, ...wrongOptions.map((e) => e.kana)];
        options.shuffle();
        correctIndex = options.indexOf(correctWord.kana);

        questionText = "'${correctWord.meaningVi}' tiếng Nhật là gì?";
        break;

      /// NGHE
      case QuestionType.audio:
        options = [
          correctWord.meaningVi,
          ...wrongOptions.map((e) => e.meaningVi),
        ];
        options.shuffle();
        correctIndex = options.indexOf(correctWord.meaningVi);

        questionText = "Nghe và chọn đáp án đúng";
        audioUrl = correctWord.audio;
        break;
    }

    questions.add(
      QuizQuestion(
        question: questionText,
        options: options,
        correctIndex: correctIndex,
        type: questionType,
        audioUrl: audioUrl,
      ),
    );
  }

  return questions;
}
