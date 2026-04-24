import 'package:flutter/material.dart';
import '../controllers/auth_controller.dart';
import '../controllers/user_controller.dart';
import '../views/update_profile_screen.dart';
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
              final confirm = await showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text("¿Eliminar cuenta?"),
                  content: const Text("Esta acción no se puede deshacer"),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text("Cancelar")),
                    TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text("Eliminar")),
                  ],
                ),
              );

              if (confirm == true) {
                final error = await userController.deleteAccount();

                if (error != null) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text(error)));
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