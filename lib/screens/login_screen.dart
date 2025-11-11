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
    const Color primaryColor = Color(0xFF26A69A);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.medical_services_outlined,
                  size: 80, color: primaryColor),
              const SizedBox(height: 20),
              const Text(
                "Epilepsia App",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 40),

              // Campo Usuario
              TextField(
                controller: _userController,
                decoration: const InputDecoration(
                  labelText: "Usuario",
                  prefixIcon: Icon(Icons.person_outline),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              // Campo Contraseña
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: "Contraseña",
                  prefixIcon: const Icon(Icons.lock_outline),
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
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

              // Botón Acceder
              ElevatedButton.icon(
                onPressed: () async {
                  final ctx = context;
                  final ok = await DBHelper.validateLogin(
                    _userController.text,
                    _passwordController.text,
                  );

                  if (!mounted) return;

                  if (ok) {
                    if (_userController.text.trim().toLowerCase() == "paciente") {
                      // ignore: use_build_context_synchronously
                      Navigator.pushNamed(ctx, "/paciente");
                    } else if (_userController.text.trim().toLowerCase() == "doctor") {
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
                icon: const Icon(Icons.login),
                label: const Text("Entrar"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 20),

              // Botón cambiar contraseña
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, "/cambiarcontrasena");
                },
                child: const Text(
                  "¿Olvidaste tu contraseña?",
                  style: TextStyle(color: primaryColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
