import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../providers/dashboard_provider.dart';
import '../routes/app_routes.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {

  String get _saudacao {
    final hora = DateTime.now().hour;
    if (hora < 12) return "Bom dia,";
    if (hora < 18) return "Boa tarde,";
    return "Boa noite,";
  }
  String _formatarMoeda(double valor) {
    return NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
      decimalDigits: 2,
    ).format(valor);
  }

  final List<Color> _coresCategorias = const [
    Color(0xFF2D6A4F),
    Color(0xFF8B7355),
    Color(0xFF4A7C59),
    Color(0xFFB85C38),
    Color(0xFF9B8EA0),
    Color(0xFF5C8A6E),
    Color(0xFFA67C52),
    Color(0xFF6B4226),
  ];

  String _tipoGrafico = "Despesa";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<DashboardProvider>();
      provider.resetar();
      provider.buscarDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    final dashboard = context.watch<DashboardProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F0E8),

      appBar: AppBar(
        backgroundColor: const Color(0xFF1B4332),
        automaticallyImplyLeading: false,
        toolbarHeight: 140,
        flexibleSpace: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: const Color(0xFF2D6A4F),
                          radius: 18,
                          child: const Text(
                            "U",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        const SizedBox(width: 10),

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _saudacao,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                              ),
                            ),
                            const Text(
                              "Usuário",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    IconButton(
                      icon: const Icon(Icons.chat_bubble_outline,
                          color: Colors.white),
                      onPressed: () => context.go(AppRoutes.chat),
                      tooltip: "Ir para o chat",
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                const Text(
                  "SALDO DISPONÍVEL",
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 9,
                    letterSpacing: 1.0,
                  ),
                ),

                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: dashboard.isCarregando
                      ? const SizedBox(
                    key: ValueKey('loading'),
                    height: 32,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                      : Column(
                    key: ValueKey('data'),
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _formatarMoeda(dashboard.dashboardData?.saldo ?? 0),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      if (dashboard.dashboardData != null)
                        Row(
                          children: [
                            Icon(
                              dashboard.dashboardData!.variacao24h <= 0
                                  ? Icons.arrow_downward
                                  : Icons.arrow_upward,
                              color: dashboard.dashboardData!.variacao24h <= 0
                                  ? Colors.greenAccent
                                  : Colors.redAccent,
                              size: 12,
                            ),
                            Flexible(
                              child: Text(
                                " ${_formatarMoeda(dashboard.dashboardData!.variacao24h.abs())} em 24h  •  ${dashboard.dashboardData!.quantidadeTransacoes} transações",
                                style: const TextStyle(
                                    color: Colors.white70, fontSize: 11),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),

      body: dashboard.isCarregando
          ? const Center(child: CircularProgressIndicator())
          : dashboard.erro != null
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline,
                color: Colors.grey, size: 48),
            const SizedBox(height: 12),
            Text(dashboard.erro!,
                style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => context
                  .read<DashboardProvider>()
                  .buscarDashboard(),
              child: const Text("Tentar novamente"),
            ),
          ],
        ),
      )

          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Row(
              children: [
                _buildCard(
                  "RECEITA",
                  dashboard.dashboardData?.totalReceitas ?? 0,
                  const Color(0xFF2D6A4F),
                ),
                const SizedBox(width: 8),
                _buildCard(
                  "DESPESA",
                  dashboard.dashboardData?.totalDespesas ?? 0,
                  const Color(0xFF8B5E3C),
                ),
                const SizedBox(width: 8),
                _buildCard(
                  "SOBRA",
                  dashboard.dashboardData?.saldo ?? 0,
                  const Color(0xFF4A6741),
                ),
              ],
            ),

            const SizedBox(height: 28),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Resumo do mês",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C2C2A),
                  ),
                ),
                _buildSeletorPeriodo(dashboard),
              ],
            ),

            const SizedBox(height: 16),

            //Card do grafico donnut + legenda
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // ── Botão toggle Despesas / Receitas ──
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: ["Despesa", "Receita"].map((tipo) {
                      final selecionado = _tipoGrafico == tipo;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _tipoGrafico = tipo;
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: selecionado
                                ? const Color(0xFF1B4332)
                                : const Color(0xFFF5F0E8),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            tipo == "Despesa" ? "Despesas" : "Receitas",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: selecionado
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: selecionado
                                  ? Colors.white
                                  : const Color(0xFF2C2C2A),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 16),

                  // ── Gráfico donnut + legenda ──
                  (dashboard.dashboardData?.porCategoria
                      .where((cat) => cat.tipo == _tipoGrafico)
                      .isEmpty ?? true)
                      ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Text(
                        "Nenhuma despesa registrada no período",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  )
                      : Row(
                    children: [
                      // ── Gráfico donnut ──
                      SizedBox(
                        width: 140,
                        height: 140,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            PieChart(
                              PieChartData(
                                sectionsSpace: 2,
                                centerSpaceRadius: 45,
                                sections: _buildSecoesPizza(dashboard),
                              ),
                            ),
                            // ── Texto central ──
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  DateFormat("MMMM", "pt_BR")
                                      .format(DateTime.now())
                                      .toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 8,
                                    color: Colors.grey,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                Text(
                                  _formatarMoeda(_tipoGrafico == "Despesa"
                                      ? dashboard.dashboardData?.totalDespesas ?? 0
                                      : dashboard.dashboardData?.totalReceitas ?? 0),
                                  // 👆 muda o valor central conforme o tipo selecionado
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2C2C2A),
                                  ),
                                ),
                                Text(
                                  _tipoGrafico == "Despesa"
                                      ? "total gasto"
                                      : "total recebido",
                                  // 👆 muda o label conforme o tipo selecionado
                                  style: const TextStyle(
                                    fontSize: 8,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 20),

                      // ── Legenda ──
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: dashboard
                              .dashboardData!.porCategoria
                              .where((cat) => cat.tipo == _tipoGrafico)
                              .take(6)
                              .toList()
                              .asMap()
                              .entries
                              .map((entry) {
                            final index = entry.key;
                            final cat = entry.value;
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 3),
                              child: Row(
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: _coresCategorias[
                                      index % _coresCategorias.length],
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      cat.categoria,
                                      style: const TextStyle(
                                          fontSize: 11, color: Color(0xFF2C2C2A)),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Text(
                                    "${cat.percentual.toStringAsFixed(0)}%",
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2C2C2A),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "Evolução diária",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C2C2A),
              ),
            ),

            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: dashboard.dashboardData!.porDia.isEmpty
                  ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text(
                    "Nenhum dado disponível",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
                  : SizedBox(
                height: 180,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: _calcularMaxY(dashboard),

                    barTouchData: BarTouchData(
                      enabled: true,
                      touchTooltipData: BarTouchTooltipData(
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          final dia = dashboard.dashboardData!.porDia[groupIndex];
                          final valor = rodIndex == 0 ? dia.despesas : dia.receitas;
                          final tipo = rodIndex == 0 ? "Despesa" : "Receita";
                          return BarTooltipItem(
                            "$tipo\n${_formatarMoeda(valor)}",
                            const TextStyle(color: Colors.white, fontSize: 10),
                          );
                        },

                      ),
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final diasComMovimento = dashboard.dashboardData!.porDia
                                .where((d) => d.despesas > 0 || d.receitas > 0)
                                .toList();
                            final index = value.toInt();
                            if (index >= diasComMovimento.length) return const SizedBox();
                            final dia = diasComMovimento[index].dia;
                            final numero = dia.split('-').last;
                            return Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                numero,
                                style: const TextStyle(fontSize: 9, color: Colors.grey),
                              ),
                            );
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      getDrawingHorizontalLine: (value) => FlLine(
                        color: Colors.grey.withOpacity(0.15),
                        strokeWidth: 1,
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    barGroups: dashboard.dashboardData!.porDia
                        .asMap()
                        .entries
                        .where((entry) =>
                    entry.value.despesas > 0 || entry.value.receitas > 0)
                        .toList()
                        .asMap()
                        .entries
                        .map((entry) {
                      final index = entry.key;
                      final dia = entry.value.value;
                      return BarChartGroupData(
                        x: index,
                        barRods: [
                          BarChartRodData(
                            toY: dia.despesas,
                            color: const Color(0xFFB85C38),
                            width: 8,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          BarChartRodData(
                            toY: dia.receitas,
                            color: const Color(0xFF2D6A4F),
                            width: 8,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),

// ── Legenda do gráfico de barras ──
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: const Color(0xFFB85C38),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 4),
                const Text("Despesas",
                    style: TextStyle(fontSize: 11, color: Colors.grey)),
                const SizedBox(width: 16),
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2D6A4F),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 4),
                const Text("Receitas",
                    style: TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 20),

            // ── Título ──
            const Text(
              "Últimas transações",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C2C2A),
              ),
            ),

            const SizedBox(height: 12),

            // ── Lista ──
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: _buildListaTransacoes(dashboard),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(String titulo, double valor, Color cor) {
    return Expanded(

      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              titulo,
              style: TextStyle(
                fontSize: 8,
                color: cor,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              NumberFormat.currency(
                locale: 'pt_BR',
                symbol: '',
                decimalDigits: 2,
              ).format(valor),
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C2C2A),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeletorPeriodo(DashboardProvider dashboard) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: ["semana", "mes", "ano"].map((periodo) {
          final selecionado =
              dashboard.periodoSelecionado == periodo;
          return GestureDetector(
            onTap: () => context
                .read<DashboardProvider>()
                .buscarDashboard(periodo: periodo),

            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: selecionado
                    ? const Color(0xFF1B4332)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                periodo == "semana"
                    ? "Semana"
                    : periodo == "mes"
                    ? "Mês"
                    : "Ano",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: selecionado
                      ? FontWeight.bold
                      : FontWeight.normal,
                  color: selecionado
                      ? Colors.white
                      : const Color(0xFF2C2C2A),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  List<PieChartSectionData> _buildSecoesPizza(DashboardProvider dashboard) {
    final categorias = dashboard.dashboardData!.porCategoria
      .where((cat) => cat.tipo == _tipoGrafico)
        .take(6)
        .toList();

    if (categorias.isEmpty) return [];

    return categorias.asMap().entries.map((entry) {
      final index = entry.key;
      final cat = entry.value;
      return PieChartSectionData(
        value: cat.percentual,
        color: _coresCategorias[index % _coresCategorias.length],
        radius: 30,
        showTitle: false,
      );
    }).toList();
  }

  double _calcularMaxY(DashboardProvider dashboard) {
    double max = 0;
    for (final dia in dashboard.dashboardData!.porDia) {
      if (dia.despesas > max) max = dia.despesas;
      if (dia.receitas > max) max = dia.receitas;
    }
    return max * 1.2;
  }

  Widget _buildListaTransacoes(DashboardProvider dashboard) {
    // Pega as transações do período via DashboardService
    // Como não temos lista individual no DashboardData,
    // usamos o porDia para mostrar os dias com movimentação
    // e buscamos as transações do provider
    final transacoes = dashboard.ultimasTransacoes;

    if (transacoes.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Center(
          child: Text(
            "Nenhuma transação no período",
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return Column(
      children: transacoes.asMap().entries.map((entry) {
        final index = entry.key;
        final t = entry.value;
        final isUltimo = index == transacoes.length - 1;
        final isDespesa = t.tipo == "Despesa";

        return Container(
          padding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: isUltimo
                ? null
                : Border(
              bottom: BorderSide(
                color: Colors.grey.withOpacity(0.1),
                width: 1,
              ),
            ),
            // linha divisória entre os itens, exceto o último
          ),
          child: Row(
            children: [
              // ── Ícone da categoria ──
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isDespesa
                      ? const Color(0xFFFAECE7)
                      : const Color(0xFFE1F5EE),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isDespesa
                      ? Icons.arrow_upward
                      : Icons.arrow_downward,
                  color: isDespesa
                      ? const Color(0xFFB85C38)
                      : const Color(0xFF2D6A4F),
                  size: 18,
                ),
              ),
              // seta para cima = despesa (dinheiro saindo)
              // seta para baixo = receita (dinheiro entrando)

              const SizedBox(width: 12),

              // ── Categoria e data ──
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.categoria,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2C2C2A),
                      ),
                    ),
                    Text(
                      DateFormat("dd/MM/yyyy").format(t.data),
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),

              // ── Valor ──
              Text(
                "${isDespesa ? '-' : '+'} ${_formatarMoeda(t.valor)}",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isDespesa
                      ? const Color(0xFFB85C38)
                      : const Color(0xFF2D6A4F),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}