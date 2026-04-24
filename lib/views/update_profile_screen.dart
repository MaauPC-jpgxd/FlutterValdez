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

  final nombre = TextEditingController();
  final telefono = TextEditingController();
  final negocio = TextEditingController();
  final telNegocio = TextEditingController();
  final ubicacion = TextEditingController();

  bool loading = false;

  @override
  void initState() {
    super.initState();
    cargarDatos();
  }

  void cargarDatos() async {
    final data = await controller.getUserData();

    if (data != null) {
      nombre.text = data['nombre'] ?? '';
      telefono.text = data['telefono'] ?? '';
      negocio.text = data['negocio'] ?? '';
      telNegocio.text = data['telefono_negocio'] ?? '';
      ubicacion.text = data['ubicacion'] ?? '';
    }
  }

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
      nombre: nombre.text.trim(),
      telefono: telefono.text.trim(),
      negocio: negocio.text.trim(),
      telefonoNegocio: telNegocio.text.trim(),
      ubicacion: ubicacion.text.trim(),
    );

    setState(() => loading = false);

    if (error != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error)));
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Datos actualizados correctamente ✅")),
    );

    Navigator.pop(context);
  }

  InputDecoration inputStyle(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: const Color(0xFF1565C0)),
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
      body: Column(
        children: [

          // 🔵 HEADER PRO
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 60, bottom: 30),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              children: const [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 40, color: Color(0xFF1565C0)),
                ),
                SizedBox(height: 10),
                Text(
                  "Actualizar perfil",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // 🔽 FORM
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [

                    TextFormField(
                      controller: nombre,
                      validator: (v) => validarTexto(v!, "Nombre"),
                      decoration: inputStyle("Nombre", Icons.person),
                    ),

                    const SizedBox(height: 15),

                    TextFormField(
                      controller: telefono,
                      keyboardType: TextInputType.phone,
                      validator: (v) => validarTelefono(v!),
                      decoration: inputStyle("Teléfono", Icons.phone),
                    ),

                    const SizedBox(height: 15),

                    TextFormField(
                      controller: negocio,
                      validator: (v) => validarTexto(v!, "Negocio"),
                      decoration: inputStyle("Negocio", Icons.store),
                    ),

                    const SizedBox(height: 15),

                    TextFormField(
                      controller: telNegocio,
                      keyboardType: TextInputType.phone,
                      validator: (v) => validarTelefono(v!),
                      decoration:
                      inputStyle("Teléfono negocio", Icons.business),
                    ),

                    const SizedBox(height: 15),

                    TextFormField(
                      controller: ubicacion,
                      validator: (v) => validarTexto(v!, "Ubicación"),
                      decoration:
                      inputStyle("Ubicación", Icons.location_on),
                    ),

                    const SizedBox(height: 30),

                    // 🔥 BOTÓN PRO
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: loading ? null : actualizar,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1565C0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 5,
                        ),
                        child: loading
                            ? const CircularProgressIndicator(
                            color: Colors.white)
                            : const Text(
                          "Guardar cambios",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}