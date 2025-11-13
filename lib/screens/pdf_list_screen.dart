import 'dart:io';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class PdfListScreen extends StatefulWidget {
  const PdfListScreen({super.key});

  @override
  State<PdfListScreen> createState() => _PdfListScreenState();
}

class _PdfListScreenState extends State<PdfListScreen> {
  List<FileSystemEntity> pdfFiles = [];

  @override
  void initState() {
    super.initState();
    cargarPDFs();
  }

  Future<void> cargarPDFs() async {
    final dir = await getExternalStorageDirectory();
    if (dir != null) {
      final files = dir.listSync().where((f) => f.path.endsWith(".pdf")).toList();
      setState(() {
        pdfFiles = files;
      });
    }
  }

  void abrirPDF(FileSystemEntity file) {
    OpenFilex.open(file.path);
  }

  void compartirPDF(FileSystemEntity file) {
    Share.shareXFiles([XFile(file.path)], text: "Aquí está tu reporte PDF");
  }

  void borrarPDF(FileSystemEntity file, int index) async {
    await File(file.path).delete();
    setState(() {
      pdfFiles.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("PDF eliminado")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mis PDFs"),
        backgroundColor: const Color(0xFF26A69A),
        foregroundColor: Colors.white,
      ),
      body: pdfFiles.isEmpty
          ? const Center(child: Text("No hay PDFs generados"))
          : ListView.builder(
              itemCount: pdfFiles.length,
              itemBuilder: (context, index) {
                final file = pdfFiles[index];
                final nombre = file.path.split('/').last;
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                  child: ListTile(
                    leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
                    title: Text(nombre),
                    // 👇 Aquí se abre el PDF al tocar el ListTile
                    onTap: () => abrirPDF(file),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'abrir') {
                          abrirPDF(file);
                        } else if (value == 'compartir') {
                          compartirPDF(file);
                        } else if (value == 'borrar') {
                          borrarPDF(file, index);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: 'abrir', child: Text("Abrir")),
                        const PopupMenuItem(value: 'compartir', child: Text("Compartir")),
                        const PopupMenuItem(value: 'borrar', child: Text("Borrar")),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
