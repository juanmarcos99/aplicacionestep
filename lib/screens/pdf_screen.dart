import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';

import '../database/crisis_dao.dart';
import '../database/crisis_detalle_dao.dart';
import '../models/crisis.dart';
import '../models/crisis_detalle.dart';
import '../utils/pdf_generator.dart';
import 'pdf_list_screen.dart'; // 👈 Importa la pantalla de listado

class PdfScreen extends StatefulWidget {
  const PdfScreen({super.key});

  @override
  State<PdfScreen> createState() => _PdfScreenState();
}

class _PdfScreenState extends State<PdfScreen> {
  int? selectedYear;
  int? selectedMonth;
  final TextEditingController nombreController = TextEditingController();

  final List<int> years = List.generate(6, (i) => DateTime.now().year - i);
  final List<String> months = const [
    'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
    'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
  ];

  Future<void> generarPdf() async {
    if (selectedYear == null || selectedMonth == null || nombreController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Completa todos los campos")),
      );
      return;
    }

    final nombreBase = nombreController.text.trim();

    // 1. Obtener crisis del mes/año
    final crisisList = await CrisisDao.getAllCrisis();
    final crisisFiltradas = crisisList.where((c) {
      return c.fechaCrisis.year == selectedYear && c.fechaCrisis.month == selectedMonth;
    }).toList();

    // 2. Agrupar por día
    Map<String, List<CrisisDetalle>> crisisPorDia = {};
    for (var crisis in crisisFiltradas) {
      final detalles = await CrisisDetalleDao.getDetallesByCrisis(crisis.id!);
      final fechaTexto = DateFormat('yyyy-MM-dd').format(crisis.fechaCrisis);
      crisisPorDia.putIfAbsent(fechaTexto, () => []);
      crisisPorDia[fechaTexto]!.addAll(detalles);
    }

    if (crisisPorDia.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No hay datos para generar el PDF")),
      );
      return;
    }

    try {
      // 3. Generar PDF con el helper
      final archivo = await PDFGenerator.generarDiarioCrisisPDF(
        crisisPorFecha: crisisPorDia,
        nombreBase: nombreBase,
        mes: selectedMonth!,
        anio: selectedYear!,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("PDF guardado en ${archivo.path}")),
      );

      // 4. Abrir el PDF automáticamente
      await OpenFilex.open(archivo.path);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al generar PDF: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF26A69A);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Generar PDF"),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.folder),
            tooltip: "Ver PDFs generados",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PdfListScreen()),
              );
            },
          ),
        ],
      ),
      backgroundColor: const Color(0xFFE6F4F1),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Nombre del PDF:", style: TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            TextFormField(
              controller: nombreController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Ejemplo: Reporte_JuanPerez",
              ),
            ),
            const SizedBox(height: 20),
            const Text("Selecciona el año:", style: TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            DropdownButtonFormField<int>(
              value: selectedYear,
              items: years.map((y) {
                return DropdownMenuItem(value: y, child: Text(y.toString()));
              }).toList(),
              onChanged: (value) => setState(() => selectedYear = value),
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),
            const Text("Selecciona el mes:", style: TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            DropdownButtonFormField<int>(
              value: selectedMonth,
              items: List.generate(12, (i) {
                return DropdownMenuItem(value: i + 1, child: Text(months[i]));
              }),
              onChanged: (value) => setState(() => selectedMonth = value),
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton.icon(
                onPressed: generarPdf,
                icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
                label: const Text("Generar PDF"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
