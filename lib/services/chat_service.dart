import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/chat_resposta.dart';
import '../models/transacao.dart';
import 'api_service.dart';

class ChatService {

  Future<ChatResposta> interpretar({
    required String texto,
    required List<Map<String, String>> historico,
    required int tentativas,
  }) async {
    final url = Uri.parse("${ApiService.baseUrl}/api/transacoesia/interpretar");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "texto": texto,
        "historico": historico,
        "tentativas": tentativas,
      }),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return ChatResposta.fromJson(json);
    } else {
      throw Exception("Erro ao interpretar: ${response.statusCode} - ${response.body}");
    }
  }

  Future<ChatResposta> confirmar(Transacao transacao) async {
    final url = Uri.parse("${ApiService.baseUrl}/api/transacoesia/confirmar");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(transacao.toJson()),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return ChatResposta.fromJson(json);
    } else {
      throw Exception("Erro ao confirmar: ${response.statusCode} - ${response.body}");
    }
  }
}