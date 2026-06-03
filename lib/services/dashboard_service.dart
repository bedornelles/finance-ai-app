import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/dashboard.dart';
import 'api_service.dart';

class DashboardService {

  Future<DashboardData> buscarDashboard(String periodo) async {
    final url = Uri.parse(
        "${ApiService.baseUrl}/api/dashboard?periodo=$periodo"
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return DashboardData.fromJson(json);
    } else {
      throw Exception("Erro ao buscar dashboard: ${response.statusCode}");
    }
  }
}