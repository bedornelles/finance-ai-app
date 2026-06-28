class PorDia {
  final String dia;
  final double receitas;
  final double despesas;

  PorDia({
    required this.dia,
    required this.receitas,
    required this.despesas,
  });

  factory PorDia.fromJson(Map<String, dynamic> json) {
    return PorDia(
      dia: json["dia"] ?? "",
      receitas: (json["receitas"] as num).toDouble(),
      despesas: (json["despesas"] as num).toDouble(),
    );
  }
}

class PorCategoria {
  final String categoria;
  final double total;
  final double percentual;
  final String tipo;

  PorCategoria({
    required this.categoria,
    required this.total,
    required this.percentual,
    required this.tipo
  });

  factory PorCategoria.fromJson(Map<String, dynamic> json) {
    return PorCategoria(
      categoria: json["categoria"] ?? "",
      total: (json["total"] as num).toDouble(),
      percentual: (json["percentual"] as num).toDouble(),
      tipo: json["tipo"] ?? "Despesa",
    );
  }
}

class DashboardData {
  final double totalReceitas;
  final double totalDespesas;
  final double saldo;
  final int quantidadeTransacoes;
  final double variacao24h;
  final List<PorDia> porDia;
  final List<PorCategoria> porCategoria;

  DashboardData({
    required this.totalReceitas,
    required this.totalDespesas,
    required this.saldo,
    required this.quantidadeTransacoes,
    required this.variacao24h,
    required this.porDia,
    required this.porCategoria,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      totalReceitas: (json["totalReceitas"] as num).toDouble(),
      totalDespesas: (json["totalDespesas"] as num).toDouble(),
      saldo: (json["saldo"] as num).toDouble(),
      quantidadeTransacoes: json["quantidadeTransacoes"] ?? 0,
      variacao24h: (json["variacao24h"] as num).toDouble(),

      porDia: (json["porDia"] as List)
          .map((item) => PorDia.fromJson(item))
          .toList(),

      porCategoria: (json["porCategoria"] as List)
          .map((item) => PorCategoria.fromJson(item))
          .toList(),
    );
  }
}