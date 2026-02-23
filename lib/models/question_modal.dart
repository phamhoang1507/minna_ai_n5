class QuizQuestion {
  final String question;
  final List<String> options;
  final int correctIndex;
  final QuestionType type;
  final String? audioUrl;

  QuizQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.type,
    this.audioUrl,
  });
}

enum QuestionType { jpToVi, viToJp, audio }
