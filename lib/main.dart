import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:minna_ai_n5/app.dart';
import 'package:minna_ai_n5/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}