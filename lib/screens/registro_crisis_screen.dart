import 'package:flutter/material.dart';

class RegistroCrisisScreen extends StatefulWidget {
  const RegistroCrisisScreen({super.key});

  @override
  State<RegistroCrisisScreen> createState() => _RegistroCrisisScreenState();
}

class _RegistroCrisisScreenState extends State<RegistroCrisisScreen> {
  DateTime fecha = DateTime.now();
  String? horario;

  final List<String> horarios = [
    '6:00 am – 10:00 am',
    '10:00 am – 2:00 pm',
    '2:00 pm – 6:00 pm',
    '6:00 pm – 10:00 pm',
    '10:00 pm – 6:00 am',
  ];

  final List<String> tiposCrisis = [
    'Focales conscientes',
    'Focales inconscientes',
    'Tónico-clónico bilateral',
    'Otro tipo',
  ];

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF26A69A);

    return Scaffold(
      backgroundColor: const Color(0xFFE6F4F1),
      appBar: AppBar(
        title: const Text(
          'Registro de Crisis',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: ListView(
          children: [
            const Text('Fecha del episodio', style: TextStyle(fontSize: 16)),
            ListTile(
              title: Text('${fecha.toLocal()}'.split(' ')[0]),
              trailing: const Icon(Icons.calendar_month_outlined,
                  color: primaryColor),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: fecha,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: const ColorScheme.light(
                          primary: primaryColor,
                          onPrimary: Colors.white,
                          onSurface: Colors.black87,
                        ),
                        textButtonTheme: TextButtonThemeData(
                          style: TextButton.styleFrom(
                            foregroundColor: primaryColor,
                          ),
                        ),
                      ),
                      child: child!,
                    );
                  },
                );
                if (picked != null) {
                  setState(() => fecha = picked);
                }
              },
            ),
            const SizedBox(height: 20),

            const Text('Horario del episodio', style: TextStyle(fontSize: 16)),
            DropdownButtonFormField<String>(
              initialValue: horario,
              items: horarios.map((h) {
                return DropdownMenuItem(value: h, child: Text(h));
              }).toList(),
              onChanged: (value) {
                setState(() => horario = value);
              },
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFE6F4F1),
                border: OutlineInputBorder(
                  borderSide: const BorderSide(color: primaryColor),
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: primaryColor),
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: primaryColor, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              dropdownColor: const Color(0xFFE6F4F1),
              iconEnabledColor: primaryColor,
              style: const TextStyle(color: Colors.black),
            ),
            const SizedBox(height: 30),

            const Text('Cantidad de crisis por tipo',
                style: TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            for (var tipo in tiposCrisis)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: TextFormField(
                  keyboardType: tipo == 'Otro tipo'
                      ? TextInputType.multiline
                      : TextInputType.number,
                  maxLines: tipo == 'Otro tipo' ? 3 : 1, // 👈 aquí el cambio
                  decoration: InputDecoration(
                    labelText: tipo,
                    border: const OutlineInputBorder(),
                  ),
                ),
              ),
            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: () {
                // Acción vacía, solo visual
              },
              icon: const Icon(Icons.save, color: Colors.white),
              label: const Text(
                'Guardar',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
