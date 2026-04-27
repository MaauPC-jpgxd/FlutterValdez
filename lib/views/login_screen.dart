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
  final _formKey = GlobalKey<FormState>();
  final email = TextEditingController();
  final pass = TextEditingController();

  bool loading = false;
  bool ocultarPassword = true; // 👁

  // 🔥 VALIDACIONES
  String? validarUsuario(String value) {
    if (value.isEmpty) return "Este campo es obligatorio";

    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    final phoneRegex = RegExp(r'^[0-9]{10,15}$');

    if (!emailRegex.hasMatch(value) && !phoneRegex.hasMatch(value)) {
      return "Ingresa un correo o teléfono válido";
    }

    return null;
  }

  String? validarPassword(String value) {
    if (value.isEmpty) return "La contraseña es obligatoria";

    if (value.length < 6) return "Mínimo 6 caracteres";

    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return "Debe tener una mayúscula";
    }

    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return "Debe tener un número";
    }

    return null;
  }

  void login() async {
    // 🔥 VALIDACIÓN ANTES DE FIREBASE
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);

    final error = await controller.login(
      email.text.trim(),
      pass.text.trim(),
    );

    setState(() => loading = false);

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: Colors.red,
        ),
      );
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
                  "Depósito Valdez",
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

                  // 🔥 FORM
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: email,
                          validator: (value) =>
                              validarUsuario(value ?? ""),
                          decoration: InputDecoration(
                            labelText: "Correo o teléfono",
                            prefixIcon: const Icon(Icons.person),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),

                        const SizedBox(height: 15),

                        TextFormField(
                          controller: pass,
                          obscureText: ocultarPassword,
                          validator: (value) =>
                              validarPassword(value ?? ""),
                          decoration: InputDecoration(
                            labelText: "Contraseña",
                            prefixIcon: const Icon(Icons.lock),

                            // 👁 BOTÓN VER CONTRASEÑA
                            suffixIcon: IconButton(
                              icon: Icon(
                                ocultarPassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  ocultarPassword = !ocultarPassword;
                                });
                              },
                            ),

                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),

                        const SizedBox(height: 25),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: loading ? null : login,
                            child: loading
                                ? const CircularProgressIndicator(
                                color: Colors.white)
                                : const Text("Iniciar sesión"),
                          ),
                        ),

                        const SizedBox(height: 15),

                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                  const RegisterScreen()),
                            );
                          },
                          child:
                          const Text("¿No tienes cuenta? Regístrate"),
                        ),

                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                  const WebViewScreen()),
                            );
                          },
                          child: const Text("Continuar sin cuenta"),
                        ),

                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                  const PrivacyScreen()),
                            );
                          },
                          child:
                          const Text("Políticas de privacidad"),
                        ),
                      ],
                    ),
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