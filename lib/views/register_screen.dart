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

  final nombreController = TextEditingController();
  final telefonoController = TextEditingController();
  final negocioController = TextEditingController();
  final telNegocioController = TextEditingController();
  final ubicacionController = TextEditingController();
  final emailController = TextEditingController();
  final passController = TextEditingController();

  bool loading = false;
  bool obscurePass = true;

  String? validarNombre(String? value) {
    if (value == null || value.trim().isEmpty) return "Ingresa tu nombre";
    if (value.length < 3) return "Muy corto";
    return null;
  }

  String? validarTelefono(String? value) {
    if (value == null || value.isEmpty) return "Ingresa teléfono";
    if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) {
      return "Debe tener 10 dígitos";
    }
    return null;
  }

  String? validarEmail(String? value) {
    if (value == null || value.isEmpty) return "Ingresa correo";
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
      return "Correo inválido";
    }
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
      case 'email-already-in-use':
        return "Este correo ya está registrado";
      case 'invalid-email':
        return "Correo inválido";
      case 'weak-password':
        return "Contraseña débil";
      default:
        return "Error al registrar";
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
        "nombre": nombreController.text.trim(),
        "telefono": telefonoController.text.trim(),
        "negocio": negocioController.text.trim(),
        "telefono_negocio": telNegocioController.text.trim(),
        "ubicacion": ubicacionController.text.trim(),
        "email": emailController.text.trim(),
        "created_at": FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cuenta creada correctamente 🚀")),
      );

      Navigator.pop(context);

    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mapError(e))),
      );
    }

    setState(() => loading = false);
  }

  InputDecoration input(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      appBar: AppBar(
        title: const Text("Crear cuenta"),
        elevation: 0,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [

              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Column(
                  children: [

                    TextFormField(
                      controller: nombreController,
                      validator: validarNombre,
                      decoration: input("Nombre Completo", Icons.person),
                    ),

                    const SizedBox(height: 15),

                    TextFormField(
                      controller: telefonoController,
                      keyboardType: TextInputType.phone,
                      validator: validarTelefono,
                      decoration: input("Teléfono", Icons.phone),
                    ),

                    const SizedBox(height: 15),

                    TextFormField(
                      controller: negocioController,
                      validator: validarNombre,
                      decoration: input("Nombre del negocio", Icons.store),
                    ),

                    const SizedBox(height: 15),

                    TextFormField(
                      controller: telNegocioController,
                      keyboardType: TextInputType.phone,
                      validator: validarTelefono,
                      decoration: input("Teléfono del negocio", Icons.storefront),
                    ),

                    const SizedBox(height: 15),

                    TextFormField(
                      controller: ubicacionController,
                      validator: validarNombre,
                      decoration: input("Direccion Completa", Icons.location_on),
                    ),

                    const SizedBox(height: 15),

                    TextFormField(
                      controller: emailController,
                      validator: validarEmail,
                      decoration: input("Correo", Icons.email),
                    ),

                    const SizedBox(height: 15),

                    TextFormField(
                      controller: passController,
                      obscureText: obscurePass,
                      validator: validarPassword,
                      decoration: input("Contraseña", Icons.lock).copyWith(
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscurePass
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() => obscurePass = !obscurePass);
                          },
                        ),
                      ),
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
            ],
          ),
        ),
      ),
    );
  }
}