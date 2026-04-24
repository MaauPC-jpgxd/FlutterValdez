import 'package:flutter/material.dart';
import '../controllers/auth_controller.dart';
import 'register_screen.dart';
import 'webview_screen.dart';
import 'privacy_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final controller = AuthController();

  final email = TextEditingController();
  final pass = TextEditingController();

  bool loading = false;

  void login() async {
    setState(() => loading = true);

    final error = await controller.login(
      email.text.trim(),
      pass.text.trim(),
    );

    setState(() => loading = false);

    if (error != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(25),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const Icon(Icons.store, size: 90, color: Colors.white),
                const SizedBox(height: 20),

                const Text(
                  "Casa Valdez",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 40),

                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    children: [
                      TextField(
                        controller: email,
                        decoration: const InputDecoration(
                          labelText: "Correo o teléfono",
                          prefixIcon: Icon(Icons.person),
                        ),
                      ),
                      const SizedBox(height: 15),
                      TextField(
                        controller: pass,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: "Contraseña",
                          prefixIcon: Icon(Icons.lock),
                        ),
                      ),
                      const SizedBox(height: 25),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: loading ? null : login,
                          child: loading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text("Iniciar sesión"),
                        ),
                      ),

                      const SizedBox(height: 15),

                      // 👉 REGISTRO
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const RegisterScreen()),
                          );
                        },
                        child: const Text("¿No tienes cuenta? Regístrate"),
                      ),

                      // 👉 CONTINUAR SIN CUENTA
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const WebViewScreen()),
                          );
                        },
                        child: const Text("Continuar sin cuenta"),
                      ),

                      // 👉 PRIVACIDAD
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const PrivacyScreen()),
                          );
                        },
                        child: const Text("Políticas de privacidad"),
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