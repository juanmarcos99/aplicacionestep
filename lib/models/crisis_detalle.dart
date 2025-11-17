class CrisisDetalle {
  final int? id;
  final int crisisId;
  final String horario;
  final String tipo;
  final int cantidad;
  final String? notas;

  CrisisDetalle({
    this.id,
    required this.crisisId,
    required this.horario,
    required this.tipo,
    required this.cantidad,
    this.notas,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'crisis_id': crisisId,
      'horario': horario,
      'tipo': tipo,
      'cantidad': cantidad,
      'notas': notas,
    };
  }

  CrisisDetalle copyWith({
    int? crisisId,
    String? horario,
    String? tipo,
    int? cantidad,
  }) {
    return CrisisDetalle(
      crisisId: crisisId ?? this.crisisId,
      horario: horario ?? this.horario,
      tipo: tipo ?? this.tipo,
      cantidad: cantidad ?? this.cantidad,
    );
  }

  factory CrisisDetalle.fromMap(Map<String, dynamic> map) {
    return CrisisDetalle(
      id: map['id'] as int?,
      crisisId: map['crisis_id'] as int,
      horario: map['horario'] as String,
      tipo: map['tipo'] as String,
      cantidad: map['cantidad'] as int,
      notas: map['notas'] as String?,
    );
  }
}
