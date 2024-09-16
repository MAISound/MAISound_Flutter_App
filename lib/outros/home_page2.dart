import 'package:flutter/material.dart';
export 'package:flutterflow_ui/flutterflow_ui.dart';

// Custom Main Button
// Botão customizado da tela inicial
class MainButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color color;
  final Color textColor;
  final double borderRadius;
  final double elevation;
  final Icon icon;

  const MainButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon = const Icon(Icons.menu),
    this.color = const Color.fromARGB(255, 18, 18, 23),
    this.textColor = const Color.fromARGB(255, 205, 205, 205),
    this.borderRadius = 15.0,
    this.elevation = 2.0,
  });

  @override
  Widget build(BuildContext context) {
    // Coluna com o botão e um texto embaixo
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Este container armazena o botão icone
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(borderRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                spreadRadius: elevation,
                blurRadius: elevation,
                offset: Offset(0, 2), // Muda posição da sombra
              ),
            ],
          ),
          child: IconButton(
            iconSize: 50,
            icon: icon,
            color: textColor,
            onPressed: onPressed,
          ),
        ),
        // Caixa de texto logo abaixo do botão
        SizedBox(height: 8), // Adiciona espaço entre o botão e o texto
        Text(
          text,
          style: TextStyle(
            color: textColor,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}

// Container/Botão que representa um projeto (projetos recente)
class ProjectButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget title;
  final Widget image;

  const ProjectButton({
    super.key,
    required this.onPressed,
    required this.title,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 392,
        height: 303,
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 20, 20, 28), // Button background color
          borderRadius: BorderRadius.circular(20), // Button border radius
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Title
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: title,
            ),
            // Image
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: image,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Pagina inicial
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: "Home",

        // Tema do aplicativo (Cores etc...)
        theme:
            ThemeData(scaffoldBackgroundColor: Color.fromARGB(255, 48, 48, 71)),

        // Componentes
        home: Scaffold(
            // Container vertical, na parte de cima tem os botões
            // Na parte debaixo tem os projetos recentes
            body: Column(
          // Centraliza os elementos da coluna
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,

          children: [
            Center(
                // Botões horizontais principais
                child: Row(
                    // Deixa os botões separados com a mesma distância
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                  MainButton(
                    text: "Menu",
                    onPressed: () {
                      // Add your onPressed code here!
                      print("Button Pressed!");
                    },
                  ),
                  MainButton(
                    text: "New Project",
                    icon: Icon(Icons.add),
                    onPressed: () {
                      // Add your onPressed code here!
                      print("Button Pressed!");
                    },
                  ),
                  MainButton(
                    text: "Load",
                    icon: Icon(Icons.file_open),
                    onPressed: () {
                      // Add your onPressed code here!
                      print("Button Pressed!");
                    },
                  )
                ])),
            // Projetos recente
            Row(
              children: [
                ProjectButton(
                  onPressed: () {
                    print('Button Pressed!');
                  },
                  title: Text(
                    'Projeto123',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  image: Image.network(
                    'https://via.placeholder.com/150',
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            )
          ],
        )));
  }
}
