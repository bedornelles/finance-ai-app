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

    print("📤 TEXTO: $texto");
    print("📤 HISTORICO: $historico");
    print("📤 TENTATIVAS: $tentativas");

    try{
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "texto": texto,
          "historico": historico,
          "tentativas": tentativas,
        }),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          print(" TIMEOUT — requisição demorou mais de 30 segundos");
          throw Exception("Timeout — a IA demorou muito para responder");
        },
      );

      print(" STATUS: ${response.statusCode}");
      print(" BODY: ${response.body}");

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return ChatResposta.fromJson(json);
    } else {
      throw Exception("Erro ao interpretar: ${response.statusCode} - ${response.body}");
    }
  } catch (e) {
      print("ERRO DE CONEXÃO: $e");
      rethrow;
    }
  }

  Future<ChatResposta> confirmar(Transacao transacao) async {
    final url = Uri.parse("${ApiService.baseUrl}/api/transacoesia/confirmar");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(transacao.toJson()),
    );

    print("📥 STATUS: ${response.statusCode}");
    print("📥 BODY: ${response.body}");

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);

      print("📦 JSON COMPLETO: $json");
      print("📦 TIPO NO JSON: ${json['tipo']}");

      return ChatResposta.fromJson(json);
    } else {
      throw Exception("Erro ao confirmar: ${response.statusCode} - ${response.body}");
    }
  }

  Future<ChatResposta> excluir(int id) async {
    final url = Uri.parse("${ApiService.baseUrl}/api/transacoesia/excluir/$id");

    final response = await http.delete(url);

    print("📥 STATUS EXCLUIR: ${response.statusCode}");
    print("📥 BODY EXCLUIR: ${response.body}");

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return ChatResposta.fromJson(json);
    } else {
      throw Exception("Erro ao excluir: ${response.statusCode} - ${response.body}");
    }
  }
}