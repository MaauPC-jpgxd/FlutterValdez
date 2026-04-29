import 'package:flutter/material.dart';
import '../controllers/auth_controller.dart';
import 'login_screen.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen>
    with SingleTickerProviderStateMixin {
  final controller = AuthController();

  late AnimationController _animController;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;

  // ── Colores ────────────────────────────────────────────────────────────────
  static const _bg         = Color(0xFF0A0E1A);
  static const _surface    = Color(0xFF111827);
  static const _surfaceAlt = Color(0xFF1C2333);
  static const _accent     = Color(0xFF2563EB);
  static const _textPri    = Color(0xFFF1F5F9);
  static const _textSec    = Color(0xFF94A3B8);
  static const _border     = Color(0xFF1E293B);

  @override
  void initState() {
    super.initState();

    // Animación de entrada
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _scaleAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutBack,
    );

    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeIn,
    );

    _animController.forward();

    // 🔥 ESCUCHAR SI EL USUARIO YA VERIFICÓ
    controller.startEmailVerificationCheck(
      onVerified: () {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Correo verificado ✅"),
            backgroundColor: const Color(0xFF16A34A),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        );

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
              (route) => false,
        );
      },
    );
  }

  @override
  void dispose() {
    // 🧹 MUY IMPORTANTE (evita memory leaks)
    _animController.dispose();
    controller.stopEmailCheck();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: FadeTransition(
            opacity: _fadeAnim,
            child: Column(
              children: [
                const Spacer(flex: 2),

                // ── Ícono animado ─────────────────────────────────────────────
                ScaleTransition(
                  scale: _scaleAnim,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Anillo exterior decorativo
                      Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          color: _accent.withOpacity(0.07),
                          borderRadius: BorderRadius.circular(32),
                          border: Border.all(
                            color: _accent.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                      ),
                      // Contenedor principal
                      Container(
                        width: 82,
                        height: 82,
                        decoration: BoxDecoration(
                          color: _accent.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: _accent.withOpacity(0.35),
                            width: 1.5,
                          ),
                        ),
                        child: const Icon(
                          Icons.mark_email_read_outlined,
                          color: _accent,
                          size: 36,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // ── Título ────────────────────────────────────────────────────
                const Text(
                  "Cuenta creada 🎉",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _textPri,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  "Ya casi terminas",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _textSec,
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: 32),

                // ── Card de instrucciones ─────────────────────────────────────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: _surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _border, width: 1),
                  ),
                  child: Column(
                    children: [
                      _Step(
                        number: "1",
                        text: "Revisa tu bandeja de entrada",
                        icon: Icons.inbox_outlined,
                      ),
                      const SizedBox(height: 14),
                      _Divider(),
                      const SizedBox(height: 14),
                      _Step(
                        number: "2",
                        text: "Revisa también tu carpeta de SPAM",
                        icon: Icons.folder_outlined,
                      ),
                      const SizedBox(height: 14),
                      _Divider(),
                      const SizedBox(height: 14),
                      _Step(
                        number: "3",
                        text: "Haz clic en el enlace del correo",
                        icon: Icons.touch_app_outlined,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // ── Indicador de espera ───────────────────────────────────────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: _surfaceAlt,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _border, width: 1),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                          AlwaysStoppedAnimation<Color>(
                              _accent.withOpacity(0.7)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        "Esperando verificación automática...",
                        style: TextStyle(
                          color: _textSec,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(flex: 2),

                // ── Botón volver ──────────────────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () async {
                      await controller.logout();

                      if (!mounted) return;

                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const LoginScreen()),
                            (route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _accent,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      "Volver al inicio de sesión",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.1,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // ── Texto informativo ─────────────────────────────────────────
                const Text(
                  "Una vez verificado podrás iniciar sesión",
                  style: TextStyle(
                    color: _textSec,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Widgets auxiliares ────────────────────────────────────────────────────────

class _Step extends StatelessWidget {
  final String number;
  final String text;
  final IconData icon;

  const _Step({
    required this.number,
    required this.text,
    required this.icon,
  });

  static const _accent  = Color(0xFF2563EB);
  static const _textPri = Color(0xFFF1F5F9);
  static const _textSec = Color(0xFF94A3B8);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Número
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: _accent.withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _accent.withOpacity(0.25),
              width: 1,
            ),
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: _accent,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),
        // Ícono
        Icon(icon, color: _textSec, size: 18),
        const SizedBox(width: 10),
        // Texto
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: _textPri,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Divider(
      color: Color(0xFF1E293B),
      height: 1,
      thickness: 1,
    );
  }
}