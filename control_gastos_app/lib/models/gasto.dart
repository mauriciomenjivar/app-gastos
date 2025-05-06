class Gasto {
  int? id;
  String titulo;
  double monto;
  String categoria;
  String fecha;

  Gasto({
    this.id,
    required this.titulo,
    required this.monto,
    required this.categoria,
    required this.fecha,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titulo': titulo,
      'monto': monto,
      'categoria': categoria,
      'fecha': fecha,
    };
  }

  factory Gasto.fromMap(Map<String, dynamic> map) {
    return Gasto(
      id: map['id'],
      titulo: map['titulo'],
      monto: map['monto'],
      categoria: map['categoria'],
      fecha: map['fecha'],
    );
  }
}
