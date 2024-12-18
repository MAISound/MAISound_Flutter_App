
import 'package:flutter/material.dart';
import 'package:maisound/services/chat_service.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  // Controlador para o campo de entrada de texto
  final TextEditingController _messageController = TextEditingController();

  final ChatService _chatService = ChatService();

  // Lista de mensagens [Type, Message]
  List<Map<String, String>> messages = [
    {'type': 'Robot', 'message': 'Olá! Eu sou a MAI , sua assistente de IA, como posso ajudar?'},
  ];

  // Função para adicionar uma nova mensagem à lista
  void _sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      setState(() {
        messages.add({'type': 'User', 'message': _messageController.text});
        _messageController.clear(); // Limpa o campo de texto
      });

      // Recebe mensagem
      try {
        var response = await _chatService.send(messages.last["message"]! + "\n" ?? "\n");

        setState(() {
          messages.add({'type': 'Robot', 'message': response["response"]});
        });
      } catch (e) {
        print('Erro ao enviar mensagem: $e');
      }
      
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black54,
      appBar: AppBar(
        title: Text('Chat Assistente IA'),
        backgroundColor: Colors.black87,
      ),
      body: Column(
        children: [
          // Lista de mensagens
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final messageType = messages[index]['type'];
                final messageText = messages[index]['message'];

                // Alinha à esquerda se for Robot, à direita se for User
                final isRobot = messageType == 'Robot';
                return Align(
                  alignment: isRobot ? Alignment.centerLeft : Alignment.centerRight,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4.0),
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: isRobot ? Colors.grey[800] : Colors.blue[800],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      messageText ?? '',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                );
              },
            ),
          ),

          // Campo de entrada e botão de envio
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white12,
                      hintText: 'Digite sua mensagem...',
                      hintStyle: TextStyle(color: Colors.white54),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: Colors.white),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
