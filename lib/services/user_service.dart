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
  Future<Map<String, dynamic>> getUser() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/auth/user'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      final user = jsonDecode(response.body);

      return user['user']; // Retorna os dados do projeto
    } else {
      throw Exception('Erro ao receber o projeto: ${response.body}');
    }
  }

  Future<bool> logout() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/auth/logout'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  } 

  // Método para buscar o nome do usuário atual
  Future<bool> isAuthenticated() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/auth/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 201) {
      return true;
    } else {
      return false;
    }
  }
}