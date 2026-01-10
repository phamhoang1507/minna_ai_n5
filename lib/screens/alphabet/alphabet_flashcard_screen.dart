import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minna_ai_n5/models/alphabet_progress_model.dart';
import 'package:minna_ai_n5/providers/alphabet_progress_provider.dart';
import 'package:minna_ai_n5/providers/alphabet_provider.dart';
import 'package:minna_ai_n5/providers/streak_provider.dart';
import 'package:minna_ai_n5/utils/app_theme.dart';
import 'package:minna_ai_n5/utils/responsive.dart';
import 'dart:math' as math;

enum AlphabetType { hiragana, katakana }

enum FilterType { all, mastered, notMastered }

enum SwipeDirection { none, left, right }

class AlphabetFlashcardScreen extends ConsumerStatefulWidget {
  final AlphabetType type;

  const AlphabetFlashcardScreen({super.key, required this.type});

  @override
  ConsumerState<AlphabetFlashcardScreen> createState() =>
      _AlphabetFlashcardScreenState();
}

class _AlphabetFlashcardScreenState
    extends ConsumerState<AlphabetFlashcardScreen>
    with TickerProviderStateMixin {
  final _audioPlayer = AudioPlayer();
  int _index = 0;
  bool _streakMarkedToday = false;
  bool _isFlipped = false;
  FilterType _filterType = FilterType.all;
  SwipeDirection _swipeDirection = SwipeDirection.none;

  late AnimationController _flipController;
  late AnimationController _swipeController;
  late Animation<double> _flipAnimation;
  late Animation<Offset> _currentCardSlide;
  late Animation<Offset> _nextCardSlide;
  late Animation<double> _currentCardFade;
  late Animation<double> _nextCardFade;

  @override
  void initState() {
    super.initState();

    /// Đánh dấu streak khi user bắt đầu học
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_streakMarkedToday) {
        ref.read(streakServiceProvider).markStudiedToday();
        _streakMarkedToday = true;
      }
    });
    _flipController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );

    _swipeController = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );

    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOut),
    );

    _setupSwipeAnimations();
  }

  void _setupSwipeAnimations() {
    // Animation cho card hiện tại (trượt ra)
    _currentCardSlide =
        Tween<Offset>(
          begin: Offset.zero,
          end: Offset.zero, // Sẽ update động
        ).animate(
          CurvedAnimation(
            parent: _swipeController,
            curve: Curves.easeInOutCubic,
          ),
        );

    // Animation cho card tiếp theo (trượt vào)
    _nextCardSlide =
        Tween<Offset>(
          begin: Offset.zero, // Sẽ update động
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _swipeController,
            curve: Curves.easeInOutCubic,
          ),
        );

    // Fade out cho card hiện tại
    _currentCardFade = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _swipeController,
        curve: Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    // Fade in cho card tiếp theo
    _nextCardFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _swipeController,
        curve: Interval(0.5, 1.0, curve: Curves.easeIn),
      ),
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _flipController.dispose();
    _swipeController.dispose();
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

  void _nextCard() async {
    setState(() {
      _swipeDirection = SwipeDirection.left;
    });

    // Update animation directions
    _currentCardSlide =
        Tween<Offset>(
          begin: Offset.zero,
          end: Offset(-1.5, 0), // Trượt sang trái
        ).animate(
          CurvedAnimation(
            parent: _swipeController,
            curve: Curves.easeInOutCubic,
          ),
        );

    _nextCardSlide =
        Tween<Offset>(
          begin: Offset(1.5, 0), // Bắt đầu từ bên phải
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _swipeController,
            curve: Curves.easeInOutCubic,
          ),
        );

    await _swipeController.forward();

    setState(() {
      _index++;
      _isFlipped = false;
      _swipeDirection = SwipeDirection.none;
    });

    _flipController.reset();
    _swipeController.reset();
  }

  void _previousCard() async {
    setState(() {
      _swipeDirection = SwipeDirection.right;
    });

    // Update animation directions
    _currentCardSlide =
        Tween<Offset>(
          begin: Offset.zero,
          end: Offset(1.5, 0), // Trượt sang phải
        ).animate(
          CurvedAnimation(
            parent: _swipeController,
            curve: Curves.easeInOutCubic,
          ),
        );

    _nextCardSlide =
        Tween<Offset>(
          begin: Offset(-1.5, 0), // Bắt đầu từ bên trái
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _swipeController,
            curve: Curves.easeInOutCubic,
          ),
        );

    await _swipeController.forward();

    setState(() {
      _index--;
      _isFlipped = false;
      _swipeDirection = SwipeDirection.none;
    });

    _flipController.reset();
    _swipeController.reset();
  }

  void _changeFilter(FilterType newFilter) {
    setState(() {
      _filterType = newFilter;
      _index = 0;
      _isFlipped = false;
    });
    _flipController.reset();
  }

  @override
  Widget build(BuildContext context) {
    final alphabetAsync = widget.type == AlphabetType.hiragana
        ? ref.watch(hiraganaProvider)
        : ref.watch(katakanaProvider);

    final progressMapAsync = widget.type == AlphabetType.hiragana
        ? ref.watch(hiraganaProgressMapProvider)
        : ref.watch(katakanaProgressMapProvider);

    final title = widget.type == AlphabetType.hiragana
        ? 'Hiragana'
        : 'Katakana';
    final gradientColors = widget.type == AlphabetType.hiragana
        ? AppTheme.hiraganaGradient
        : AppTheme.katakanaGradient;

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
          child: alphabetAsync.when(
            data: (allList) {
              return progressMapAsync.when(
                data: (progressMap) {
                  if (allList.isEmpty) {
                    return const Center(child: Text('Không có dữ liệu'));
                  }

                  // Filter list
                  final List filteredList;
                  switch (_filterType) {
                    case FilterType.mastered:
                      filteredList = allList
                          .where(
                            (item) => progressMap[item.id]?.isMastered == true,
                          )
                          .toList();
                      break;
                    case FilterType.notMastered:
                      filteredList = allList
                          .where(
                            (item) => progressMap[item.id]?.isMastered != true,
                          )
                          .toList();
                      break;
                    default:
                      filteredList = allList;
                  }

                  if (filteredList.isEmpty) {
                    return Column(
                      children: [
                        _buildHeader(
                          title,
                          gradientColors,
                          allList.length,
                          progressMap,
                          context,
                        ),
                        Expanded(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.inbox_rounded,
                                  size: R.w(context, 20),
                                  color: Colors.grey[300],
                                ),
                                SizedBox(height: R.h(context, 2)),
                                Text(
                                  _filterType == FilterType.mastered
                                      ? 'Chưa có từ nào được đánh dấu đã nhớ'
                                      : 'Không có từ nào chưa học',
                                  style: TextStyle(
                                    fontSize: R.fs(context, 4),
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  }

                  if (_index >= filteredList.length) {
                    _index = 0;
                  }

                  final item = filteredList[_index];
                  final nextItem = _index < filteredList.length - 1
                      ? filteredList[_index + 1]
                      : null;
                  final prevItem = _index > 0 ? filteredList[_index - 1] : null;

                  final progress = (_index + 1) / filteredList.length;
                  final isMastered = progressMap[item.id]?.isMastered == true;

                  return Column(
                    children: [
                      _buildHeader(
                        title,
                        gradientColors,
                        allList.length,
                        progressMap,
                        context,
                      ),
                      SizedBox(height: R.h(context, 1)),

                      // Flashcard Stack
                      Expanded(
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: R.w(context, 5),
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Next/Previous card (background)
                                if (_swipeDirection != SwipeDirection.none)
                                  AnimatedBuilder(
                                    animation: _nextCardFade,
                                    builder: (context, child) {
                                      final displayItem =
                                          _swipeDirection == SwipeDirection.left
                                          ? nextItem
                                          : prevItem;
                                      if (displayItem == null)
                                        return SizedBox();

                                      final displayMastered =
                                          progressMap[displayItem.id]
                                              ?.isMastered ==
                                          true;

                                      return Opacity(
                                        opacity: _nextCardFade.value,
                                        child: SlideTransition(
                                          position: _nextCardSlide,
                                          child: _buildCard(
                                            displayItem,
                                            gradientColors,
                                            displayMastered,
                                            context,
                                            false,
                                          ),
                                        ),
                                      );
                                    },
                                  ),

                                // Current card (foreground)
                                AnimatedBuilder(
                                  animation:
                                      _swipeDirection != SwipeDirection.none
                                      ? _currentCardFade
                                      : _flipAnimation,
                                  builder: (context, child) {
                                    if (_swipeDirection !=
                                        SwipeDirection.none) {
                                      return Opacity(
                                        opacity: _currentCardFade.value,
                                        child: SlideTransition(
                                          position: _currentCardSlide,
                                          child: _buildCard(
                                            item,
                                            gradientColors,
                                            isMastered,
                                            context,
                                            false,
                                          ),
                                        ),
                                      );
                                    }

                                    return GestureDetector(
                                      onTap: _toggleFlip,
                                      child: _buildCard(
                                        item,
                                        gradientColors,
                                        isMastered,
                                        context,
                                        true,
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: R.h(context, 2)),

                      // Progress indicator
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: R.w(context, 8),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: R.h(context, 0.7),
                            backgroundColor: AppTheme.borderColor,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              gradientColors[0],
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: R.h(context, 0.5)),

                      Text(
                        '${_index + 1} / ${filteredList.length}',
                        style: TextStyle(
                          fontSize: R.fs(context, 3.5),
                          color: AppTheme.secondaryText,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      // Bottom Controls
                      Padding(
                        padding: EdgeInsets.all(R.sp(context, 4)),
                        child: Column(
                          children: [
                            // Audio Button
                            SizedBox(
                              width: double.infinity,
                              height: R.h(context, 7),
                              child: ElevatedButton(
                                onPressed: () async {
                                  await _audioPlayer.setVolume(1.0);
                                  await _audioPlayer.play(
                                    AssetSource(item.audio),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: gradientColors[0],
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    side: BorderSide(
                                      color: gradientColors[0].withOpacity(0.3),
                                      width: 2,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.volume_up_rounded,
                                      size: R.w(context, 7),
                                    ),
                                    SizedBox(width: R.w(context, 3)),
                                    Text(
                                      'Nghe phát âm',
                                      style: TextStyle(
                                        fontSize: R.fs(context, 4.5),
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            SizedBox(height: R.h(context, 1.5)),

                            // Mastery Buttons
                            Row(
                              children: [
                                Expanded(
                                  child: SizedBox(
                                    height: R.h(context, 7),
                                    child: ElevatedButton(
                                      onPressed: () {
                                        _saveProgress(item.id, false);
                                        if (_index < filteredList.length - 1)
                                          _nextCard();
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppTheme.errorColor,
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.close_rounded,
                                            size: R.w(context, 6),
                                          ),
                                          SizedBox(height: 2),
                                          Text(
                                            'Chưa nhớ',
                                            style: TextStyle(
                                              fontSize: R.fs(context, 3),
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: R.w(context, 3)),
                                Expanded(
                                  child: SizedBox(
                                    height: R.h(context, 7),
                                    child: ElevatedButton(
                                      onPressed: () {
                                        _saveProgress(item.id, true);
                                        if (_index < filteredList.length - 1)
                                          _nextCard();
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppTheme.successColor,
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.check_rounded,
                                            size: R.w(context, 6),
                                          ),
                                          SizedBox(height: 2),
                                          Text(
                                            'Đã nhớ',
                                            style: TextStyle(
                                              fontSize: R.fs(context, 3),
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: R.h(context, 1.5)),

                            // Navigation
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  onPressed: _index > 0 ? _previousCard : null,
                                  icon: Icon(Icons.chevron_left_rounded),
                                  iconSize: R.w(context, 8),
                                  style: IconButton.styleFrom(
                                    backgroundColor: _index > 0
                                        ? gradientColors[0].withOpacity(0.1)
                                        : Colors.grey.withOpacity(0.1),
                                    foregroundColor: _index > 0
                                        ? gradientColors[0]
                                        : Colors.grey,
                                  ),
                                ),
                                SizedBox(width: R.w(context, 4)),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: R.w(context, 4),
                                    vertical: R.h(context, 1),
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.backgroundColor,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    'Tap để lật thẻ',
                                    style: TextStyle(
                                      fontSize: R.fs(context, 3.2),
                                      color: AppTheme.secondaryText,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                SizedBox(width: R.w(context, 4)),
                                IconButton(
                                  onPressed: _index < filteredList.length - 1
                                      ? _nextCard
                                      : null,
                                  icon: Icon(Icons.chevron_right_rounded),
                                  iconSize: R.w(context, 8),
                                  style: IconButton.styleFrom(
                                    backgroundColor:
                                        _index < filteredList.length - 1
                                        ? gradientColors[0].withOpacity(0.1)
                                        : Colors.grey.withOpacity(0.1),
                                    foregroundColor:
                                        _index < filteredList.length - 1
                                        ? gradientColors[0]
                                        : Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(child: Text('Lỗi: $error')),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(child: Text('Lỗi: $error')),
          ),
        ),
      ),
    );
  }

  Widget _buildCard(
    item,
    List<Color> gradientColors,
    bool isMastered,
    BuildContext context,
    bool enableFlip,
  ) {
    if (!enableFlip) {
      return _buildFrontCard(item, gradientColors, isMastered, context);
    }

    return AnimatedBuilder(
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
              ? _buildFrontCard(item, gradientColors, isMastered, context)
              : Transform(
                  transform: Matrix4.identity()..rotateY(math.pi),
                  alignment: Alignment.center,
                  child: _buildBackCard(
                    item,
                    gradientColors,
                    isMastered,
                    context,
                  ),
                ),
        );
      },
    );
  }

  // Keep all your existing _buildHeader, _buildFilterTab, _buildFrontCard, _buildBackCard, _saveProgress methods exactly the same...

  Widget _buildHeader(
    String title,
    List<Color> gradientColors,
    int totalCount,
    Map<String, AlphabetProgress> progressMap,
    BuildContext context,
  ) {
    final masteredCount = progressMap.values.where((p) => p.isMastered).length;
    final notMasteredCount = totalCount - masteredCount;

    return Padding(
      padding: EdgeInsets.all(R.sp(context, 4)),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: Icon(
                  Icons.arrow_back_rounded,
                  color: gradientColors[0],
                  size: R.w(context, 7),
                ),
                onPressed: () => Navigator.pop(context),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: R.fs(context, 7),
                        fontWeight: FontWeight.w900,
                        color: AppTheme.primaryText,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      '$masteredCount đã nhớ / $totalCount',
                      style: TextStyle(
                        fontSize: R.fs(context, 3.5),
                        color: AppTheme.secondaryText,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: R.h(context, 2)),
          Container(
            height: R.h(context, 6),
            decoration: BoxDecoration(
              color: AppTheme.backgroundColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                _buildFilterTab(
                  'Tất cả',
                  totalCount,
                  FilterType.all,
                  gradientColors,
                  context,
                ),
                _buildFilterTab(
                  'Đã nhớ',
                  masteredCount,
                  FilterType.mastered,
                  gradientColors,
                  context,
                ),
                _buildFilterTab(
                  'Chưa nhớ',
                  notMasteredCount,
                  FilterType.notMastered,
                  gradientColors,
                  context,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTab(
    String label,
    int count,
    FilterType type,
    List<Color> gradientColors,
    BuildContext context,
  ) {
    final isSelected = _filterType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => _changeFilter(type),
        child: AnimatedContainer(
          duration: Duration(milliseconds: 200),
          margin: EdgeInsets.all(R.sp(context, 1)),
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(colors: gradientColors)
                : null,
            color: isSelected ? null : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: R.fs(context, 3.2),
                    fontWeight: FontWeight.w700,
                    color: isSelected ? Colors.white : AppTheme.secondaryText,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  count.toString(),
                  style: TextStyle(
                    fontSize: R.fs(context, 4),
                    fontWeight: FontWeight.w900,
                    color: isSelected ? Colors.white : gradientColors[0],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFrontCard(
    item,
    List<Color> gradientColors,
    bool isMastered,
    BuildContext context,
  ) {
    return Container(
      width: double.infinity,
      height: R.h(context, 50),
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
          if (isMastered)
            Positioned(
              left: R.sp(context, 4),
              top: R.sp(context, 4),
              child: Container(
                padding: EdgeInsets.all(R.sp(context, 3)),
                decoration: BoxDecoration(
                  color: AppTheme.successColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.successColor.withOpacity(0.4),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: R.w(context, 6),
                ),
              ),
            ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  item.char,
                  style: TextStyle(
                    fontSize: R.fs(context, 35),
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    height: 1.0,
                  ),
                ),
                SizedBox(height: R.h(context, 2)),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: R.w(context, 6),
                    vertical: R.h(context, 1),
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Tap để xem romaji',
                    style: TextStyle(
                      fontSize: R.fs(context, 3.5),
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackCard(
    item,
    List<Color> gradientColors,
    bool isMastered,
    BuildContext context,
  ) {
    return Container(
      width: double.infinity,
      height: R.h(context, 50),
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
          if (isMastered)
            Positioned(
              left: R.sp(context, 4),
              top: R.sp(context, 4),
              child: Container(
                padding: EdgeInsets.all(R.sp(context, 3)),
                decoration: BoxDecoration(
                  color: AppTheme.successColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.successColor.withOpacity(0.4),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: R.w(context, 6),
                ),
              ),
            ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: R.w(context, 6),
                    vertical: R.h(context, 1.5),
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: gradientColors),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Romaji',
                    style: TextStyle(
                      fontSize: R.fs(context, 4),
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                SizedBox(height: R.h(context, 3)),
                Text(
                  item.romaji.toUpperCase(),
                  style: TextStyle(
                    fontSize: R.fs(context, 16),
                    fontWeight: FontWeight.w900,
                    foreground: Paint()
                      ..shader = LinearGradient(
                        colors: gradientColors,
                      ).createShader(Rect.fromLTWH(0, 0, 200, 70)),
                    letterSpacing: 2,
                  ),
                ),
                SizedBox(height: R.h(context, 2)),
                Text(
                  item.char,
                  style: TextStyle(
                    fontSize: R.fs(context, 12),
                    color: Color(0xFFCBD5E0),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _saveProgress(String alphabetId, bool isMastered) {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;
    final service = ref.read(alphabetProgressServiceProvider);
    service.save(
      userId: userId,
      progress: AlphabetProgress(
        alphabetId: alphabetId,
        isMastered: isMastered,
        updatedAt: DateTime.now(),
      ),
    );
  }
}
