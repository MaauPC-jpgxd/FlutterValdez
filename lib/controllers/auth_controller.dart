import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

class AuthController {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;
  Timer? _timer;

  // 🟢 REGISTRO
  Future<String?> register({
    required String email,
    required String password,
    required Map<String, dynamic> data,
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 📩 enviar verificación
      await cred.user!.sendEmailVerification();

      // 💾 guardar usuario
      await _db.collection('usuarios').doc(cred.user!.uid).set({
        ...data,
        "emailVerified": false,
        "created_at": FieldValue.serverTimestamp(),
      });

      // 🔐 cerrar sesión
      await _auth.signOut();

      return null;
    } on FirebaseAuthException catch (e) {
      return _mapError(e.code);
    }
  }

  // 🔵 LOGIN
  Future<String?> login(String email, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      await cred.user!.reload();
      final user = _auth.currentUser;

      if (user != null && !user.emailVerified) {
        await _auth.signOut();
        return "Debes verificar tu correo antes de iniciar sesión 📩";
      }

      // 🔥 actualizar Firestore
      await _db.collection('usuarios').doc(user!.uid).update({
        "emailVerified": true,
      });

      return null;
    } on FirebaseAuthException catch (e) {
      return _mapError(e.code);
    }
  }

  // 📩 REENVIAR CORREO
  Future<void> resendEmail() async {
    await _auth.currentUser?.sendEmailVerification();
  }

  // 🔄 AUTO REFRESH (🔥 ESTE ES EL IMPORTANTE)
  void startEmailVerificationCheck({
    required Function onVerified,
  }) {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      final user = _auth.currentUser;

      await user?.reload();

      if (user != null && user.emailVerified) {
        // 🔥 sincronizar con Firestore
        await _db.collection('usuarios').doc(user.uid).update({
          "emailVerified": true,
        });

        timer.cancel();
        onVerified();
      }
    });
  }

  void stopEmailCheck() {
    _timer?.cancel();
  }

  // 🧹 LOGOUT
  Future<void> logout() async {
    await _auth.signOut();
  }

  // ❌ ERRORES
  String _mapError(String code) {
    switch (code) {
      case 'email-already-in-use':
        return "Correo ya registrado";
      case 'invalid-email':
        return "Correo inválido";
      case 'weak-password':
        return "Contraseña débil";
      case 'user-not-found':
        return "Usuario no encontrado";
      case 'wrong-password':
        return "Contraseña incorrecta";
      default:
        return "Error inesperado";
    }
  }
}