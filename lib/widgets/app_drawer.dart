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

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  void loadUser() async {
    final data = await userController.getUserData();
    setState(() => userData = data);
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(
              color: Color(0xFF1565C0),
            ),
            accountName: Text(userData?['nombre'] ?? 'Invitado'),
            accountEmail: Text(userData?['email'] ?? ''),
            currentAccountPicture: const CircleAvatar(
              child: Icon(Icons.person),
            ),
          ),

          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text("Actualizar cuenta"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const UpdateProfileScreen(),
                  ),
                );
              },
          ),

          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text("Eliminar cuenta"),
            onTap: () async {
              final passwordController = TextEditingController();
              bool obscure = true;

              final confirm = await showDialog(
                context: context,
                builder: (context) {
                  return StatefulBuilder(
                    builder: (context, setState) {
                      return AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        title: const Text(
                          "Eliminar cuenta",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              "⚠️ Esta acción es permanente.\nIngresa tu contraseña para continuar.",
                              style: TextStyle(fontSize: 14),
                            ),
                            const SizedBox(height: 15),

                            TextField(
                              controller: passwordController,
                              obscureText: obscure,
                              decoration: InputDecoration(
                                labelText: "Contraseña",
                                prefixIcon: const Icon(Icons.lock),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    obscure ? Icons.visibility : Icons.visibility_off,
                                  ),
                                  onPressed: () {
                                    setState(() => obscure = !obscure);
                                  },
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text("Cancelar"),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text("Eliminar"),
                          ),
                        ],
                      );
                    },
                  );
                },
              );

              if (confirm == true) {
                final email = FirebaseAuth.instance.currentUser?.email;

                if (email == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Error: usuario inválido")),
                  );
                  return;
                }

                final error = await userController.deleteAccount(
                  email,
                  passwordController.text.trim(),
                );

                if (error != null) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text(error)));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Cuenta eliminada correctamente")),
                  );

                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                        (route) => false,
                  );
                }
              }
            },
          ),

          const Divider(),

          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text("Cerrar sesión"),
            onTap: () async {
              await auth.logout();
            },
          ),
        ],
      ),
    );
  }
}