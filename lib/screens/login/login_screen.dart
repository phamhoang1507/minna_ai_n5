// File: lib/screens/auth/login_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minna_ai_n5/providers/auth_init_provider.dart';
import 'package:minna_ai_n5/utils/app_theme.dart';
import 'package:minna_ai_n5/utils/responsive.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool _isLoading = false;

  Future<void> _handleGoogleSignIn() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      final authService = ref.read(authServiceProvider);
      final user = await authService.signInWithGoogle();

      // ✅ Check mounted trước khi dùng context
      if (!mounted) return;

      if (user != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Chào mừng ${user.displayName ?? "bạn"}!'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    } catch (e) {
      // ✅ Check mounted trước khi dùng context
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi đăng nhập: $e'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleGuestSignIn() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      final authService = ref.read(authServiceProvider);
      await authService.ensureUser();

      // Navigation tự động xử lý bởi GoRouter
    } catch (e) {
      // ✅ Check mounted
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: $e'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFF6B6B).withOpacity(0.1),
              Color(0xFFFF8E53).withOpacity(0.05),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: R.w(context, 8)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  Text(
                    'Minna',
                    style: TextStyle(
                      fontSize: R.fs(context, 16),
                      fontWeight: FontWeight.w900,
                      letterSpacing: -2,
                      foreground: Paint()
                        ..shader = LinearGradient(
                          colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
                        ).createShader(Rect.fromLTWH(0, 0, 200, 70)),
                    ),
                  ),
                  SizedBox(height: R.h(context, 1)),
                  Text(
                    'みんなの日本語',
                    style: TextStyle(
                      fontSize: R.fs(context, 5),
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryText,
                      letterSpacing: 2,
                    ),
                  ),

                  SizedBox(height: R.h(context, 8)),

                  // Google Sign In Button
                  SizedBox(
                    width: double.infinity,
                    height: R.h(context, 7),
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _handleGoogleSignIn,
                      icon: _isLoading
                          ? SizedBox(
                              width: R.w(context, 6),
                              height: R.w(context, 6),
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Color(0xFF4285F4),
                                ),
                              ),
                            )
                          : Icon(Icons.login, size: R.w(context, 6)),
                      label: Text(
                        _isLoading ? 'Đang đăng nhập...' : 'Đăng nhập với Google',
                        style: TextStyle(
                          fontSize: R.fs(context, 4.5),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Color(0xFF4285F4),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: Color(0xFF4285F4).withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: R.h(context, 2)),

                  // Divider
                  Row(
                    children: [
                      Expanded(child: Divider(color: AppTheme.borderColor)),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: R.w(context, 4)),
                        child: Text(
                          'hoặc',
                          style: TextStyle(
                            fontSize: R.fs(context, 3.5),
                            color: AppTheme.secondaryText,
                          ),
                        ),
                      ),
                      Expanded(child: Divider(color: AppTheme.borderColor)),
                    ],
                  ),

                  SizedBox(height: R.h(context, 2)),

                  // Continue as Guest
                  SizedBox(
                    width: double.infinity,
                    height: R.h(context, 7),
                    child: OutlinedButton.icon(
                      onPressed: _isLoading ? null : _handleGuestSignIn,
                      icon: Icon(Icons.person_outline, size: R.w(context, 6)),
                      label: Text(
                        'Tiếp tục với tài khoản khách',
                        style: TextStyle(
                          fontSize: R.fs(context, 4.5),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.primaryText,
                        side: BorderSide(
                          color: AppTheme.borderColor,
                          width: 2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
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