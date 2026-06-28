import 'package:flutter/foundation.dart';
import 'package:registrai/models/dashboard.dart';
import 'package:registrai/services/dashboard_service.dart';

class DashboardProvider extends ChangeNotifier {
  final DashboardService _dashboardService = DashboardService();

  DashboardData? _dashboardData;
  DashboardData? get dashboardData => _dashboardData;

  String _periodoSelecionado = "mes";
  String get periodoSelecionado => _periodoSelecionado;

  bool _isCarregando = true;
  bool get isCarregando => _isCarregando;

  String? _erro;
  String? get erro => _erro;

  Future<void> buscarDashboard({String? periodo}) async {
    if (periodo != null) {
      _periodoSelecionado = periodo;
    }

    _isCarregando = true;
    _erro = null;
    notifyListeners();

    try {
      _dashboardData = await _dashboardService.buscarDashboard(_periodoSelecionado);
    } catch (e) {
      _erro = "Erro ao carregar o dashboard. Tente novamente.";
    } finally {
      _isCarregando = false;
      notifyListeners();
    }
  }
  void resetar() {
    _dashboardData = null;
    _isCarregando = true;
    _erro = null;
    notifyListeners();
  }
}