import 'package:flutter/material.dart';

class PacienteScreen extends StatelessWidget {
  const PacienteScreen({super.key});

  final List<String> options = const [
    'Registro de Crisis',
    'Registro de Eventos Adversos',
    'Diario de Crisis',
    'Diario de Eventos Adversos',
    'Alertas',
    'Conoce mejor tu enfermedad',
    'Configuración',
  ];

  final List<IconData> icons = const [
    Icons.add_alert_outlined,               // Registro de Crisis
    Icons.sentiment_dissatisfied_outlined,  // Registro de Eventos Adversos
    Icons.calendar_today_outlined,          // Diario de Crisis
    Icons.event_note_outlined,              // Diario de Eventos Adversos
    Icons.notifications_active_outlined,    // Alertas
    Icons.info_outline,                     // Conoce mejor tu enfermedad
    Icons.settings_outlined,                // Configuración
  ];

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF26A69A);

    return Scaffold(
      backgroundColor: const Color(0xFFE6F4F1),
      appBar: AppBar(
        title: const Text(
          'Panel del Paciente',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          children: [
            const Icon(Icons.health_and_safety_outlined,
                size: 80, color: primaryColor),
            const SizedBox(height: 20),
            const Text(
              'Bienvenido. Aquí puedes registrar, consultar y editar tu evolución.',
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black87),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            Expanded(
              child: ListView.separated(
                itemCount: options.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  return ElevatedButton.icon(
                    onPressed: () {
                      // Acción vacía para evitar errores
                    },
                    icon: Icon(icons[index], size: 24, color: Colors.white),
                    label: Text(
                      options[index],
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      padding: const EdgeInsets.symmetric(
                          vertical: 14, horizontal: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.centerLeft,
                      elevation: 2,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
