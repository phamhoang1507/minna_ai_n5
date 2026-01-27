import 'package:flutter/material.dart';
import 'package:minna_ai_n5/routes/navigation_manager.dart';
import 'package:minna_ai_n5/utils/app_theme.dart';
import 'package:minna_ai_n5/utils/responsive.dart';
import 'lesson_detail_screen.dart';

class VocabularyScreen extends StatefulWidget {
  const VocabularyScreen({super.key});

  @override
  State<VocabularyScreen> createState() => _VocabularyScreenState();
}

class _VocabularyScreenState extends State<VocabularyScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _headerController;
  late Animation<double> _headerSlide;
  late Animation<double> _headerFade;

  @override
  void initState() {
    super.initState();
    _headerController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );

    _headerSlide = Tween<double>(begin: -50, end: 0).animate(
      CurvedAnimation(parent: _headerController, curve: Curves.easeOut),
    );

    _headerFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _headerController, curve: Curves.easeOut),
    );

    _headerController.forward();
  }

  @override
  void dispose() {
    _headerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF093FB), Color(0xFFF5576C), Color(0xFFFF8A00)],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Animated Header
              AnimatedBuilder(
                animation: _headerController,
                builder: (context, child) {
                  return Opacity(
                    opacity: _headerFade.value,
                    child: Transform.translate(
                      offset: Offset(0, _headerSlide.value),
                      child: child,
                    ),
                  );
                },
                child: _buildHeader(context),
              ),

              // Lesson Cards
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                    child: ListView.builder(
                      padding: EdgeInsets.only(
                        top: R.h(context, 3),
                        left: R.w(context, 5),
                        right: R.w(context, 5),
                        bottom: R.h(context, 2),
                      ),
                      physics: const BouncingScrollPhysics(),
                      itemCount: 26,
                      itemBuilder: (context, index) {
                        return _LessonCard(
                          lessonNumber: index,
                          delay: index * 40,
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(R.sp(context, 6)),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.arrow_back_rounded,
                    color: Colors.white,
                    size: R.w(context, 7),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              Spacer(),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: R.w(context, 4),
                  vertical: R.h(context, 1),
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.collections_bookmark_rounded,
                      color: Colors.white,
                      size: R.w(context, 5),
                    ),
                    SizedBox(width: R.w(context, 2)),
                    Text(
                      '26 Bài học',
                      style: TextStyle(
                        fontSize: R.fs(context, 3.5),
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: R.h(context, 3)),
          Text(
            '単語',
            style: TextStyle(
              fontSize: R.fs(context, 14),
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -2,
              shadows: [
                Shadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: Offset(0, 4),
                ),
              ],
            ),
          ),
          SizedBox(height: R.h(context, 0.5)),
          Text(
            'Từ vựng Minna no Nihongo',
            style: TextStyle(
              fontSize: R.fs(context, 4.5),
              fontWeight: FontWeight.w600,
              color: Colors.white.withOpacity(0.9),
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _LessonCard extends StatefulWidget {
  final int lessonNumber;
  final int delay;

  const _LessonCard({required this.lessonNumber, required this.delay});

  @override
  State<_LessonCard> createState() => _LessonCardState();
}

class _LessonCardState extends State<_LessonCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: 100,
      end: 0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getGradientColor1(int index) {
    final colors = [
      Color(0xFFFF6B6B), // Red
      Color(0xFF4FACFE), // Blue
      Color(0xFF43E97B), // Green
      Color(0xFFFA709A), // Pink
      Color(0xFFFEE140), // Yellow
      Color(0xFF30CFD0), // Cyan
      Color(0xFFA8EDEA), // Mint
      Color(0xFFFFD93D), // Orange
      Color(0xFF667EEA), // Purple
    ];
    return colors[index % colors.length];
  }

  Color _getGradientColor2(int index) {
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
    return colors[index % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final isPreLesson = widget.lessonNumber == 0;
    final lessonTitle = isPreLesson ? 'PRE' : '${widget.lessonNumber}';
    final lessonSubtitle = isPreLesson
        ? 'Bài chuẩn bị'
        : 'Bài học ${widget.lessonNumber}';

    final gradientColor1 = isPreLesson
        ? Color(0xFFFFD93D)
        : _getGradientColor1(widget.lessonNumber);
    final gradientColor2 = isPreLesson
        ? Color(0xFFFF8A00)
        : _getGradientColor2(widget.lessonNumber);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Transform.translate(
            offset: Offset(_slideAnimation.value, 0),
            child: child,
          ),
        );
      },
      child: Padding(
        padding: EdgeInsets.only(bottom: R.h(context, 2)),
        child: GestureDetector(
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) {
            setState(() => _isPressed = false);
            context.nav.toVocabularytDetail(context, widget.lessonNumber);
          },
          onTapCancel: () => setState(() => _isPressed = false),
          child: AnimatedContainer(
            duration: Duration(milliseconds: 200),
            transform: Matrix4.identity()
              ..scale(_isPressed ? 0.98 : 1.0)
              ..rotateZ(_isPressed ? -0.01 : 0),
            child: Container(
              height: R.h(context, 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: gradientColor1.withOpacity(0.3),
                    blurRadius: 20,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Gradient left side
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    child: Container(
                      width: R.w(context, 28),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [gradientColor1, gradientColor2],
                        ),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(24),
                          bottomLeft: Radius.circular(24),
                          topRight: Radius.circular(100),
                          bottomRight: Radius.circular(100),
                        ),
                      ),
                      child: Stack(
                        children: [
                          // Decorative circles
                          Positioned(
                            right: R.w(context, -5),
                            top: R.h(context, -2),
                            child: Container(
                              width: R.w(context, 20),
                              height: R.w(context, 20),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withOpacity(0.1),
                              ),
                            ),
                          ),
                          Positioned(
                            left: R.w(context, -3),
                            bottom: R.h(context, -1),
                            child: Container(
                              width: R.w(context, 15),
                              height: R.w(context, 15),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withOpacity(0.05),
                              ),
                            ),
                          ),
                          // Lesson number
                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (isPreLesson)
                                  Icon(
                                    Icons.star_rounded,
                                    color: Colors.white,
                                    size: R.w(context, 8),
                                  )
                                else
                                  Container(
                                    width: R.w(context, 12),
                                    height: R.w(context, 12),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white.withOpacity(0.2),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.4),
                                        width: 2,
                                      ),
                                    ),
                                    child: Center(
                                      child: Icon(
                                        Icons.book_rounded,
                                        color: Colors.white,
                                        size: R.w(context, 6),
                                      ),
                                    ),
                                  ),
                                SizedBox(height: R.h(context, 0.5)),
                                Text(
                                  lessonTitle,
                                  style: TextStyle(
                                    fontSize: R.fs(context, 6),
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Content right side
                  Positioned(
                    left: R.w(context, 30),
                    right: R.w(context, 4),
                    top: 0,
                    bottom: 0,
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                lessonSubtitle,
                                style: TextStyle(
                                  fontSize: R.fs(context, 4.5),
                                  fontWeight: FontWeight.w900,
                                  color: AppTheme.primaryText,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              SizedBox(height: R.h(context, 0.5)),
                              Row(
                                children: [
                                  Icon(
                                    Icons.description_outlined,
                                    size: R.w(context, 4),
                                    color: AppTheme.secondaryText,
                                  ),
                                  SizedBox(width: R.w(context, 1.5)),
                                  Text(
                                    'Từ vựng cơ bản',
                                    style: TextStyle(
                                      fontSize: R.fs(context, 3.2),
                                      color: AppTheme.secondaryText,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Arrow button
                        Container(
                          width: R.w(context, 12),
                          height: R.w(context, 12),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [gradientColor1, gradientColor2],
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: gradientColor1.withOpacity(0.4),
                                blurRadius: 12,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.arrow_forward_rounded,
                            color: Colors.white,
                            size: R.w(context, 6),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Special badge for Pre
                  if (isPreLesson)
                    Positioned(
                      right: R.w(context, 16),
                      top: R.h(context, 1),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: R.w(context, 2),
                          vertical: R.h(context, 0.3),
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
                          ),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xFFFF6B6B).withOpacity(0.4),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          'HOT',
                          style: TextStyle(
                            fontSize: R.fs(context, 2.5),
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}