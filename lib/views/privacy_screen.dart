import 'package:flutter/material.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Privacidad")),
      body: const Padding(
        padding: EdgeInsets.all(20),
        child: Text(
          "Aquí van tus políticas de privacidad...",
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}