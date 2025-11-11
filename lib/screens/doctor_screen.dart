import 'package:flutter/cupertino.dart';

// Pantalla básica para el rol Doctor.
// Aquí más adelante mostraré lista de pacientes, reportes, etc.
class DoctorScreen extends StatelessWidget {
  const DoctorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text("Doctor"),
      ),
      child: SafeArea(
        child: Center(
          child: Text(
            "Bienvenido, Doctor",
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
