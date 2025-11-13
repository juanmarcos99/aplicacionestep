import 'dart:io';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';

import '../models/crisis_detalle.dart';

class PDFGenerator {
  /// Limpia texto para evitar caracteres raros en el PDF
  static String _limpiarTexto(String texto) {
    return texto
        .replaceAll('–', '-') // guion en dash
        .replaceAll('—', '-') // guion largo
        .replaceAll(RegExp(r'[^\x00-\x7F]'), ''); // elimina caracteres no ASCII
  }

  /// Genera un PDF con las crisis agrupadas por fecha
  static Future<File> generarDiarioCrisisPDF({
    required Map<String, List<CrisisDetalle>> crisisPorFecha,
    required String nombreBase,
    required int mes,
    required int anio,
  }) async {
    final pdf = pw.Document();
    final mesTexto = DateFormat.MMMM().format(DateTime(anio, mes));
    final nombreArchivo = "${_limpiarTexto(nombreBase)}_${mesTexto}_$anio.pdf";

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text(
              "Reporte de Crisis - ${_limpiarTexto(nombreBase)}\n$mesTexto $anio",
              style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
            ),
          ),
          for (var fecha in crisisPorFecha.keys)
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  "📅 Fecha: ${_limpiarTexto(fecha)}",
                  style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 8),
                pw.Table(
                  border: pw.TableBorder.all(),
                  children: [
                    pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Text("Horario", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Text("Tipo", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Text("Cantidad", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ),
                      ],
                    ),
                    for (var detalle in crisisPorFecha[fecha]!)
                      pw.TableRow(
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(4),
                            child: pw.Text(_limpiarTexto(detalle.horario)),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(4),
                            child: pw.Text(_limpiarTexto(detalle.tipo)),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(4),
                            child: pw.Text(detalle.cantidad.toString()),
                          ),
                        ],
                      ),
                  ],
                ),
                pw.SizedBox(height: 16),
              ],
            ),
        ],
      ),
    );

    // 📌 Pedir permiso de almacenamiento
    final status = await Permission.storage.request();
    if (!status.isGranted) {
      throw Exception("Permiso de almacenamiento denegado");
    }

    // 📌 Guardar en carpeta propia de la app (seguro en Android 11+)
    final dir = await getExternalStorageDirectory();
    if (dir == null) throw Exception("No se pudo acceder al almacenamiento externo");

    final file = File("${dir.path}/$nombreArchivo");
    await file.writeAsBytes(await pdf.save());

    return file;
  }
}
