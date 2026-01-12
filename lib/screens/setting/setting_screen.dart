// File: lib/screens/settings/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minna_ai_n5/providers/auth_init_provider.dart';
import 'package:minna_ai_n5/utils/app_theme.dart';
import 'package:minna_ai_n5/utils/responsive.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authService = ref.watch(authServiceProvider);
    final isAnonymous = ref.watch(isAnonymousProvider);
    final currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Cài đặt'),
      ),
      body: ListView(
        padding: EdgeInsets.all(R.sp(context, 4)),
        children: [
          // User Info Card
          if (currentUser != null)
            Container(
              padding: EdgeInsets.all(R.sp(context, 4)),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: R.w(context, 10),
                    backgroundImage: currentUser.photoURL != null
                        ? NetworkImage(currentUser.photoURL!)
                        : null,
                    child: currentUser.photoURL == null
                        ? Icon(Icons.person, size: R.w(context, 10))
                        : null,
                  ),
                  SizedBox(width: R.w(context, 4)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currentUser.displayName ?? 'Tài khoản khách',
                          style: TextStyle(
                            fontSize: R.fs(context, 4.5),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (currentUser.email != null)
                          Text(
                            currentUser.email!,
                            style: TextStyle(
                              fontSize: R.fs(context, 3.5),
                              color: AppTheme.secondaryText,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          
          SizedBox(height: R.h(context, 2)),
          
          // Link Google Account (chỉ hiện nếu là anonymous)
          if (isAnonymous)
            ListTile(
              leading: Icon(Icons.link, color: Color(0xFF4285F4)),
              title: Text('Liên kết với Google'),
              subtitle: Text('Đồng bộ dữ liệu trên nhiều thiết bị'),
              trailing: Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () async {
                try {
                  final user = await authService.linkAnonymousToGoogle();
                  
                  if (user != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Đã liên kết thành công!'),
                        backgroundColor: AppTheme.successColor,
                      ),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Lỗi: $e'),
                      backgroundColor: AppTheme.errorColor,
                    ),
                  );
                }
              },
            ),
          
          Divider(),
          
          // Sign Out
          ListTile(
            leading: Icon(Icons.logout, color: AppTheme.errorColor),
            title: Text(
              'Đăng xuất',
              style: TextStyle(color: AppTheme.errorColor),
            ),
            onTap: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Xác nhận'),
                  content: Text('Bạn có chắc muốn đăng xuất?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text('Hủy'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: Text('Đăng xuất'),
                    ),
                  ],
                ),
              );
              
              if (confirm == true) {
                await authService.signOut();
                // Navigation tự động về login
              }
            },
          ),
        ],
      ),
    );
  }
}