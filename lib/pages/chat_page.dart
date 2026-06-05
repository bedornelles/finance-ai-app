import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:registrai/providers/chat_provider.dart';
import 'package:registrai/routes/app_routes.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _rolarParaOFim() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _enviarMensagem() {
    final texto = _controller.text.trim();

    if (texto.isEmpty) return;

    _controller.clear();

    context.read<ChatProvider>().enviarMensagem(texto);
    _rolarParaOFim();
  }

  @override
  Widget build(BuildContext context) {
    final chat = context.watch<ChatProvider>();

    if (chat.mensagens.isNotEmpty) {
      _rolarParaOFim();
    }
    return Scaffold(
    backgroundColor: const Color(0xFFF5F0E8),
    appBar: AppBar(
      backgroundColor: const Color(0xFF1B4332),
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CircleAvatar(
          backgroundColor: const Color(0xFF2D6A4F),
          child: const Icon(Icons.savings, color: Colors.white, size: 20),
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "RegistrAI",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const Text(
            "● escutando você",
            style: TextStyle(
              color: Colors.greenAccent,
              fontSize: 12,
            ),
          ),
        ],
      ),
      actions: [
        Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openEndDrawer(),
          ),
        ),
      ],
    ),
    endDrawer: Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              color: const Color(0xFF1B4332),
              child: const Text(
                "RegistrAI",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard, color: Color(0xFF1B4332)),
              title: const Text("Dashboard"),
              onTap: () {
                Navigator.pop(context);
                context.go(AppRoutes.dashboard);
              },
            ),
          ],
        ),
      ),
    ),
    body: Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(
            "HOJE · ${DateFormat("EEEE, dd 'DE' MMMM", "pt_BR").format(DateTime.now()).toUpperCase()}",
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: chat.mensagens.length + (chat.isCarregando ? 1 : 0),
            itemBuilder: (context, index) {
              if (chat.isCarregando && index == chat.mensagens.length) {
                return _buildIndicadorDigitando();
              }
              final mensagem = chat.mensagens[index];
              final isUser = mensagem["role"] == "user";
              return _buildBalao(mensagem["content"]!, isUser);
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(0, -2),
              )
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: "Pergunte ou registre algo...",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF5F0E8),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  onSubmitted: (_) => _enviarMensagem(),
                ),
              ),
              const SizedBox(width: 8),
              CircleAvatar(
                backgroundColor: const Color(0xFF1B4332),
                child: IconButton(
                  icon: const Icon(Icons.send, color: Colors.white, size: 20),
                  onPressed: _enviarMensagem,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
    );
  }

  Widget _buildBalao(String texto, bool isUser) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isUser ? const Color(0xFF1B4332) : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isUser ? const Radius.circular(16) : Radius.zero,
            bottomRight: isUser ? Radius.zero : const Radius.circular(16),
          ),
        ),
        child: Text(
          texto,
          style: TextStyle(
            color: isUser ? Colors.white : Colors.black87,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  Widget _buildIndicadorDigitando() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Text(
          "●●●",
          style: TextStyle(
            color: Colors.grey,
            fontSize: 20,
            letterSpacing: 4,
          ),
        ),
      ),
    );
  }
}