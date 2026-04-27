import 'package:flutter/material.dart';
import '../controllers/auth_controller.dart';
import '../controllers/user_controller.dart';
import '../views/update_profile_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../views/login_screen.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  final userController = UserController();
  final auth = AuthController();

  Map<String, dynamic>? userData;

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
    loadUser();
  }

  void loadUser() async {
    final data = await userController.getUserData();
    setState(() => userData = data);
  }

  // ── Iniciales del nombre para el avatar ────────────────────────────────────
  String _getInitials(String? nombre) {
    if (nombre == null || nombre.trim().isEmpty) return "?";
    final parts = nombre.trim().split(" ");
    if (parts.length >= 2) {
      return "${parts[0][0]}${parts[1][0]}".toUpperCase();
    }
    return nombre[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final nombre  = userData?['nombre'] as String?;
    final email   = userData?['email']  as String?;
    final negocio = userData?['negocio'] as String?;
    final isGuest = nombre == null;

    return Drawer(
      backgroundColor: _bg,
      width: 290,
      child: SafeArea(
        child: Column(
          children: [

            // ── Header ────────────────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
              decoration: const BoxDecoration(
                color: _surface,
                border: Border(
                  bottom: BorderSide(color: _border, width: 1),
                ),
              ),
              child: Row(
                children: [
                  // Avatar con iniciales
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: _accent.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _accent.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: isGuest
                          ? const Icon(Icons.person_outline_rounded,
                          color: _accent, size: 24)
                          : Text(
                        _getInitials(nombre),
                        style: const TextStyle(
                          color: _accent,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 14),

                  // Nombre + email
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          nombre ?? "Invitado",
                          style: const TextStyle(
                            color: _textPri,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (email != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            email,
                            style: const TextStyle(
                              color: _textSec,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        if (negocio != null) ...[
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: _accent.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              negocio,
                              style: const TextStyle(
                                color: _accent,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // ── Items del menú ────────────────────────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  children: [

                    _DrawerItem(
                      icon: Icons.edit_outlined,
                      label: "Actualizar cuenta",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const UpdateProfileScreen(),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 4),

                    _DrawerItem(
                      icon: Icons.delete_outline_rounded,
                      label: "Eliminar cuenta",
                      isDestructive: true,
                      onTap: () async {
                        final passwordController = TextEditingController();
                        bool obscure = true;

                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) {
                            return StatefulBuilder(
                              builder: (context, setStateDialog) {
                                return Dialog(
                                  backgroundColor: _surface,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    side: const BorderSide(
                                        color: _border, width: 1),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(24),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        // Ícono de advertencia
                                        Container(
                                          width: 44,
                                          height: 44,
                                          decoration: BoxDecoration(
                                            color: _errorColor.withOpacity(0.1),
                                            borderRadius:
                                            BorderRadius.circular(12),
                                          ),
                                          child: const Icon(
                                            Icons.warning_amber_rounded,
                                            color: _errorColor,
                                            size: 22,
                                          ),
                                        ),
                                        const SizedBox(height: 16),

                                        const Text(
                                          "Eliminar cuenta",
                                          style: TextStyle(
                                            color: _textPri,
                                            fontSize: 17,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        const Text(
                                          "Esta acción es permanente y no se puede deshacer. Ingresa tu contraseña para confirmar.",
                                          style: TextStyle(
                                            color: _textSec,
                                            fontSize: 13,
                                            height: 1.5,
                                          ),
                                        ),
                                        const SizedBox(height: 20),

                                        // Campo contraseña
                                        TextField(
                                          controller: passwordController,
                                          obscureText: obscure,
                                          style: const TextStyle(
                                              color: _textPri, fontSize: 14),
                                          decoration: InputDecoration(
                                            hintText: "Tu contraseña",
                                            hintStyle: const TextStyle(
                                                color: _textSec, fontSize: 14),
                                            filled: true,
                                            fillColor: _surfaceAlt,
                                            prefixIcon: const Icon(
                                                Icons.lock_outline_rounded,
                                                color: _textSec,
                                                size: 18),
                                            suffixIcon: IconButton(
                                              splashRadius: 18,
                                              icon: Icon(
                                                obscure
                                                    ? Icons.visibility_outlined
                                                    : Icons
                                                    .visibility_off_outlined,
                                                color: _textSec,
                                                size: 18,
                                              ),
                                              onPressed: () => setStateDialog(
                                                      () => obscure = !obscure),
                                            ),
                                            contentPadding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 14,
                                                vertical: 14),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                              BorderRadius.circular(12),
                                              borderSide: const BorderSide(
                                                  color: _border, width: 1),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                              BorderRadius.circular(12),
                                              borderSide: const BorderSide(
                                                  color: _errorColor,
                                                  width: 1.5),
                                            ),
                                          ),
                                        ),

                                        const SizedBox(height: 24),

                                        // Botones
                                        Row(
                                          children: [
                                            Expanded(
                                              child: TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(
                                                        context, false),
                                                style: TextButton.styleFrom(
                                                  foregroundColor: _textSec,
                                                  padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 12),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                    BorderRadius.circular(
                                                        11),
                                                    side: const BorderSide(
                                                        color: _border,
                                                        width: 1),
                                                  ),
                                                ),
                                                child: const Text("Cancelar",
                                                    style: TextStyle(
                                                        fontSize: 14)),
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: ElevatedButton(
                                                onPressed: () =>
                                                    Navigator.pop(
                                                        context, true),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: _errorColor,
                                                  foregroundColor: Colors.white,
                                                  elevation: 0,
                                                  padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 12),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                    BorderRadius.circular(
                                                        11),
                                                  ),
                                                ),
                                                child: const Text("Eliminar",
                                                    style: TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                        FontWeight.w600)),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        );

                        if (confirm == true) {
                          final email =
                              FirebaseAuth.instance.currentUser?.email;

                          if (email == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content:
                                const Text("Error: usuario inválido"),
                                backgroundColor: _errorColor,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                            );
                            return;
                          }

                          final error = await userController.deleteAccount(
                            email,
                            passwordController.text.trim(),
                          );

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
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content:
                                const Text("Cuenta eliminada correctamente"),
                                backgroundColor: const Color(0xFF16A34A),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                            );

                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const LoginScreen()),
                                  (route) => false,
                            );
                          }
                        }
                      },
                    ),

                    // Divider
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Divider(
                          color: _border, thickness: 1, height: 1),
                    ),

                    _DrawerItem(
                      icon: Icons.logout_rounded,
                      label: "Cerrar sesión",
                      onTap: () async {
                        await auth.logout();
                      },
                    ),
                  ],
                ),
              ),
            ),

            // ── Footer con versión ─────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: _accent,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(Icons.store_rounded,
                        color: Colors.white, size: 12),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    "Depósito Valdez",
                    style: TextStyle(
                      color: _textSec,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Item del drawer ───────────────────────────────────────────────────────────
class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  static const _textPri    = Color(0xFFF1F5F9);
  static const _textSec    = Color(0xFF94A3B8);
  static const _surfaceAlt = Color(0xFF1C2333);
  static const _errorColor = Color(0xFFEF4444);
  static const _accent     = Color(0xFF2563EB);

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? _errorColor : _textPri;
    final iconBg = isDestructive
        ? _errorColor.withOpacity(0.1)
        : _surfaceAlt;
    final iconColor = isDestructive ? _errorColor : _textSec;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        splashColor: (isDestructive ? _errorColor : _accent).withOpacity(0.08),
        highlightColor: (isDestructive ? _errorColor : _accent).withOpacity(0.05),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              if (!isDestructive)
                Icon(Icons.chevron_right_rounded,
                    color: _textSec.withOpacity(0.5), size: 18),
            ],
          ),
        ),
      ),
    );
  }
}