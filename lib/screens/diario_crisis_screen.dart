import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:aplicacionestep/database/crisis_dao.dart';
import 'package:aplicacionestep/database/crisis_detalle_dao.dart';
import 'package:aplicacionestep/models/crisis_detalle.dart';
import 'pdf_screen.dart'; // 👈 Importa la nueva pantalla

class DiarioCrisisScreen extends StatefulWidget {
  const DiarioCrisisScreen({super.key});

  @override
  State<DiarioCrisisScreen> createState() => _DiarioCrisisScreenState();
}

class _DiarioCrisisScreenState extends State<DiarioCrisisScreen> {
  DateTime fechaSeleccionada = DateTime.now();

  Map<String, List<CrisisDetalle>> crisisPorHorario = {};

  @override
  void initState() {
    super.initState();
    cargarDatos();
  }

  Future<void> seleccionarFecha() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: fechaSeleccionada,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      helpText: 'Selecciona una fecha específica',
    );
    if (picked != null) {
      setState(() => fechaSeleccionada = picked);
      await cargarDatos();
    }
  }

  Future<void> cargarDatos() async {
    final fechaTexto = DateFormat('yyyy-MM-dd').format(fechaSeleccionada);

    final crisisList = await CrisisDao.getAllCrisis();

    final crisisDelDia = crisisList.where((c) {
      final fechaCrisisTexto = DateFormat('yyyy-MM-dd').format(c.fechaCrisis);
      return fechaCrisisTexto == fechaTexto;
    }).toList();

    Map<String, List<CrisisDetalle>> agrupados = {};

    for (var crisis in crisisDelDia) {
      final detalles = await CrisisDetalleDao.getDetallesByCrisis(crisis.id!);
      for (var d in detalles) {
        agrupados.putIfAbsent(d.horario, () => []);
        agrupados[d.horario]!.add(d);
      }
    }

    setState(() {
      crisisPorHorario = agrupados;
    });
  }

  @override
  Widget build(BuildContext context) {
    final fechaTexto = DateFormat.yMMMMd().format(fechaSeleccionada);
    const Color primaryColor = Color(0xFF26A69A);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Diario de Crisis'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        actions: [
          // 📌 Botón PDF en el AppBar que navega a PdfScreen
          IconButton(
            icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
            tooltip: "Exportar a PDF",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PdfScreen()),
              );
            },
          ),
        ],
      ),
      backgroundColor: const Color(0xFFE6F4F1),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ListTile(
              title: Text('Fecha seleccionada: $fechaTexto'),
              trailing: const Icon(Icons.calendar_today, color: primaryColor),
              onTap: seleccionarFecha,
            ),
            const SizedBox(height: 20),
            Expanded(
              child: crisisPorHorario.isEmpty
                  ? const Center(
                      child: Text('No hay registros para esta fecha'),
                    )
                  : ListView(
                      children: crisisPorHorario.entries.map((entry) {
                        final horario = entry.key;
                        final detalles = entry.value;
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: ListTile(
                            title: Text('🕒 $horario'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: detalles.map((d) {
                                return Text('${d.tipo}: ${d.cantidad}');
                              }).toList(),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
