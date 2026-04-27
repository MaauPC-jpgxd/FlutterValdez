import 'package:flutter/material.dart';
import '../controllers/user_controller.dart';

class UpdateProfileScreen extends StatefulWidget {
  const UpdateProfileScreen({super.key});

  @override
  State<UpdateProfileScreen> createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  final controller = UserController();
  final _formKey = GlobalKey<FormState>();

  final nombre    = TextEditingController();
  final telefono  = TextEditingController();
  final negocio   = TextEditingController();
  final telNegocio = TextEditingController();
  final ubicacion = TextEditingController();

  bool loading = false;

  // ── Colores (mismo sistema Nu) ─────────────────────────────────────────────
  static const _bg         = Color(0xFF0A0E1A);
  static const _surface    = Color(0xFF111827);
  static const _surfaceAlt = Color(0xFF1C2333);
  static const _accent     = Color(0xFF2563EB);
  static const _textPri    = Color(0xFFF1F5F9);
  static const _textSec    = Color(0xFF94A3B8);
  static const _border     = Color(0xFF1E293B);
  static const _errorColor = Color(0xFFEF4444);

  @override
  void initState() {
    super.initState();
    cargarDatos();
  }

  void cargarDatos() async {
    final data = await controller.getUserData();
    if (data != null) {
      nombre.text    = data['nombre']           ?? '';
      telefono.text  = data['telefono']         ?? '';
      negocio.text   = data['negocio']          ?? '';
      telNegocio.text = data['telefono_negocio'] ?? '';
      ubicacion.text = data['ubicacion']        ?? '';
    }
  }

  // ── Validaciones (sin cambios) ─────────────────────────────────────────────
  String? validarTexto(String value, String campo) {
    if (value.isEmpty) return "$campo requerido";
    if (value.length < 3) return "$campo muy corto";
    return null;
  }

  String? validarTelefono(String value) {
    if (value.isEmpty) return "Teléfono requerido";
    if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) {
      return "Teléfono inválido (10 dígitos)";
    }
    return null;
  }

  void actualizar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);

    final error = await controller.updateUser(
      nombre:          nombre.text.trim(),
      telefono:        telefono.text.trim(),
      negocio:         negocio.text.trim(),
      telefonoNegocio: telNegocio.text.trim(),
      ubicacion:       ubicacion.text.trim(),
    );

    setState(() => loading = false);

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: _errorColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Datos actualizados correctamente ✅"),
        backgroundColor: const Color(0xFF16A34A),
        behavior: SnackBarBehavior.floating,
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );

    Navigator.pop(context);
  }

  // ── Helper decoración de inputs ────────────────────────────────────────────
  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: _textSec, fontSize: 14),
      filled: true,
      fillColor: _surfaceAlt,
      prefixIcon: Icon(icon, color: _textSec, size: 20),
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

  // ── Iniciales para el avatar ───────────────────────────────────────────────
  String get _initials {
    final n = nombre.text.trim();
    if (n.isEmpty) return "?";
    final parts = n.split(" ");
    if (parts.length >= 2) {
      return "${parts[0][0]}${parts[1][0]}".toUpperCase();
    }
    return n[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,

      // ── AppBar ──────────────────────────────────────────────────────────────
      appBar: AppBar(
        backgroundColor: _surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: _textPri,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Editar perfil",
          style: TextStyle(
            color: _textPri,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: _border),
        ),
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [

            // ── Header con avatar ─────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32),
              color: _surface,
              child: Column(
                children: [
                  // Avatar con iniciales animado al cambiar nombre
                  AnimatedBuilder(
                    animation: nombre,
                    builder: (_, __) => Container(
                      width: 76,
                      height: 76,
                      decoration: BoxDecoration(
                        color: _accent.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: _accent.withOpacity(0.35),
                          width: 1.5,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          _initials,
                          style: const TextStyle(
                            color: _accent,
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  const Text(
                    "Actualizar perfil",
                    style: TextStyle(
                      color: _textPri,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Los cambios se guardan en tu cuenta",
                    style: TextStyle(
                      color: _textSec,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            // ── Formulario ────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // ── Datos personales ──────────────────────────────────────
                    _SectionHeader(title: "Datos personales"),
                    const SizedBox(height: 12),

                    _FieldLabel(text: "Nombre completo"),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: nombre,
                      validator: (v) => validarTexto(v!, "Nombre"),
                      style: const TextStyle(color: _textPri, fontSize: 15),
                      decoration: _inputDecoration(
                        hint: "Tu nombre completo",
                        icon: Icons.person_outline_rounded,
                      ),
                    ),

                    const SizedBox(height: 16),

                    _FieldLabel(text: "Teléfono personal"),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: telefono,
                      keyboardType: TextInputType.phone,
                      validator: (v) => validarTelefono(v!),
                      style: const TextStyle(color: _textPri, fontSize: 15),
                      decoration: _inputDecoration(
                        hint: "10 dígitos",
                        icon: Icons.phone_outlined,
                      ),
                    ),

                    const SizedBox(height: 28),
                    _SectionDivider(),

                    // ── Datos del negocio ─────────────────────────────────────
                    _SectionHeader(title: "Datos del negocio"),
                    const SizedBox(height: 12),

                    _FieldLabel(text: "Nombre del negocio"),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: negocio,
                      validator: (v) => validarTexto(v!, "Negocio"),
                      style: const TextStyle(color: _textPri, fontSize: 15),
                      decoration: _inputDecoration(
                        hint: "Nombre de tu negocio",
                        icon: Icons.store_outlined,
                      ),
                    ),

                    const SizedBox(height: 16),

                    _FieldLabel(text: "Teléfono del negocio"),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: telNegocio,
                      keyboardType: TextInputType.phone,
                      validator: (v) => validarTelefono(v!),
                      style: const TextStyle(color: _textPri, fontSize: 15),
                      decoration: _inputDecoration(
                        hint: "10 dígitos",
                        icon: Icons.business_outlined,
                      ),
                    ),

                    const SizedBox(height: 16),

                    _FieldLabel(text: "Dirección completa"),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: ubicacion,
                      validator: (v) => validarTexto(v!, "Ubicación"),
                      style: const TextStyle(color: _textPri, fontSize: 15),
                      decoration: _inputDecoration(
                        hint: "Calle, número, colonia, ciudad",
                        icon: Icons.location_on_outlined,
                      ),
                    ),

                    const SizedBox(height: 36),

                    // ── Botón guardar ─────────────────────────────────────────
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: loading ? null : actualizar,
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
                          "Guardar cambios",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── Botón cancelar ────────────────────────────────────────
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          foregroundColor: _textSec,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                            side: const BorderSide(color: _border, width: 1),
                          ),
                        ),
                        child: const Text(
                          "Cancelar",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Widgets auxiliares (mismo sistema que RegisterScreen) ─────────────────────

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