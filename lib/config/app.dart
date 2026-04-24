import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import '../views/login_screen.dart';
import '../views/webview_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../firebase_options.dart';

class CasaValdezApp extends StatelessWidget {
  const CasaValdezApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: "Casa Valdez",
            theme: ThemeData(
              primaryColor: const Color(0xFF1565C0),
            ),
            home: const AuthWrapper(),
          );
        }

        return const MaterialApp(
          home: Scaffold(
            body: Center(child: CircularProgressIndicator()),
          ),
        );
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return const WebViewScreen();
        }
        return const LoginScreen();
      },
    );
  }
}