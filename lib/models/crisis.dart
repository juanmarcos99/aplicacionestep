class Crisis {
  final int? id;
  final DateTime fechaCrisis;
  final DateTime fechaRegistro;

  Crisis({
    this.id,
    required this.fechaCrisis,
    required this.fechaRegistro,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fecha_crisis': fechaCrisis.toIso8601String(),
      'fecha_registro': fechaRegistro.toIso8601String(),
    };
  }

  factory Crisis.fromMap(Map<String, dynamic> map) {
    return Crisis(
      id: map['id'] as int?,
      fechaCrisis: DateTime.parse(map['fecha_crisis']),
      fechaRegistro: DateTime.parse(map['fecha_registro']),
    );
  }
}
