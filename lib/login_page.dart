import 'package:flutter/material.dart';
import 'package:maisound/home_page.dart';
import './services/user_service.dart';
import 'package:maisound/cadastro_page.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final UserService _userService = UserService();

  void _login() async {
    try {
      var response = await _userService.loginUser(
        _emailController.text,
        _passwordController.text,
      );
      print('Usuário logado: $response');
      // Aqui você pode salvar o token e navegar para outra página
    } catch (e) {
      print('Erro ao fazer login: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF333441), // Cor de fundo
      body: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          width: double.infinity, // Para ocupar toda a largura
          constraints: BoxConstraints(maxWidth: 400), // Limitar a largura
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Campos de texto e botão de login aqui
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  hintText: 'Email',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  hintText: 'Password',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                obscureText: true,
              ),
              SizedBox(height: 24.0),
              ElevatedButton(
                onPressed: () async {
                  String email = _emailController.text;
                  String password = _passwordController.text;

                  // Chama o serviço para fazer login
                  var response = await _userService.loginUser(email, password);

                  // Redireciona para a HomePage após o login
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => HomePage()),
                  );
                                },
                child: Text('Login'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, // Cor do botão
                  padding: EdgeInsets.symmetric(vertical: 14.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              // Link para Cadastro
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CadastroPage()),
                  );
                },
                child: Text(
                  "Não tem cadastro? Crie uma conta",
                  style: TextStyle(
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
