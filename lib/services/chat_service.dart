import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:maisound/classes/globals.dart';
import 'package:maisound/classes/instrument.dart';
import 'package:maisound/classes/track.dart';

class ChatService {
  // URL base da API
  final String baseUrl = "http://localhost:5000";

  // Envia a mensagem para a API
  Future<Map<String, dynamic>> send(String prompt) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/chat'),

      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        "prompt": prompt,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body); // Retorna o token e informações do usuário
    } else {
      throw Exception('Erro ao enviar a mensagem: ${response.body}');
    }
  }
}