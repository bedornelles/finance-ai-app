class Transacao {
  final int id;
  final double valor;
  final String categoria;
  final DateTime data;
  final String tipo;

  Transacao({
    required this.id,
    required this.valor,
    required this.categoria,
    required this.data,
    required this.tipo,
  });

  factory Transacao.fromJson(Map<String, dynamic> json) {
    return Transacao(
        id: json["id"] ?? 0,
        valor: (json["valor"] as num).toDouble(),
        categoria: json["categoria"] ?? "",
        data: DateTime.parse(json["data"]),
        tipo: json["tipo"] ?? "",
    );
  }

  Map<String, dynamic> toJson(){
    return {
      "id": id,
      "valor": valor,
      "categoria": categoria,
      "data": data.toIso8601String(),
      "tipo": tipo,
    };
  }
}