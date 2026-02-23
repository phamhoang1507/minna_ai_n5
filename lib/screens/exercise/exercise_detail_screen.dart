import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:minna_ai_n5/models/question_modal.dart';
import 'package:minna_ai_n5/providers/exercise_provider.dart';

class ExerciseDetailScreen extends StatefulWidget {
  final List<int> exerciseId;

  const ExerciseDetailScreen({super.key, required this.exerciseId});

  @override
  State<ExerciseDetailScreen> createState() => _ExerciseDetailScreenState();
}

class _ExerciseDetailScreenState extends State<ExerciseDetailScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();

  int currentIndex = 0;
  int? selectedIndex;
  int correctCount = 0;

  List<QuizQuestion> questions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadQuestions();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> loadQuestions() async {
    final data = await fetchRandomQuiz(widget.exerciseId);

    if (!mounted) return;

    setState(() {
      questions = data;
      isLoading = false;
    });
  }

  Future<void> playAudio(String url) async {
    await _audioPlayer.stop();
    await _audioPlayer.play(UrlSource(url));
  }

  void selectAnswer(int index) {
    if (selectedIndex != null) return;

    final isCorrect = index == questions[currentIndex].correctIndex;

    setState(() {
      selectedIndex = index;
      if (isCorrect) correctCount++;
    });

    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;

      if (currentIndex < questions.length - 1) {
        setState(() {
          currentIndex++;
          selectedIndex = null;
        });
      } else {
        showCompletedDialog();
      }
    });
  }

  void showCompletedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("🎉 Hoàn thành!"),
        content: Text(
          "Bạn đúng $correctCount / ${questions.length} câu",
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text("Quay lại"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (questions.isEmpty) {
      return const Scaffold(body: Center(child: Text("Không có dữ liệu")));
    }

    final question = questions[currentIndex];
    final progress = (currentIndex + 1) / questions.length;

    final gradientColors = const [Color(0xFF43E97B), Color(0xFF38F9D7)];

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              gradientColors[0].withOpacity(0.1),
              gradientColors[1].withOpacity(0.05),
              Colors.white,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                /// HEADER
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: gradientColors[0]),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: gradientColors),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "${currentIndex + 1}/${questions.length}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                /// PROGRESS
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation(gradientColors[0]),
                  ),
                ),

                const SizedBox(height: 30),

                /// QUESTION CARD
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: gradientColors),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: gradientColors[0].withOpacity(0.4),
                        blurRadius: 25,
                        offset: const Offset(0, 15),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        question.question,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      /// AUDIO BUTTON
                      if (question.type == QuestionType.audio &&
                          question.audioUrl != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: IconButton(
                            icon: const Icon(
                              Icons.volume_up,
                              size: 36,
                              color: Colors.white,
                            ),
                            onPressed: () => playAudio(question.audioUrl!),
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                /// OPTIONS
                Expanded(
                  child: ListView.builder(
                    itemCount: question.options.length,
                    itemBuilder: (context, i) {
                      final isSelected = selectedIndex == i;
                      final isCorrect = i == question.correctIndex;

                      Color? bgColor;

                      if (selectedIndex != null) {
                        if (isCorrect) {
                          bgColor = Colors.green;
                        } else if (isSelected) {
                          bgColor = Colors.red;
                        }
                      }

                      return GestureDetector(
                        onTap: () => selectAnswer(i),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: bgColor ?? Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color:
                                  bgColor ?? gradientColors[0].withOpacity(0.4),
                              width: 2,
                            ),
                          ),
                          child: Text(
                            question.options[i],
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: bgColor != null
                                  ? Colors.white
                                  : Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
