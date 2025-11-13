import 'package:aplicacionestep/database/crisis_dao.dart';
import 'package:aplicacionestep/database/crisis_detalle_dao.dart';
import 'package:aplicacionestep/models/crisis.dart';
import 'package:flutter/material.dart';
import 'package:aplicacionestep/models/crisis_detalle.dart';


class RegistroCrisisScreen extends StatefulWidget {
  const RegistroCrisisScreen({super.key});

  @override
  State<RegistroCrisisScreen> createState() => _RegistroCrisisScreenState();
}

class _RegistroCrisisScreenState extends State<RegistroCrisisScreen> {
  DateTime fecha = DateTime.now();
  String? horario;

  final List<String> horarios = [
    '6:00 am - 10:00 am',
    '10:00 am - 2:00 pm',
    '2:00 pm - 6:00 pm',
    '6:00 pm - 10:00 pm',
    '10:00 pm - 6:00 am',
  ];

  final List<String> tiposCrisis = [
    'Focales conscientes',
    'Focales inconscientes',
    'Tónico-clónico bilateral',
  ];

  // Controladores para los tipos predefinidos
  final Map<String, TextEditingController> crisisControllers = {};

  // Lista dinámica de pares (descripcion + cantidad)
  final List<Map<String, TextEditingController>> otrosCampos = [];

  @override
  void initState() {
    super.initState();
    for (var tipo in tiposCrisis) {
      crisisControllers[tipo] = TextEditingController();
    }
  }

  // Función para limpiar texto
  String sanitizeText(String input) {
    return input
        .replaceAll('–', '-') // guiones largos → simples
        .replaceAll('—', '-') 
        .replaceAll(RegExp(r'[“”]'), '"')
        .replaceAll(RegExp(r"[‘’]"), "'")
        .replaceAll(RegExp(r'[^\x00-\x7F]'), '') // elimina emojis
        .trim();
  }

  Future<void> guardarCrisis() async {
    if (horario == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Selecciona un horario")),
      );
      return;
    }

    // 1. Insertar crisis principal
    final crisis = Crisis(
      fechaCrisis: fecha,
      fechaRegistro: DateTime.now(),
    );
    final crisisId = await CrisisDao.insertCrisis(crisis);

    // 2. Insertar detalles predefinidos
    for (var tipo in tiposCrisis) {
      final valor = crisisControllers[tipo]!.text.trim();
      if (valor.isNotEmpty) {
        final detalle = CrisisDetalle(
          crisisId: crisisId,
          horario: sanitizeText(horario!),
          tipo: sanitizeText(tipo),
          cantidad: int.tryParse(valor) ?? 0,
        );
        await CrisisDetalleDao.insertDetalle(detalle);
      }
    }

    // 3. Insertar detalles dinámicos
    for (var campo in otrosCampos) {
      final descripcion = campo['descripcion']!.text.trim();
      final cantidad = campo['cantidad']!.text.trim();
      if (descripcion.isNotEmpty && cantidad.isNotEmpty) {
        final detalle = CrisisDetalle(
          crisisId: crisisId,
          horario: sanitizeText(horario!),
          tipo: sanitizeText(descripcion),
          cantidad: int.tryParse(cantidad) ?? 0,
        );
        await CrisisDetalleDao.insertDetalle(detalle);
      }
    }

    // 4. Confirmación visual
    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Crisis registrada correctamente")),
    );
    // ignore: use_build_context_synchronously
    Navigator.pop(context); // opcional: volver atrás
  }

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
            // ---------------- Fecha ----------------
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
                );
                if (picked != null) setState(() => fecha = picked);
              },
            ),
            const SizedBox(height: 20),

            // ---------------- Horario ----------------
            const Text('Horario del episodio', style: TextStyle(fontSize: 16)),
            DropdownButtonFormField<String>(
              initialValue: horario,
              items: horarios.map((h) {
                return DropdownMenuItem(value: h, child: Text(h));
              }).toList(),
              onChanged: (value) => setState(() => horario = value),
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
            const SizedBox(height: 30),

            // ---------------- Tipos predefinidos ----------------
            const Text('Cantidad de crisis por tipo',
                style: TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            for (var tipo in tiposCrisis)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: TextFormField(
                  controller: crisisControllers[tipo],
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: tipo,
                    border: const OutlineInputBorder(),
                  ),
                ),
              ),

            // ---------------- Campos dinámicos ----------------
            const SizedBox(height: 20),
            const Text('Otros tipos de crisis',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            for (var i = 0; i < otrosCampos.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: otrosCampos[i]['descripcion'],
                        decoration: const InputDecoration(
                          labelText: "Descripción",
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 1,
                      child: TextFormField(
                        controller: otrosCampos[i]['cantidad'],
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: "Cantidad",
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          otrosCampos.removeAt(i);
                        });
                      },
                    ),
                  ],
                ),
              ),

            TextButton.icon(
              onPressed: () {
                setState(() {
                  otrosCampos.add({
                    "descripcion": TextEditingController(),
                    "cantidad": TextEditingController(),
                  });
                });
              },
              icon: const Icon(Icons.add, color: primaryColor),
              label: const Text("Añadir otro tipo"),
            ),

            const SizedBox(height: 20),

            // ---------------- Botón Guardar ----------------
            ElevatedButton.icon(
              onPressed: guardarCrisis,
              icon: const Icon(Icons.save, color: Colors.white),
              label: const Text("Guardar"),
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
