import 'package:registrai/models/transacao.dart';

class ChatResposta {
  final String tipo;
  // "confirmacao_pendente" → IA entendeu tudo, aguarda sim/não
  // "pergunta_info"        → IA precisa de mais informação
  // "pergunta"             → usuário fez uma pergunta, IA respondeu
  // "cancelado"            → usuário cancelou
  // "salvo"                → transação salva com sucesso
  // "erro"                 → IA não conseguiu entender

  final String mensagem;

  final Transacao? transacaoPendente;

  ChatResposta({
    required this.tipo,
    required this.mensagem,
    required this.transacaoPendente,
  });

  factory ChatResposta.fromJson(Map<String, dynamic> json) {
    return ChatResposta(
      tipo: json["tipo"] ?? "",
      mensagem: json["mensagem"] ?? "",

      // Se vier null, fica null
      // Se vier preenchido, converte para objeto Transacao
      transacaoPendente: json["transacaoPendente"] != null
          ? Transacao.fromJson(json["transacaoPendente"])
          : null,
    );
  }
}