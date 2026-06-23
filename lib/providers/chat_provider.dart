import 'package:flutter/foundation.dart';
import 'package:registrai/services/chat_service.dart';
import 'package:registrai/models/transacao.dart';

class ChatProvider extends ChangeNotifier{

  final ChatService _chatService = ChatService();

  final List <Map<String, String>> _mensagens  = [];

  List<Map<String, String>> get mensagens => _mensagens;

  Transacao? _transacaoPendente;
  Transacao? get transacaoPendente => _transacaoPendente;

  int _tentativas = 0;

  bool _isCarregando = false;
  bool get isCarregando => _isCarregando;

  String? _erro;
  String? get erro => _erro;

  int? _idTransacaoParaExcluir;

  Future<void> enviarMensagem(String texto) async {
    _mensagens.add({"role": "user", "content": texto});
    _isCarregando = true;
    _erro = null;
    notifyListeners();

    try {
      final resposta = await _chatService.interpretar(
        texto: texto,
        historico: _mensagens
            .where((m) => m["role"] != "user" || m["content"] != texto)
            .toList()
            .reversed
            .take(6)
            .toList()
            .reversed
            .toList(),
        tentativas: _tentativas,
      );
      print("✅ TIPO RECEBIDO: ${resposta.tipo}");
      print("✅ MENSAGEM RECEBIDA: ${resposta.mensagem}");
      print("✅ TRANSACAO PENDENTE: ${resposta.transacaoPendente}");

      // Adiciona a resposta da IA na lista só se tiver mensagem
      if (resposta.mensagem.isNotEmpty) {
        _mensagens.add({"role": "assistant", "content": resposta.mensagem});
      }

      // Trata cada tipo de resposta
      switch (resposta.tipo) {
        case "confirmacao_pendente":
        // IA entendeu tudo — guarda a transação e aguarda confirmação
          _transacaoPendente = resposta.transacaoPendente;
          _tentativas = 0;
          break;

        case "pergunta_info":
        // IA precisa de mais informação
          _tentativas++;
          break;

        case "cancelado":
        // Usuário cancelou — limpa tudo
          _transacaoPendente = null;
          _tentativas = 0;
          break;

        case "pergunta":
        // IA respondeu uma pergunta sobre gastos
          _tentativas = 0;
          _transacaoPendente = null;
          break;

        case "exclusao_confirmacao":
        // IA encontrou 1 transação — guarda o ID e aguarda sim/não
          _idTransacaoParaExcluir = resposta.transacaoPendente?.id;
          _tentativas = 0;
          break;

        case "exclusao_multipla":
        // IA encontrou mais de 1 — só exibe a lista, usuário precisa ser mais específico
          _tentativas = 0;
          _idTransacaoParaExcluir = null;
          break;

        case "excluido":
        // Transação excluída com sucesso
          _idTransacaoParaExcluir = null;
          _tentativas = 0;
          break;

        case "confirmado":
        // Usuário confirmou — verifica se é exclusão ou registro
          if (_idTransacaoParaExcluir != null) {
            await excluirTransacao(); // 👈 exclusão
          } else if (_transacaoPendente != null) {
            await confirmarTransacao(); // 👈 registro
          }
          break;

        default:
        // Erro ou classificação desconhecida
          _tentativas = 0;
          _transacaoPendente = null;
          break;
      }

    } catch (e) {
      print("ERRO COMPLETO: $e");
      _erro = "Erro ao conectar com a IA. Tente novamente.";
      _mensagens.add({"role": "assistant", "content": _erro!});
      _transacaoPendente = null;
      _tentativas = 0;
    } finally {
      _isCarregando = false;
      notifyListeners();
    }
  }

  Future<void> confirmarTransacao() async {
    if (_transacaoPendente == null) return;

    _isCarregando = true;
    notifyListeners();

    try {
      final resposta = await _chatService.confirmar(_transacaoPendente!);
      _mensagens.add({"role": "assistant", "content": resposta.mensagem});
      _transacaoPendente = null;
      _tentativas = 0;
    } catch (e) {
      _erro = "Erro ao salvar a transação. Tente novamente.";
      _mensagens.add({"role": "assistant", "content": _erro!});
    } finally {
      _isCarregando = false;
      notifyListeners();
    }
  }

  Future<void> excluirTransacao() async {
    if (_idTransacaoParaExcluir == null) return;

    _isCarregando = true;
    notifyListeners();

    try {
      final resposta = await _chatService.excluir(_idTransacaoParaExcluir!);
      _mensagens.add({"role": "assistant", "content": resposta.mensagem});
      _idTransacaoParaExcluir = null;
      _tentativas = 0;
    } catch (e) {
      _erro = "Erro ao excluir a transação. Tente novamente.";
      _mensagens.add({"role": "assistant", "content": _erro!});
    } finally {
      _isCarregando = false;
      notifyListeners();
    }
  }
}