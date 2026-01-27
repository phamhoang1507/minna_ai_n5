import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minna_ai_n5/models/vocabulary_word.dart';
import 'package:minna_ai_n5/providers/vocabulary_provider.dart';
import 'package:minna_ai_n5/utils/app_theme.dart';
import 'package:minna_ai_n5/utils/responsive.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:math' as math;

class LessonDetailScreen extends ConsumerStatefulWidget {
  final int lessonNumber;
  const LessonDetailScreen({super.key, required this.lessonNumber});

  @override
  ConsumerState<LessonDetailScreen> createState() => _LessonDetailScreenState();
}

class _LessonDetailScreenState extends ConsumerState<LessonDetailScreen>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  bool _isFlipped = false;
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlayingAudio = false;

  @override
  void initState() {
    super.initState();

    _flipController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );

    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOut),
    );

    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _isPlayingAudio = state == PlayerState.playing;
        });
      }
    });
  }

  @override
  void dispose() {
    _flipController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _toggleFlip() {
    if (_isFlipped) {
      _flipController.reverse();
    } else {
      _flipController.forward();
    }
    setState(() => _isFlipped = !_isFlipped);
  }

  void _nextCard(int maxLength) {
    if (_currentIndex < maxLength - 1) {
      setState(() {
        _currentIndex++;
        _isFlipped = false;
      });
      _flipController.reset();
      _audioPlayer.stop();
    }
  }

  void _previousCard() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _isFlipped = false;
      });
      _flipController.reset();
      _audioPlayer.stop();
    }
  }

  Future<void> _playAudio(String audioUrl) async {
    try {
      await _audioPlayer.setVolume(1.0);

      if (_isPlayingAudio) {
        await _audioPlayer.stop();
      } else {
        await _audioPlayer.play(UrlSource(audioUrl));
      }
    } catch (e) {
      print('Error playing audio: $e');
    }
  }

  Color _getGradientColor1() {
    if (widget.lessonNumber == 0) return Color(0xFFFFD93D);
    final colors = [
      Color(0xFFFF6B6B),
      Color(0xFF4FACFE),
      Color(0xFF43E97B),
      Color(0xFFFA709A),
      Color(0xFFFEE140),
      Color(0xFF30CFD0),
      Color(0xFFA8EDEA),
      Color(0xFFFFD93D),
      Color(0xFF667EEA),
    ];
    return colors[widget.lessonNumber % colors.length];
  }

  Color _getGradientColor2() {
    if (widget.lessonNumber == 0) return Color(0xFFFF8A00);
    final colors = [
      Color(0xFFFF8E53),
      Color(0xFF00F2FE),
      Color(0xFF38F9D7),
      Color(0xFFFEE140),
      Color(0xFFFA709A),
      Color(0xFF330867),
      Color(0xFFFED6E3),
      Color(0xFFFF8A00),
      Color(0xFF764BA2),
    ];
    return colors[widget.lessonNumber % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final vocabularyAsync = ref.watch(
      vocabularyLessonProvider(widget.lessonNumber),
    );

    final gradientColors = [_getGradientColor1(), _getGradientColor2()];
    final isPreLesson = widget.lessonNumber == 0;
    final lessonTitle = isPreLesson ? 'Pre' : 'Bài ${widget.lessonNumber}';

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              gradientColors[0].withOpacity(0.1),
              gradientColors[1].withOpacity(0.05),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: vocabularyAsync.when(
            data: (words) {
              if (words.isEmpty) {
                return Center(
                  child: Text(
                    'Không có từ vựng',
                    style: TextStyle(
                      fontSize: R.fs(context, 4),
                      color: AppTheme.secondaryText,
                    ),
                  ),
                );
              }

              final word = words[_currentIndex];
              final progress = (_currentIndex + 1) / words.length;

              return Column(
                children: [
                  // Header
                  _buildHeader(
                    context,
                    lessonTitle,
                    words.length,
                    progress,
                    gradientColors,
                  ),

                  SizedBox(height: R.h(context, 2)),

                  // Flashcard
                  Expanded(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: R.w(context, 5),
                        ),
                        child: GestureDetector(
                          onTap: _toggleFlip,
                          child: AnimatedBuilder(
                            animation: _flipAnimation,
                            builder: (context, child) {
                              final angle = _flipAnimation.value * math.pi;
                              final transform = Matrix4.identity()
                                ..setEntry(3, 2, 0.001)
                                ..rotateY(angle);

                              return Transform(
                                transform: transform,
                                alignment: Alignment.center,
                                child: angle < math.pi / 2
                                    ? _buildFrontCard(
                                        word,
                                        gradientColors,
                                        context,
                                      )
                                    : Transform(
                                        transform: Matrix4.identity()
                                          ..rotateY(math.pi),
                                        alignment: Alignment.center,
                                        child: _buildBackCard(
                                          word,
                                          gradientColors,
                                          context,
                                        ),
                                      ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Navigation
                  _buildNavigation(context, gradientColors, words.length),
                ],
              );
            },
            loading: () => Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(gradientColors[0]),
              ),
            ),
            error: (error, stack) => Center(
              child: Padding(
                padding: EdgeInsets.all(R.sp(context, 4)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      size: R.w(context, 15),
                      color: Colors.red.shade300,
                    ),
                    SizedBox(height: R.h(context, 2)),
                    Text(
                      'Đã có lỗi xảy ra',
                      style: TextStyle(
                        fontSize: R.fs(context, 5),
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryText,
                      ),
                    ),
                    SizedBox(height: R.h(context, 1)),
                    Text(
                      '$error',
                      style: TextStyle(
                        fontSize: R.fs(context, 3.5),
                        color: AppTheme.secondaryText,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: R.h(context, 3)),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: gradientColors[0],
                        padding: EdgeInsets.symmetric(
                          horizontal: R.w(context, 8),
                          vertical: R.h(context, 1.5),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Quay lại',
                        style: TextStyle(
                          fontSize: R.fs(context, 4),
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFrontCard(
    VocabularyWord word,
    List<Color> gradientColors,
    BuildContext context,
  ) {
    Locale locale = Localizations.localeOf(context);
    return Container(
      width: double.infinity,
      height: R.h(context, 60),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: gradientColors[0].withOpacity(0.4),
            blurRadius: 30,
            offset: Offset(0, 15),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            right: -50,
            top: -50,
            child: Container(
              width: R.w(context, 50),
              height: R.w(context, 50),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          Positioned(
            left: -30,
            bottom: -30,
            child: Container(
              width: R.w(context, 40),
              height: R.w(context, 40),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),

          // Audio button
          Positioned(
            top: R.h(context, 2),
            right: R.w(context, 4),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(50),
                onTap: () => _playAudio(word.audio ?? ''),
                child: Container(
                  padding: EdgeInsets.all(R.sp(context, 3)),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    _isPlayingAudio
                        ? Icons.pause_rounded
                        : Icons.volume_up_rounded,
                    color: Colors.white,
                    size: R.w(context, 6),
                  ),
                ),
              ),
            ),
          ),

          // Content
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: R.w(context, 6)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Type badge
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: R.w(context, 5),
                      vertical: R.h(context, 1),
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.4),
                        width: 2,
                      ),
                    ),
                    child: Text(
                      locale.languageCode == 'en' ? word.typeEn : word.typeVi,
                      style: TextStyle(
                        fontSize: R.fs(context, 4),
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 1,
                      ),
                    ),
                  ),

                  SizedBox(height: R.h(context, 4)),

                  // Kana
                  Text(
                    word.kana,
                    style: TextStyle(
                      fontSize: R.fs(context, 16),
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      height: 1.2,
                      letterSpacing: 1,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: R.h(context, 2)),

                  // Kanji
                  if (word.kanji!.isNotEmpty && word.kanji != word.kana)
                    Text(
                      word.kanji!,
                      style: TextStyle(
                        fontSize: R.fs(context, 6),
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withOpacity(0.9),
                        letterSpacing: 2,
                      ),
                      textAlign: TextAlign.center,
                    ),

                  SizedBox(height: R.h(context, 4)),

                  // Hint
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: R.w(context, 6),
                      vertical: R.h(context, 1.2),
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.touch_app_rounded,
                          color: Colors.white.withOpacity(0.9),
                          size: R.w(context, 4.5),
                        ),
                        SizedBox(width: R.w(context, 2)),
                        Text(
                          'Nhấn để xem nghĩa',
                          style: TextStyle(
                            fontSize: R.fs(context, 3.5),
                            color: Colors.white.withOpacity(0.9),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackCard(
    VocabularyWord word,
    List<Color> gradientColors,
    BuildContext context,
  ) {
    Locale locale = Localizations.localeOf(context);
    final hasKanji = word.kanji!.isNotEmpty && word.kanji != word.kana;

    return Container(
      width: double.infinity,
      height: R.h(context, 60),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: gradientColors[0].withOpacity(0.3), width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 30,
            offset: Offset(0, 15),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative elements
          Positioned(
            right: -30,
            top: -30,
            child: Container(
              width: R.w(context, 40),
              height: R.w(context, 40),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: gradientColors[0].withOpacity(0.05),
              ),
            ),
          ),

          // Audio button
          Positioned(
            top: R.h(context, 2),
            right: R.w(context, 4),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(50),
                onTap: () => _playAudio(word.audio ?? ''),
                child: Container(
                  padding: EdgeInsets.all(R.sp(context, 3)),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: gradientColors),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: gradientColors[0].withOpacity(0.3),
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    _isPlayingAudio
                        ? Icons.pause_rounded
                        : Icons.volume_up_rounded,
                    color: Colors.white,
                    size: R.w(context, 6),
                  ),
                ),
              ),
            ),
          ),

          // Content
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: R.w(context, 6),
                vertical: R.h(context, 4),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Type badge
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: R.w(context, 5),
                      vertical: R.h(context, 1),
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          gradientColors[0].withOpacity(0.15),
                          gradientColors[1].withOpacity(0.15),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: gradientColors[0].withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: Text(
                      locale.languageCode == 'en' ? word.typeEn : word.typeVi,
                      style: TextStyle(
                        fontSize: R.fs(context, 4),
                        fontWeight: FontWeight.w700,
                        color: gradientColors[0],
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),

                  SizedBox(height: R.h(context, 3)),

                  // Romaji
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: R.w(context, 6),
                      vertical: R.h(context, 1.5),
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: gradientColors),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: gradientColors[0].withOpacity(0.3),
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Text(
                      word.romaji,
                      style: TextStyle(
                        fontSize: R.fs(context, 6),
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),

                  SizedBox(height: R.h(context, 3)),

                  // Meaning
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: R.w(context, 4)),
                    child: Text(
                      locale.languageCode == 'en'
                          ? word.meaningEn
                          : word.meaningVi,
                      style: TextStyle(
                        fontSize: R.fs(context, 7.5),
                        fontWeight: FontWeight.w900,
                        foreground: Paint()
                          ..shader = LinearGradient(
                            colors: gradientColors,
                          ).createShader(Rect.fromLTWH(0, 0, 200, 70)),
                        letterSpacing: -0.5,
                        height: 1.2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  SizedBox(height: R.h(context, 3)),

                  // Kana and Kanji separated
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: R.w(context, 5),
                      vertical: R.h(context, 2),
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.backgroundColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: gradientColors[0].withOpacity(0.2),
                        width: 2,
                      ),
                    ),
                    child: Column(
                      children: [
                        // Kana
                        Text(
                          word.kana,
                          style: TextStyle(
                            fontSize: R.fs(context, 5.5),
                            color: AppTheme.primaryText,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        // Kanji (if different)
                        if (hasKanji) ...[
                          SizedBox(height: R.h(context, 1)),
                          Container(
                            height: 1,
                            width: R.w(context, 20),
                            color: gradientColors[0].withOpacity(0.2),
                          ),
                          SizedBox(height: R.h(context, 1)),
                          Text(
                            word.kanji!,
                            style: TextStyle(
                              fontSize: R.fs(context, 5.5),
                              color: AppTheme.primaryText,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    String lessonTitle,
    int length,
    double progress,
    List<Color> gradientColors,
  ) {
    return Padding(
      padding: EdgeInsets.all(R.sp(context, 4)),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.arrow_back_rounded,
                    color: gradientColors[0],
                    size: R.w(context, 6),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              SizedBox(width: R.w(context, 3)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lessonTitle,
                      style: TextStyle(
                        fontSize: R.fs(context, 6),
                        fontWeight: FontWeight.w900,
                        color: AppTheme.primaryText,
                        letterSpacing: -0.5,
                      ),
                    ),
                    SizedBox(height: R.h(context, 0.5)),
                    Text(
                      '$length từ vựng',
                      style: TextStyle(
                        fontSize: R.fs(context, 3.5),
                        color: AppTheme.secondaryText,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: R.w(context, 4.5),
                  vertical: R.h(context, 1.2),
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: gradientColors),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: gradientColors[0].withOpacity(0.3),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  '${_currentIndex + 1}/$length',
                  style: TextStyle(
                    fontSize: R.fs(context, 4),
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: R.h(context, 2)),
          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: R.h(context, 1.2),
              backgroundColor: AppTheme.borderColor.withOpacity(0.3),
              valueColor: AlwaysStoppedAnimation<Color>(gradientColors[0]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigation(
    BuildContext context,
    List<Color> gradientColors,
    int length,
  ) {
    return Padding(
      padding: EdgeInsets.all(R.sp(context, 4)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Previous button
          Expanded(
            child: Container(
              height: R.h(context, 7),
              decoration: BoxDecoration(
                gradient: _currentIndex > 0
                    ? LinearGradient(colors: gradientColors)
                    : null,
                color: _currentIndex > 0 ? null : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(20),
                boxShadow: _currentIndex > 0
                    ? [
                        BoxShadow(
                          color: gradientColors[0].withOpacity(0.3),
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: _currentIndex > 0 ? _previousCard : null,
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chevron_left_rounded,
                          color: _currentIndex > 0 ? Colors.white : Colors.grey,
                          size: R.w(context, 7),
                        ),
                        SizedBox(width: R.w(context, 1)),
                        Text(
                          'Trước',
                          style: TextStyle(
                            fontSize: R.fs(context, 4.5),
                            fontWeight: FontWeight.w700,
                            color: _currentIndex > 0
                                ? Colors.white
                                : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          SizedBox(width: R.w(context, 3)),

          // Next button
          Expanded(
            child: Container(
              height: R.h(context, 7),
              decoration: BoxDecoration(
                gradient: _currentIndex < length - 1
                    ? LinearGradient(colors: gradientColors)
                    : null,
                color: _currentIndex < length - 1 ? null : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(20),
                boxShadow: _currentIndex < length - 1
                    ? [
                        BoxShadow(
                          color: gradientColors[0].withOpacity(0.3),
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: _currentIndex < length - 1
                      ? () => _nextCard(length)
                      : null,
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Tiếp',
                          style: TextStyle(
                            fontSize: R.fs(context, 4.5),
                            fontWeight: FontWeight.w700,
                            color: _currentIndex < length - 1
                                ? Colors.white
                                : Colors.grey,
                          ),
                        ),
                        SizedBox(width: R.w(context, 1)),
                        Icon(
                          Icons.chevron_right_rounded,
                          color: _currentIndex < length - 1
                              ? Colors.white
                              : Colors.grey,
                          size: R.w(context, 7),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
