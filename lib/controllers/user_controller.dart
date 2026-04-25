import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserController {
  final user = FirebaseAuth.instance.currentUser;

  Future<Map<String, dynamic>?> getUserData() async {
    if (user == null) return null;

    final doc = await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(user!.uid)
        .get();

    return doc.data();
  }

  Future<String?> updateUser({
    required String nombre,
    required String telefono,
    required String negocio,
    required String telefonoNegocio,
    required String ubicacion,
  }) async {
    try {
      if (user == null) return "Sesión inválida";

      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user!.uid)
          .update({
        "nombre": nombre,
        "telefono": telefono,
        "negocio": negocio,
        "telefono_negocio": telefonoNegocio,
        "ubicacion": ubicacion,
        "updated_at": FieldValue.serverTimestamp(),
      });

      return null;
    } catch (e) {
      return "Error al actualizar datos";
    }
  }
  Future<String?> deleteAccount(String email, String password) async {
    try {
      if (user == null) return "Sesión inválida";

      // 🔐 REAUTENTICACIÓN OBLIGATORIA
      final credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );

      await user!.reauthenticateWithCredential(credential);

      // 🗑️ BORRAR DATOS
      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user!.uid)
          .delete();

      await user!.delete();

      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        return "Contraseña incorrecta";
      } else if (e.code == 'requires-recent-login') {
        return "Vuelve a iniciar sesión para eliminar la cuenta";
      }
      return "Error de autenticación";
    } catch (e) {
      return "No se pudo eliminar la cuenta";
    }
  }
}