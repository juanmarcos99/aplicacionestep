import 'package:aplicacionestep/database/crisis_dao.dart';
import 'package:aplicacionestep/database/crisis_detalle_dao.dart';
import 'package:aplicacionestep/models/crisis.dart';
import 'package:flutter/material.dart';
import 'package:aplicacionestep/models/crisis_detalle.dart';

// inicio la clase
class RegistroCrisisScreen extends StatefulWidget {
  const RegistroCrisisScreen({super.key});

  //Se sobrescribe el metodo q ya existe en la clase padre, Este método le dice
  //a Flutter: “Cuando crees un RegistroCrisisScreen, usa esta clase de estado para
  //manejarlo”.
  @override
  State<RegistroCrisisScreen> createState() => _RegistroCrisisScreenState();
}

// define la clase de estado que controla tu pantalla RegistroCrisisScreen, es lo q
// dibuja la pantalla
class _RegistroCrisisScreenState extends State<RegistroCrisisScreen> {
  //declaro dos atributos uno para la fecha y el otro para el horario
  DateTime fecha = DateTime.now();
  String? horario;
  bool _isLoading = false;

  // primero creo la lista con los horarios
  final List<String> horarios = [
    '6:00 am - 10:00 am',
    '10:00 am - 2:00 pm',
    '2:00 pm - 6:00 pm',
    '6:00 pm - 10:00 pm',
    '10:00 pm - 6:00 am',
  ];
  //despues una con los tipos de crisis q son fijos
  final List<String> tiposCrisis = [
    'Focales conscientes',
    'Focales inconscientes',
    'Tónico-clónico bilateral',
  ];

  // Controladores para los tipos predefinidos, los controladores son los text field
  final Map<String, TextEditingController> crisisControllers = {};

  // Lista dinámica de pares (descripcion + cantidad), esto es para las crisis q puede
  //poner el usuario, es decir q puede agragar tipos de crisis
  final List<Map<String, TextEditingController>> otrosCampos = [];

  //nota importante: Los texteEditingController se deben crear antes que se dibuje la
  //pantalla y los mismos reservan espacio en memoria por lo q cuando se elimina el
  //widget deben liberarse con dipose, son como variables q ocupan espacios

  //initState() es un método especial que pertenece a la clase State de
  //un StatefulWidget. Se ejecuta una sola vez, justo cuando el widget
  //se crea por primera vez en memoria. Sirve para inicializar variables,
  //controladores o listeners antes de que el widget se dibuje en pantalla.
  @override
  void initState() {
    super.initState();
    for (var tipo in tiposCrisis) {
      crisisControllers[tipo] = TextEditingController();
    }
  }

  //metodo para liberar los texteditingcontroller cuando se elimina el widget
  @override
  void dispose() {
    // predefinidos
    for (var controller in crisisControllers.values) {
      controller.dispose();
    }
    // dinámicos
    for (var campo in otrosCampos) {
      campo['descripcion']?.dispose();
      campo['cantidad']?.dispose();
    }
    super.dispose();
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

  //metodo q guarda las crisis en la base de datos
  Future<void> guardarCrisis() async {
    if (!mounted) return;
    if (horario == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Selecciona un horario")));
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Validar detalles fijos
      final detalles = <CrisisDetalle>[];
      for (var tipo in tiposCrisis) {
        final valor = crisisControllers[tipo]!.text.trim();
        if (valor.isNotEmpty) {
          detalles.add(
            CrisisDetalle(
              crisisId: 0, // se asignará luego
              horario: sanitizeText(horario!),
              tipo: sanitizeText(tipo),
              cantidad: int.tryParse(valor) ?? 0,
            ),
          );
        }
      }

      if (detalles.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Debes llenar al menos un campo fijo")),
        );
        return;
      }

      // 2. Validar detalles dinámicos
      final dinamicos = <CrisisDetalle>[];
      for (var campo in otrosCampos) {
        final descripcion = campo['descripcion']!.text.trim();
        final cantidad = campo['cantidad']!.text.trim();
        if (descripcion.isNotEmpty && cantidad.isNotEmpty) {
          dinamicos.add(
            CrisisDetalle(
              crisisId: 0, // se asignará luego
              horario: sanitizeText(horario!),
              tipo: sanitizeText(descripcion),
              cantidad: int.tryParse(cantidad) ?? 0,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                "Debes llenar todos los campos de las crisis añadidas",
              ),
            ),
          );
          return;
        }
      }

      //Si llegamos aquí, significa que todo está validado

      // 3. Insertar crisis principal
      final crisis = Crisis(fechaCrisis: fecha, fechaRegistro: DateTime.now());
      final crisisId = await CrisisDao.insertCrisis(crisis);

      // 4. Insertar detalles fijos
      for (var detalle in detalles) {
        await CrisisDetalleDao.insertDetalle(
          detalle.copyWith(crisisId: crisisId),
        );
      }

      // 5. Insertar detalles dinámicos
      for (var dinamico in dinamicos) {
        await CrisisDetalleDao.insertDetalle(
          dinamico.copyWith(crisisId: crisisId),
        );
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Crisis registrada correctamente")),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF26A69A); // color primario para la app

    return Scaffold(
      backgroundColor: const Color(0xFFE6F4F1),
      // hago el appBar para el encabezado de la pantalla
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

      // cuerpo de la pantalla
      body: Padding(
        padding: const EdgeInsets.all(
          24.0,
        ), //doy un padding de 24px a todos los lados
        child: ListView(
          children: [
            // ---------------- Fecha ----------------
            const Text('Fecha del episodio', style: TextStyle(fontSize: 16)),
            ListTile(
              title: Text('${fecha.toLocal()}'.split(' ')[0]),
              trailing: const Icon(
                Icons.calendar_month_outlined,
                color: primaryColor,
              ),
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
            const Text(
              'Cantidad de crisis por tipo',
              style: TextStyle(fontSize: 16),
            ),
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
            const Text(
              'Otros tipos de crisis',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
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
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton.icon(
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
