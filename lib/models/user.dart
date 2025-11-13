class User {
  final int? id;            // id autoincremental
  final String username;    // nombre de usuario
  final String passwordHash; // hash de la contraseña

  User({
    this.id,
    required this.username,
    required this.passwordHash,
  });

  // Convertir objeto a Map para insertar en la DB
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'passwordHash': passwordHash,
    };
  }

  // Crear objeto desde Map (ej. resultado de una query)
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as int?,
      username: map['username'] as String,
      passwordHash: map['passwordHash'] as String,
    );
  }
}
