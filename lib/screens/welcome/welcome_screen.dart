import 'package:flutter/material.dart';
import 'package:minna_ai_n5/routes/navigation_manager.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(onPressed: () {
          context.nav.toLogin(context);
        }, child: Text('Continue')),
      ),
    );
  }
}
