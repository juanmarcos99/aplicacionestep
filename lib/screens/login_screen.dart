import 'package:flutter/material.dart';
import '../database/db_helper.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscurePassword = true;
  final _userController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  "Epilepsia App",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2E7D7D),
                  ),
                ),
                const SizedBox(height: 40),

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

                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: "Contraseña",
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey.shade600,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D7D),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () async {
                    // Capturo el context actual en una variable local
                    final ctx = context;

                    // Valido usuario y contraseña contra la BD
                    final ok = await DBHelper.validateLogin(
                      _userController.text,
                      _passwordController.text,
                    );

                    // Verifico que el widget sigue montado
                    if (!mounted) return;

                    if (ok) {
                      if (_userController.text.trim() == "Paciente") {
                        // ignore: use_build_context_synchronously
                        Navigator.pushNamed(ctx, "/paciente");
                      } else if (_userController.text.trim() == "Doctor") {
                        // ignore: use_build_context_synchronously
                        Navigator.pushNamed(ctx, "/doctor");
                      }
                    } else {
                      showDialog(
                        // ignore: use_build_context_synchronously
                        context: ctx,
                        builder: (_) => AlertDialog(
                          title: const Text("Error de acceso"),
                          content: const Text("Usuario o contraseña incorrectos."),
                          actions: [
                            TextButton(
                              child: const Text("OK"),
                              onPressed: () => Navigator.pop(ctx),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                  child: const Text(
                    "Acceder",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),

                const SizedBox(height: 20),

                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, "/cambiarPassword");
                  },
                  child: const Text(
                    "¿Olvidaste tu contraseña?",
                    style: TextStyle(color: Colors.grey),
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
