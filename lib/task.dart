class Task {
  final int? id;
  final String titulo;
  final String responsavel;
  final DateTime dataLimite;

  Task({
    this.id,
    required this.titulo,
    required this.responsavel,
    required this.dataLimite,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titulo': titulo,
      'responsavel': responsavel,
      'dataLimite': dataLimite.toIso8601String(),
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      titulo: map['titulo'],
      responsavel: map['responsavel'],
      dataLimite: DateTime.parse(map['dataLimite']),
    );
  }
}
