import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minna_ai_n5/app.dart'; // File chứa MyApp
import 'package:minna_ai_n5/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Chỉ giữ lại Firebase (vì bạn đang dùng Auth/Firestore)
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );


  // Chạy app với ProviderScope (bắt buộc cho Riverpod)
  runApp(
    const ProviderScope(  
      child: MyApp(),
    ),
  );
}