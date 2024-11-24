import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UserService {
  // URL base da API
  final String baseUrl = "http://localhost:5000";

  // Método para registrar um novo usuário
  Future<Map<String, dynamic>> registerUser(String name, String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/register'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'name': name,
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Erro ao registrar usuário: ${response.body}');
    }
  }

  // Método para fazer login
  Future<Map<String, dynamic>> loginUser(String email, String password) async {
  final response = await http.post(
    Uri.parse('$baseUrl/api/auth/login'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{
      'email': email,
      'password': password,
    }),
  );

  if (response.statusCode == 200) {
    final responseData = jsonDecode(response.body);
    final token = responseData['token']; // Supondo que o token esteja nesse campo
    if (token != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('authToken', token); // Armazena o token
    }
    return responseData;
  } else {
    throw Exception('Erro ao fazer login: ${response.body}');
  }
}

  // Método para buscar o nome do usuário atual
  Future<String> getCurrentUserName() async {
    try {
      // Recuperar o token do usuário logado (caso você esteja usando tokens)
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('session'); // Certifique-se de ter salvo o token ao fazer login

      if (token == null) {
        throw Exception('Token de autenticação não encontrado.');
      }

      // Chamada para o endpoint que retorna os dados do usuário atual
      final response = await http.get(
        Uri.parse('$baseUrl/api/user'),
        headers: {
          'Authorization': 'Bearer $token', // Inclua o token aqui
          'Content-Type': 'application/json',
        },
      );
      print(response.body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['name'] ?? 'Guest'; // Retorna o nome ou "Guest" se não existir
      } else {
        throw Exception('Erro ao buscar o nome do usuário: ${response.body}');
      }
    } catch (e) {
      throw Exception('Erro ao buscar o nome do usuário: $e');
    }
  }

  Future<String> fetchCookie() async {
    final url = Uri.parse('localhost:5000/auth/');
    final response = await http.get(url);

    // Verifica se os cookies estão nos headers
    if (response.headers.containsKey('set-cookie')) {
      final cookies = response.headers['set-cookie']!;
      // Extrai o cookie chamado "session"
      final sessionCookie = cookies.split(';').firstWhere(
        (cookie) => cookie.trim().startsWith('session='),
        orElse: () => '',
      );
      print('Cookie session: $sessionCookie');
      return sessionCookie;
    } else {
      print('Nenhum cookie encontrado');
      return '';
    }
}

}