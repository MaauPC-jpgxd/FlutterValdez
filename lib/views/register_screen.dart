import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final nombreController     = TextEditingController();
  final telefonoController   = TextEditingController();
  final negocioController    = TextEditingController();
  final telNegocioController = TextEditingController();
  final ubicacionController  = TextEditingController();
  final emailController      = TextEditingController();
  final passController       = TextEditingController();

  bool loading    = false;
  bool obscurePass = true;

  // ── Colores (mismo sistema que LoginScreen) ────────────────────────────────
  static const _bg         = Color(0xFF0A0E1A);
  static const _surfaceAlt = Color(0xFF1C2333);
  static const _accent     = Color(0xFF2563EB);
  static const _textPri    = Color(0xFFF1F5F9);
  static const _textSec    = Color(0xFF94A3B8);
  static const _border     = Color(0xFF1E293B);
  static const _errorColor = Color(0xFFEF4444);

  // ── Validaciones (sin cambios) ─────────────────────────────────────────────
  String? validarNombre(String? value) {
    if (value == null || value.trim().isEmpty) return "Ingresa tu nombre";
    if (value.length < 3) return "Muy corto";
    return null;
  }

  String? validarTelefono(String? value) {
    if (value == null || value.isEmpty) return "Ingresa teléfono";
    if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) return "Debe tener 10 dígitos";
    return null;
  }

  String? validarEmail(String? value) {
    if (value == null || value.isEmpty) return "Ingresa correo";
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) return "Correo inválido";
    return null;
  }

  String? validarPassword(String? value) {
    if (value == null || value.isEmpty) return "Ingresa contraseña";
    if (value.length < 6) return "Mínimo 6 caracteres";
    if (!RegExp(r'[A-Z]').hasMatch(value)) return "Debe tener mayúscula";
    if (!RegExp(r'[0-9]').hasMatch(value)) return "Debe tener número";
    return null;
  }

  String mapError(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use': return "Este correo ya está registrado";
      case 'invalid-email':        return "Correo inválido";
      case 'weak-password':        return "Contraseña débil";
      default:                     return "Error al registrar";
    }
  }

  Future<void> register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);

    try {
      UserCredential user = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passController.text.trim(),
      );

      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.user!.uid)
          .set({
        "nombre":           nombreController.text.trim(),
        "telefono":         telefonoController.text.trim(),
        "negocio":          negocioController.text.trim(),
        "telefono_negocio": telNegocioController.text.trim(),
        "ubicacion":        ubicacionController.text.trim(),
        "email":            emailController.text.trim(),
        "created_at":       FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Cuenta creada correctamente 🚀"),
          backgroundColor: const Color(0xFF16A34A),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );

      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(mapError(e)),
          backgroundColor: _errorColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }

    setState(() => loading = false);
  }

  // ── Helper decoración de inputs ────────────────────────────────────────────
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,

      // ── AppBar ──────────────────────────────────────────────────────────────
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: _textPri, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Crear cuenta",
          style: TextStyle(
            color: _textPri,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ── Sección: Datos personales ───────────────────────────────────
              _SectionHeader(title: "Datos personales"),
              const SizedBox(height: 12),

              _FieldLabel(text: "Nombre completo"),
              const SizedBox(height: 6),
              TextFormField(
                controller: nombreController,
                validator: validarNombre,
                style: const TextStyle(color: _textPri, fontSize: 15),
                decoration: _inputDecoration(
                  hint: "Juan Pérez",
                  icon: Icons.person_outline_rounded,
                ),
              ),

              const SizedBox(height: 16),

              _FieldLabel(text: "Teléfono personal"),
              const SizedBox(height: 6),
              TextFormField(
                controller: telefonoController,
                keyboardType: TextInputType.phone,
                validator: validarTelefono,
                style: const TextStyle(color: _textPri, fontSize: 15),
                decoration: _inputDecoration(
                  hint: "10 dígitos",
                  icon: Icons.phone_outlined,
                ),
              ),

              const SizedBox(height: 28),

              // ── Divider ─────────────────────────────────────────────────────
              _SectionDivider(),

              // ── Sección: Datos del negocio ──────────────────────────────────
              _SectionHeader(title: "Datos del negocio"),
              const SizedBox(height: 12),

              _FieldLabel(text: "Nombre del negocio"),
              const SizedBox(height: 6),
              TextFormField(
                controller: negocioController,
                validator: validarNombre,
                style: const TextStyle(color: _textPri, fontSize: 15),
                decoration: _inputDecoration(
                  hint: "Mi tienda S.A.",
                  icon: Icons.store_outlined,
                ),
              ),

              const SizedBox(height: 16),

              _FieldLabel(text: "Teléfono del negocio"),
              const SizedBox(height: 6),
              TextFormField(
                controller: telNegocioController,
                keyboardType: TextInputType.phone,
                validator: validarTelefono,
                style: const TextStyle(color: _textPri, fontSize: 15),
                decoration: _inputDecoration(
                  hint: "10 dígitos",
                  icon: Icons.storefront_outlined,
                ),
              ),

              const SizedBox(height: 16),

              _FieldLabel(text: "Dirección completa"),
              const SizedBox(height: 6),
              TextFormField(
                controller: ubicacionController,
                validator: validarNombre,
                style: const TextStyle(color: _textPri, fontSize: 15),
                decoration: _inputDecoration(
                  hint: "Calle, número, colonia, ciudad",
                  icon: Icons.location_on_outlined,
                ),
              ),

              const SizedBox(height: 28),

              // ── Divider ─────────────────────────────────────────────────────
              _SectionDivider(),

              // ── Sección: Acceso ─────────────────────────────────────────────
              _SectionHeader(title: "Acceso"),
              const SizedBox(height: 12),

              _FieldLabel(text: "Correo electrónico"),
              const SizedBox(height: 6),
              TextFormField(
                controller: emailController,
                validator: validarEmail,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: _textPri, fontSize: 15),
                decoration: _inputDecoration(
                  hint: "usuario@correo.com",
                  icon: Icons.email_outlined,
                ),
              ),

              const SizedBox(height: 16),

              _FieldLabel(text: "Contraseña"),
              const SizedBox(height: 6),
              TextFormField(
                controller: passController,
                obscureText: obscurePass,
                validator: validarPassword,
                style: const TextStyle(color: _textPri, fontSize: 15),
                decoration: _inputDecoration(
                  hint: "Mínimo 6 caracteres",
                  icon: Icons.lock_outline_rounded,
                  suffix: IconButton(
                    splashRadius: 20,
                    icon: Icon(
                      obscurePass
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: _textSec,
                      size: 20,
                    ),
                    onPressed: () =>
                        setState(() => obscurePass = !obscurePass),
                  ),
                ),
              ),

              // ── Hint de requisitos ──────────────────────────────────────────
              const SizedBox(height: 8),
              const Padding(
                padding: EdgeInsets.only(left: 4),
                child: Text(
                  "Al menos 6 caracteres, una mayúscula y un número",
                  style: TextStyle(color: _textSec, fontSize: 11),
                ),
              ),

              const SizedBox(height: 36),

              // ── Botón registrar ─────────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: loading ? null : register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _accent,
                    disabledBackgroundColor: _accent.withOpacity(0.4),
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
                    "Crear cuenta",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ── Ya tengo cuenta ─────────────────────────────────────────────
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(foregroundColor: _textSec),
                  child: RichText(
                    text: const TextSpan(
                      style: TextStyle(fontSize: 14, color: _textSec),
                      children: [
                        TextSpan(text: "¿Ya tienes cuenta? "),
                        TextSpan(
                          text: "Inicia sesión",
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

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Widgets auxiliares ────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: Color(0xFFF1F5F9),
        fontSize: 15,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFF94A3B8),
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
      ),
    );
  }
}

class _SectionDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(bottom: 20),
      child: Divider(color: Color(0xFF1E293B), thickness: 1),
    );
  }
}