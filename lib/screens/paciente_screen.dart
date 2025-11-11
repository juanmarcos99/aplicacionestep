import 'package:flutter/cupertino.dart';

// Pantalla básica para el rol Paciente.
// Aquí más adelante mostraré las crisis registradas, estadísticas, etc.
class PacienteScreen extends StatelessWidget {
  const PacienteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text("Paciente"),
      ),
      child: SafeArea(
        child: Center(
          child: Text(
            "Bienvenido, Paciente",
            style: TextStyle(
              fontSize: 20,
              color: const Color(0xFF2E7D7D), // Color clínico
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
