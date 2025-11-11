import 'package:flutter/material.dart';
import 'screens/login_screen.dart'; // Importo la pantalla de login
import 'screens/paciente_screen.dart';
import 'screens/doctor_screen.dart';
import 'screens/cambiar_contrasena_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Quita la etiqueta de debug
      title: '',
      theme: ThemeData(
        primaryColor: const Color(0xFF2E7D7D), // Color médico principal
      ),
      // Defino las rutas de la app
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/paciente': (context) => const PacienteScreen(),
        '/doctor': (context) => const DoctorScreen(),
        '/cambiarcontrasena': (context) => const CambiarContrasenaScreen(),
      },
    );
  }
}
