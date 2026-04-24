import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nombreController = TextEditingController();
  final telefonoController = TextEditingController();
  final negocioController = TextEditingController();
  final telNegocioController = TextEditingController();
  final ubicacionController = TextEditingController();
  final emailController = TextEditingController();
  final passController = TextEditingController();

  bool loading = false;

  Future<void> register() async {
    setState(() => loading = true);

    try {
      // 🔐 Crear usuario
      UserCredential user = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passController.text.trim(),
      );

      // 💾 Guardar datos en Firestore
      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.user!.uid)
          .set({
        "nombre": nombreController.text.trim(),
        "telefono": telefonoController.text.trim(),
        "negocio": negocioController.text.trim(),
        "telefono_negocio": telNegocioController.text.trim(),
        "ubicacion": ubicacionController.text.trim(),
        "email": emailController.text.trim(),
        "created_at": FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Registro exitoso 🔥")),
      );

      Navigator.pop(context);

    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? "Error")),
      );
    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Crear cuenta")),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            TextField(
              controller: nombreController,
              decoration: const InputDecoration(labelText: "Nombre"),
            ),

            TextField(
              controller: telefonoController,
              decoration: const InputDecoration(labelText: "Teléfono"),
            ),

            TextField(
              controller: negocioController,
              decoration: const InputDecoration(labelText: "Nombre del negocio"),
            ),

            TextField(
              controller: telNegocioController,
              decoration: const InputDecoration(labelText: "Teléfono del negocio"),
            ),

            TextField(
              controller: ubicacionController,
              decoration: const InputDecoration(labelText: "Ubicación"),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "Correo"),
            ),

            TextField(
              controller: passController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Contraseña"),
            ),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: loading ? null : register,
                child: loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Registrarse"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}