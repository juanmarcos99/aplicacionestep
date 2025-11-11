import 'package:flutter/material.dart';
import '../database/db_helper.dart';

class CambiarContrasenaScreen extends StatefulWidget {
  const CambiarContrasenaScreen({super.key});

  @override
  State<CambiarContrasenaScreen> createState() => _CambiarContrasenaScreenState();
}

class _CambiarContrasenaScreenState extends State<CambiarContrasenaScreen> {
  final _userController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Cambiar contraseña"),
        backgroundColor: const Color(0xFF2E7D7D),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Usuario
                TextField(
                  controller: _userController,
                  decoration: InputDecoration(
                    labelText: "Usuario",
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Contraseña actual
                TextField(
                  controller: _currentPasswordController,
                  obscureText: _obscureCurrent,
                  decoration: InputDecoration(
                    labelText: "Contraseña actual",
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureCurrent ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey.shade600,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureCurrent = !_obscureCurrent;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Contraseña nueva
                TextField(
                  controller: _newPasswordController,
                  obscureText: _obscureNew,
                  decoration: InputDecoration(
                    labelText: "Contraseña nueva",
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureNew ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey.shade600,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureNew = !_obscureNew;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Rectificar contraseña nueva
                TextField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirm,
                  decoration: InputDecoration(
                    labelText: "Repetir contraseña nueva",
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirm ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey.shade600,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirm = !_obscureConfirm;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // Botón Cambiar contraseña
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D7D),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () async {
                    final user = _userController.text.trim();
                    final currentPass = _currentPasswordController.text;
                    final newPass = _newPasswordController.text;
                    final confirmPass = _confirmPasswordController.text;

                    if (newPass != confirmPass) {
                      if (!mounted) return;
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text("Error"),
                          content: const Text("Las contraseñas nuevas no coinciden."),
                          actions: [
                            TextButton(
                              child: const Text("OK"),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                      );
                      return;
                    }

                    final valid = await DBHelper.validateLogin(user, currentPass);
                    if (!mounted) return;

                    if (valid) {
                      await DBHelper.changePassword(user, newPass);
                      showDialog(
                        // ignore: use_build_context_synchronously
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text("Éxito"),
                          content: const Text("Contraseña cambiada correctamente."),
                          actions: [
                            TextButton(
                              child: const Text("OK"),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                      );
                    } else {
                      showDialog(
                        // ignore: use_build_context_synchronously
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text("Error"),
                          content: const Text("Usuario o contraseña actual incorrectos."),
                          actions: [
                            TextButton(
                              child: const Text("OK"),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                  child: const Text(
                    "Cambiar contraseña",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
