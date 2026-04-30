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
  bool ocultarPassword = true;

  // 🔥 VALIDACIONES
  String? validarUsuario(String value) {
    if (value.isEmpty) return "Este campo es obligatorio";

    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    final phoneRegex = RegExp(r'^[0-9]{10,15}$');

    if (!emailRegex.hasMatch(value) && !phoneRegex.hasMatch(value)) {
      return "Ingresa un correo válido";
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
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);

    final error = await controller.login(
      email.text.trim(),
      pass.text.trim(),
    );

    setState(() => loading = false);

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const WebViewScreen()),
    );
  }

  // ── Colores centralizados (Nu-style azul) ──────────────────────────────────
  static const _bg         = Color(0xFF0A0E1A); // fondo oscuro principal
  static const _surface    = Color(0xFF111827); // superficie de cards
  static const _surfaceAlt = Color(0xFF1C2333); // inputs
  static const _accent     = Color(0xFF2563EB); // azul Nu
  static const _accentSoft = Color(0xFF1D4ED8); // azul presionado
  static const _textPri    = Color(0xFFF1F5F9); // texto principal
  static const _textSec    = Color(0xFF94A3B8); // texto secundario
  static const _border     = Color(0xFF1E293B); // bordes sutiles
  static const _errorColor = Color(0xFFEF4444); // error

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),

              // ── Logo + nombre ──────────────────────────────────────────────
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      // Sin padding para que la imagen llene todo
                      clipBehavior: Clip.hardEdge,
                      decoration: BoxDecoration(
                        color: _surface,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          )
                        ],
                        border: Border.all(color: _border),
                      ),
                      child: Image.asset(
                        "assets/images/login.png",
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Depósito Valdez",
                      style: TextStyle(
                        color: _textPri,
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      "Inicia sesión para continuar",
                      style: TextStyle(
                        color: _textSec,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 48),

              // ── Formulario ────────────────────────────────────────────────
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Campo: correo / teléfono
                    _FieldLabel(text: "Ingresa tu Correo "),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: email,
                      validator: (value) => validarUsuario(value ?? ""),
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(
                        color: _textPri,
                        fontSize: 15,
                      ),
                      decoration: _inputDecoration(
                        hint: "usuario@correo.com",
                        icon: Icons.person_outline_rounded,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Campo: contraseña
                    _FieldLabel(text: "Contraseña"),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: pass,
                      obscureText: ocultarPassword,
                      validator: (value) => validarPassword(value ?? ""),
                      style: const TextStyle(
                        color: _textPri,
                        fontSize: 15,
                      ),
                      decoration: _inputDecoration(
                        hint: "••••••••",
                        icon: Icons.lock_outline_rounded,
                        suffix: IconButton(
                          splashRadius: 20,
                          icon: Icon(
                            ocultarPassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: _textSec,
                            size: 20,
                          ),
                          onPressed: () {
                            setState(() {
                              ocultarPassword = !ocultarPassword;
                            });
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 36),

                    // ── Botón principal ──────────────────────────────────────
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: loading ? null : login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _accent,
                          disabledBackgroundColor: _accentSoft.withOpacity(0.5),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: loading
                            ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                            : const Text(
                          "Iniciar sesión",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // ── Divider ──────────────────────────────────────────────
                    Row(
                      children: [
                        Expanded(child: Divider(color: _border, thickness: 1)),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            "o",
                            style: TextStyle(color: _textSec, fontSize: 13),
                          ),
                        ),
                        Expanded(child: Divider(color: _border, thickness: 1)),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // ── Links secundarios ────────────────────────────────────
                    Center(
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const RegisterScreen()),
                          );
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: _accent,
                        ),
                        child: RichText(
                          text: const TextSpan(
                            style: TextStyle(fontSize: 14, color: _textSec),
                            children: [
                              TextSpan(text: "¿No tienes cuenta? "),
                              TextSpan(
                                text: "Regístrate",
                                style: TextStyle(
                                  color: _accent,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 4),

                    Center(
                      child: TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const WebViewScreen()),
                          );
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: _textSec,
                        ),
                        child: const Text(
                          "Continuar sin cuenta",
                          style: TextStyle(
                            fontSize: 14,
                            color: _textSec,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── Políticas ────────────────────────────────────────────
                    Center(
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const PrivacyScreen()),
                          );
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: _textSec,
                        ),
                        child: const Text(
                          "Políticas de privacidad",
                          style: TextStyle(
                            fontSize: 12,
                            color: _textSec,
                            decoration: TextDecoration.underline,
                            decorationColor: _textSec,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Helper: decoración de inputs ──────────────────────────────────────────
  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: _textSec, fontSize: 14),
      filled: true,
      fillColor: _surfaceAlt,
      prefixIcon: Icon(icon, color: _textSec, size: 20),
      suffixIcon: suffix,
      errorStyle: const TextStyle(color: _errorColor, fontSize: 12),
      contentPadding:
      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _border, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _accent, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _errorColor, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _errorColor, width: 1.5),
      ),
    );
  }
}

// ── Widget auxiliar para labels de campos ────────────────────────────────────
class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFF94A3B8),
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
      ),
    );
  }
}