import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minna_ai_n5/providers/streak_provider.dart';
import 'package:minna_ai_n5/providers/user_provider.dart';
import 'package:minna_ai_n5/routes/navigation_manager.dart';
import 'package:minna_ai_n5/utils/date_utils.dart';
import 'package:minna_ai_n5/utils/responsive.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(streakServiceProvider).updateStreak();
    });
    final userDoc = ref.watch(userStreamProvider);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF8F9FA), Color(0xFFE9ECEF), Color(0xFFFFF4E6)],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Header with Streak
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    R.w(context, 6),
                    R.h(context, 3),
                    R.w(context, 6),
                    R.h(context, 2),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Streak Badge
                      userDoc.when(
                        data: (doc) {
                          final streak = doc['streak'] ?? 0;
                          final learned = doc['lastStudyDate'] != null
                              ? doc['lastStudyDate'] ==
                                    DateUtilsHelper.todayKey()
                              : false;

                          return Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: R.w(context, 4),
                              vertical: R.h(context, 1),
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: learned
                                    ? [Color(0xFFFF6B6B), Color(0xFFFF8E53)]
                                    : [Color(0xFFE0E0E0), Color(0xFFBDBDBD)],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: learned
                                      ? Color(0xFFFF6B6B).withOpacity(0.3)
                                      : Colors.grey.withOpacity(0.2),
                                  blurRadius: 12,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  learned
                                      ? Icons.local_fire_department_rounded
                                      : Icons.local_fire_department_outlined,
                                  color: Colors.white,
                                  size: R.w(context, 6),
                                ),
                                SizedBox(width: R.w(context, 2)),
                                Text(
                                  '$streak ngày',
                                  style: TextStyle(
                                    fontSize: R.fs(context, 4),
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        loading: () => const SizedBox(),
                        error: (_, __) => const SizedBox(),
                      ),

                      SizedBox(height: R.h(context, 3)),

                      // Title
                      Text(
                        'Minna',
                        style: TextStyle(
                          fontSize: R.fs(context, 12),
                          fontWeight: FontWeight.w900,
                          letterSpacing: -2,
                          height: 1.0,
                          foreground: Paint()
                            ..shader = LinearGradient(
                              colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
                            ).createShader(Rect.fromLTWH(0, 0, 200, 70)),
                        ),
                      ),
                      SizedBox(height: R.h(context, 0.5)),
                      Text(
                        'みんなの日本語',
                        style: TextStyle(
                          fontSize: R.fs(context, 5),
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF495057),
                          letterSpacing: 2,
                        ),
                      ),
                      SizedBox(height: R.h(context, 0.8)),
                      Text(
                        'N5 Level • Japanese Learning',
                        style: TextStyle(
                          fontSize: R.fs(context, 3.5),
                          color: Color(0xFF868E96),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Cards
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  R.w(context, 6),
                  R.h(context, 3),
                  R.w(context, 6),
                  R.h(context, 4),
                ),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    ElevatedButton(
                      onPressed: () {
                        context.nav.toSettings(context);
                      },
                      child: Text('SETTING'),
                    ),
                    _ModernHomeCard(
                      title: '文字',
                      subtitle: 'Bảng chữ cái',
                      description: 'Học Hiragana & Katakana',
                      icon: Icons.text_fields_rounded,
                      gradientColors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                      delay: 0,
                      onTap: () {
                        context.nav.toAlphabetMenu(context);
                      },
                    ),
                    SizedBox(height: R.h(context, 2)),
                    _ModernHomeCard(
                      title: '単語',
                      subtitle: 'Từ vựng',
                      description: 'Minna no Nihongo N5',
                      icon: Icons.book_rounded,
                      gradientColors: [Color(0xFFF093FB), Color(0xFFF5576C)],
                      delay: 100,
                      onTap: () {
                        context.nav.toVocabularytMenu(context);
                      },
                    ),
                    SizedBox(height: R.h(context, 2)),
                    _ModernHomeCard(
                      title: '文法',
                      subtitle: 'Ngữ pháp',
                      description: 'Cấu trúc câu cơ bản',
                      icon: Icons.menu_book_rounded,
                      gradientColors: [Color(0xFF4FACFE), Color(0xFF00F2FE)],
                      delay: 200,
                      onTap: () {},
                    ),
                    SizedBox(height: R.h(context, 2)),
                    _ModernHomeCard(
                      title: '会話',
                      subtitle: 'Hội thoại AI',
                      description: 'Luyện giao tiếp với AI',
                      icon: Icons.psychology_rounded,
                      gradientColors: [Color(0xFFFA709A), Color(0xFFFEE140)],
                      delay: 300,
                      onTap: () {},
                    ),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModernHomeCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final List<Color> gradientColors;
  final int delay;
  final VoidCallback onTap;

  const _ModernHomeCard({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.gradientColors,
    required this.delay,
    required this.onTap,
  });

  @override
  State<_ModernHomeCard> createState() => _ModernHomeCardState();
}

class _ModernHomeCardState extends State<_ModernHomeCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

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

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Transform.scale(scale: _scaleAnimation.value, child: child),
        );
      },
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) {
          setState(() => _isPressed = false);
          widget.onTap();
        },
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedContainer(
          duration: Duration(milliseconds: 150),
          transform: Matrix4.identity()..scale(_isPressed ? 0.97 : 1.0),
          child: Container(
            height: R.h(context, 15),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: widget.gradientColors,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: widget.gradientColors[0].withOpacity(0.3),
                  blurRadius: 20,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Decorative circles
                Positioned(
                  right: R.w(context, -5),
                  top: R.h(context, -2),
                  child: Container(
                    width: R.w(context, 25),
                    height: R.w(context, 25),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.1),
                    ),
                  ),
                ),
                Positioned(
                  right: R.w(context, 10),
                  bottom: R.h(context, -3),
                  child: Container(
                    width: R.w(context, 20),
                    height: R.w(context, 20),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.05),
                    ),
                  ),
                ),
                // Content
                Padding(
                  padding: EdgeInsets.all(R.sp(context, 6)),
                  child: Row(
                    children: [
                      // Icon container
                      Container(
                        width: R.w(context, 16),
                        height: R.w(context, 16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1.5,
                          ),
                        ),
                        child: Icon(
                          widget.icon,
                          color: Colors.white,
                          size: R.w(context, 8),
                        ),
                      ),
                      SizedBox(width: R.w(context, 5)),
                      // Text content
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              widget.title,
                              style: TextStyle(
                                fontSize: R.fs(context, 7),
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: -0.5,
                                height: 1.1,
                              ),
                            ),
                            SizedBox(height: R.h(context, 0.2)),
                            Text(
                              widget.subtitle,
                              style: TextStyle(
                                fontSize: R.fs(context, 4),
                                fontWeight: FontWeight.w600,
                                color: Colors.white.withOpacity(0.9),
                                letterSpacing: 0.3,
                              ),
                            ),
                            SizedBox(height: R.h(context, 0.4)),
                            Text(
                              widget.description,
                              style: TextStyle(
                                fontSize: R.fs(context, 3.2),
                                color: Colors.white.withOpacity(0.75),
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Arrow icon
                      Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white.withOpacity(0.8),
                        size: R.w(context, 6),
                      ),
                    ],
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
