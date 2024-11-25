import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:maisound/classes/globals.dart';
import 'package:maisound/home_page.dart';
import 'package:maisound/services/project_service.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:maisound/project_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:maisound/login_page.dart';
import 'package:maisound/services/user_service.dart'; 
import 'dart:io';
//import 'dart:html' as html;

export 'package:flutterflow_ui/flutterflow_ui.dart';

// Importa dart:html apenas para a web
//import 'dart:html' as html;
import 'package:universal_html/html.dart' as html;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  late final ScrollController _scrollController;

  ProjectService _projectService = ProjectService();
  List<List<String>> projects = [];

  String? userIconPath = 'assets/images/default_user.png';
  String? userImage = 'assets/images/logged_user.png';
  bool isLoggedIn = false;

  // ----------------------------------------------------------------------------------------------
  // Nome do usuário
  String userName = "Guest"; 
  final UserService _userService = UserService();

  @override
  void initState() {
    super.initState();

    fetchProjectNames();
    _fetchUserName();  

    _scrollController = ScrollController();
  }

    // ----------------------------------------------------------------------------------------------
    // Método para buscar o nome do usuário atual
    Future<void> _fetchUserName() async {
      // Marca usuario como logado

      try {
        isLoggedIn = await _userService.isAuthenticated();
        final user = await _userService.getUser();

        setState(() {
          userName = user["name"];
        });
      } catch(e) {
        return;
      }
    }
  // ----------------------------------------------------------------------------------------------


  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // ----------------------------------------------------------------------------------------------
  // Método para verificar o status de login do usuário
  Future<void> checkUserStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
      userIconPath = prefs.getString('userIconPath');
      if (isLoggedIn && userIconPath != null) {
        userImage = userIconPath;
      } else {
        userImage = 'assets/images/default_user.png';
      }
    });
  }

  void loadProjectFromFile() async {
    try {
      // Abre o seletor de arquivos para escolher um arquivo JSON
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'], // Permite apenas arquivos JSON
      );

      if (result == null) {
        print("Nenhum arquivo selecionado.");
        return;
      }

      // Obtém o conteúdo do arquivo, considerando plataformas com ou sem path
      String? fileContent;

      if (kIsWeb) {
        // Plataforma web: Use os bytes para ler o arquivo
        Uint8List? fileBytes = result.files.single.bytes;
        if (fileBytes != null) {
          fileContent = utf8.decode(fileBytes);
        } else {
          print("Erro: arquivo vazio ou bytes inválidos.");
          return;
        }
      } else {
        // Outras plataformas: Use o caminho do arquivo
        String? filePath = result.files.single.path;
        if (filePath != null) {
          File file = File(filePath);
          fileContent = await file.readAsString();
        } else {
          print("Erro: caminho do arquivo inválido.");
          return;
        }
      }

      // Verifica se o conteúdo do arquivo foi carregado
      if (fileContent == null || fileContent.isEmpty) {
        print("Erro: conteúdo do arquivo inválido ou vazio.");
        return;
      }

      // Decodifica o JSON
      late Map<String, dynamic> jsonProject;
      try {
        jsonProject = jsonDecode(fileContent);
      } catch (e) {
        print("Erro ao decodificar o JSON: $e");
        return;
      }

      // Solicita ao usuário um nome para o projeto importado
      String? importedProjectName = await _showImportProjectDialog();
      if (importedProjectName == null) {
        print("Usuário cancelou a importação.");
        return;
      }

      // Define o nome do projeto e cria o novo projeto
      project_name = importedProjectName;
      await _projectService.create();

      // Pega o ID do projeto (Carerga todos os projetos e pega o ID do ultimo)
      Map<String, String> tempProjects = await _projectService.getProjectNames();

      // Obter todas as chaves do mapa
      List<String> keys = tempProjects.keys.toList();
      String temp_projectId = keys.last; // Id do ultimo projeto

      // Carrega o projeto do arquivo e restaura algumas informações
      loadProjectData(jsonProject);
      project_name = importedProjectName;
      current_projectId = temp_projectId;

      // Salva o projeto
      await _projectService.save(temp_projectId);

      // Atualiza o estado para mostrar os novos projetos
      setState(() {
        fetchProjectNames();
      });

      print("Projeto carregado com sucesso: $project_name");
    } catch (e) {
      print("Erro ao carregar o arquivo: $e");
    }
  }


  void export_project(String projectId) async {
    try {
      // Carrega projeto
      await _projectService.loadProjectById(projectId);
    } catch(e) {
      return;
    }

    // Transforma projeto em json
    var jsonProject = stringifyProject();

    // Condicional para diferenciar entre plataformas
    if (kIsWeb) {
      // Se for Web, faz o download do arquivo
      final blob = html.Blob([Uint8List.fromList(utf8.encode(jsonProject))]);
      final url = html.Url.createObjectUrlFromBlob(blob);

      final anchor = html.AnchorElement(href: url)
        ..target = 'blank'
        ..download = 'project_$projectId.json';

      anchor.click();
      html.Url.revokeObjectUrl(url);
      print('Arquivo pronto para download como project_$projectId.json');
    } else {
      // Se for desktop ou mobile, salva o arquivo no sistema de arquivos
      String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

      if (selectedDirectory == null) {
        // O usuário cancelou a seleção do diretório
        print("Nenhum diretório foi selecionado.");
        return;
      }

      // Define o caminho e o nome do arquivo
      final filePath = '$selectedDirectory/project_$projectId.json';

      // Cria e escreve no arquivo
      final file = File(filePath);
      await file.writeAsString(jsonProject);

      print('Arquivo salvo em: $filePath');
    }

    //print(jsonProject);

    // Permite ao usuário escolher um diretório para salvar o arquivo
    // String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

    // if (selectedDirectory == null) {
    //   // O usuário cancelou a seleção do diretório
    //   print("Nenhum diretório foi selecionado.");
    //   return;
    // }

    // // Define o caminho e o nome do arquivo
    // final filePath = '$selectedDirectory/project_$projectId.json';

    // // Cria e escreve no arquivo
    // final file = File(filePath);
    // await file.writeAsString(jsonProject);

    // print('Arquivo salvo em: $filePath');
  }

  Future<void> saveUserIcon(String iconPath) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userIconPath', iconPath);
    setState(() {
      userIconPath = iconPath;
    });
  }

  void updateUserStatus(bool loggedIn, String? imagePath) {
    setState(() {
      isLoggedIn = loggedIn;
      userIconPath = imagePath;
    });
  }

  Future<String?> _showImportProjectDialog() async {
    String? projectName;

    return showDialog<String?>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1D1D25),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            'Enter the Project Name',
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          content: TextField(
            autofocus: true,
            maxLength: 20,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Project name',
              hintStyle: const TextStyle(color: Colors.white38),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.white24, width: 1),
                borderRadius: BorderRadius.circular(8),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.white, width: 1.5),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onChanged: (value) {
              projectName = value;
            },
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'Cancel',
                style: TextStyle(color: Color.fromARGB(179, 252, 0, 0), fontSize: 18),
              ),
              onPressed: () {
                Navigator.of(context).pop(null); // Retorna null
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF383846),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Import',
                style: TextStyle(color: Colors.green, fontSize: 18),
              ),
              onPressed: () {
                if (projectName != null && projectName!.isNotEmpty) {
                  Navigator.of(context).pop(projectName); // Retorna o nome do projeto
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showAddProjectDialog() async {
    String? projectName;
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1D1D25),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            'Enter the Project Name',
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          content: TextField(
            autofocus: true,
            maxLength: 20,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Project name',
              hintStyle: const TextStyle(color: Colors.white38),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.white24, width: 1),
                borderRadius: BorderRadius.circular(8),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.white, width: 1.5),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onChanged: (value) {
              projectName = value;
            },
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'Cancel',
                style: TextStyle(color: Color.fromARGB(179, 252, 0, 0), fontSize: 18),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF383846),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Create',
                style: TextStyle(color: Colors.green, fontSize: 18),
              ),
              onPressed: () async {
                if (projectName != null && projectName!.isNotEmpty) {
                  project_name = projectName!;

                  await _projectService.create();

                  await Future.delayed(const Duration(milliseconds: 200));

                  fetchProjectNames();

                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showDeleteConfirmationDialog(int index) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1D1D25),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            'Delete Project',
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          content: const Text(
            'Are you sure you want to delete this project?',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'Cancel',
                style: TextStyle(color: Color.fromARGB(179, 252, 0, 0), fontSize: 18),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF383846),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.redAccent, fontSize: 18),
              ),
              onPressed: () async {
                await _projectService.deleteProject(projects[index][0]);

                await Future.delayed(const Duration(milliseconds: 200));

                fetchProjectNames();

                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void fetchProjectNames() async {
    try {
      var response = await _projectService.getProjectNames();

      projects.clear();
      setState(() {
        response.forEach((k, v) => projects.add([k, v]));
      });
    } catch(e) {
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    bool _loadedProject = loadedProject;

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        body: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/playing_piano.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF303047).withOpacity(0.97),
                    Color(0xFF1D1D26).withOpacity(0.97),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            SafeArea(
              top: true,
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: PopupMenuButton<int>(
                        onSelected: (value) async {
                          if (value == 1) {
                            print('Change account icon selected');
                          } else if (value == 2) {
                            _userService.logout();

                            setState(() {
                              isLoggedIn = false;
                              userImage = null;
                            });
                            print('Logout selected');
                          } else if (value == 3) {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => LoginPage(),
                                ),
                              );
                          }
                        },
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Color.fromRGBO(18, 18, 23, 0.9),  // Cor de fundo igual à do popup
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: isLoggedIn && userImage != null
                                ? ClipOval(
                                    child: Image.asset(
                                      userImage!,
                                      fit: BoxFit.cover,
                                      width: 70,
                                      height: 70,
                                    ),
                                  )
                                : Icon(
                                    Icons.person,
                                    color: Colors.white,
                                    size: 40,
                                  ),
                          ),
                        ),
                        itemBuilder: (context) => [
                          PopupMenuItem<int>(
                            value: 0,
                            child: Text(
                              'User: ${isLoggedIn ? userName : "Guest"}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,  // Cor do texto igual ao do popup
                              ),
                            ),
                            enabled: false,
                          ),
                          PopupMenuDivider(),
                          PopupMenuItem<int>(
                            value: 1,
                            child: Row(
                              children: [
                                Icon(Icons.image, color: Colors.white),  // Ícone com cor branca
                                SizedBox(width: 10),
                                Text('Change Icon', style: TextStyle(color: Colors.white)),  // Texto branco
                              ],
                            ),
                          ),
                          if (isLoggedIn)
                            PopupMenuItem<int>(
                              value: 2,
                              child: Row(
                                children: [
                                  Icon(Icons.logout, color: Colors.white), // Icon with white color
                                  SizedBox(width: 10),
                                  Text('Logout', style: TextStyle(color: Colors.white)), // Text with white color
                                ],
                              ),
                            )
                          else
                            PopupMenuItem<int>(
                              value: 3,
                              child: Row(
                                children: [
                                  Icon(Icons.login, color: Colors.white), // Icon with white color
                                  SizedBox(width: 10),
                                  Text('Login', style: TextStyle(color: Colors.white)), // Text with white color
                                ],
                              ),
                            ),
                        ],
                        color: Color(0xFF1D1D25),  // Cor do fundo do PopupMenuButton
                        offset: Offset(85, 0), // Posição do popup
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Expanded(
                    flex: 3,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                FlutterFlowIconButton(
                                  borderRadius: 20,
                                  borderWidth: 1,
                                  buttonSize: 80,
                                  fillColor: _loadedProject
                                  ? Color.fromRGBO(18, 18, 23, 0.9) // Active color
                                  : Color.fromRGBO(18, 18, 23, 0.3), // Grey out the color when disabled
                                  hoverColor: Color.fromRGBO(18, 18, 23, 0.6),
                                  hoverIconColor: Colors.white,
                                  icon: FaIcon(
                                    FontAwesomeIcons.arrowLeft,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                                  onPressed: _loadedProject ? () {
                                    Navigator.pushReplacement(
                                      context,
                                      PageRouteBuilder(
                                        pageBuilder: (context, animation1, animation2) => ProjectPageWidget(),
                                        transitionDuration: Duration.zero,
                                        reverseTransitionDuration: Duration.zero,
                                      ),
                                    );
                                  } : null,
                                ),
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(0, 5, 0, 0),
                                  child: Text(
                                    'Return',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(width: 50),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                FlutterFlowIconButton(
                                  borderRadius: 20,
                                  borderWidth: 1,
                                  buttonSize: 80,
                                  fillColor: Color.fromRGBO(18, 18, 23, 0.9),
                                  hoverColor: Color.fromRGBO(18, 18, 23, 0.6),
                                  hoverIconColor: Colors.white,
                                  icon: FaIcon(
                                    FontAwesomeIcons.plus,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _showAddProjectDialog();
                                    });
                                  },
                                ),
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(0, 5, 0, 0),
                                  child: Text(
                                    'New Project',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(width: 50),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                FlutterFlowIconButton(
                                  borderRadius: 20,
                                  borderWidth: 1,
                                  buttonSize: 80,
                                  fillColor: Color.fromRGBO(18, 18, 23, 0.9),
                                  hoverColor: Color.fromRGBO(18, 18, 23, 0.6),
                                  hoverIconColor: Colors.white,
                                  icon: Icon(
                                    Icons.upload_file,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                                  onPressed: () {
                                    loadProjectFromFile();
                                  },
                                ),
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(0, 5, 0, 0),
                                  child: Text(
                                    'Load Project',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Container(
                        width: MediaQuery.sizeOf(context).width,
                        height: 10,
                        decoration: BoxDecoration(
                          color: Color(0xFF090C1E),
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    flex: 2,
                    child: RawScrollbar(
                      controller: _scrollController,
                      thumbColor: Color.fromRGBO(58, 58, 71, 1),
                      trackColor: Color.fromRGBO(20, 20, 28, 1),
                      thumbVisibility: true,
                      trackVisibility: true,
                      radius: Radius.circular(20),
                      thickness: 12,
                      child: ListView.builder(
                        controller: _scrollController,
                        scrollDirection: Axis.horizontal,
                        itemCount: projects.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () async {
                              await _projectService.loadProjectById(projects[index][0]);

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProjectPageWidget(
                                    projectName: projects[index][1],
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              width: MediaQuery.sizeOf(context).width * 0.3,
                              height: MediaQuery.sizeOf(context).width * 0.3,
                              margin: EdgeInsets.only(bottom: 15, top: 2, left: 5, right: 5),
                              decoration: BoxDecoration(
                                color: Color(0xFF14141C),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Column(
                                children: [
                                  // Parte superior com o nome do projeto e ícones
                                  Container(
                                    padding: EdgeInsets.all(8),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        // Ícone para exportar o arquivo
                                        IconButton(
                                          icon: Icon(Icons.file_download, color: Colors.white),
                                          onPressed: () {
                                            export_project(projects[index][0]);
                                            // Lógica para exportar o arquivo
                                            //print('Exporting project...');
                                          },
                                        ),
                                        // Nome do projeto centralizado
                                        Expanded(
                                          child: Center(
                                            child: Text(
                                              projects[index][1],
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 20,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),
                                        // Ícone para deletar o projeto
                                        IconButton(
                                          icon: Icon(Icons.delete, color: Colors.red),
                                          onPressed: () {
                                            _showDeleteConfirmationDialog(index);
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                  
                                  // Linha de separação entre o topo e o futuro espaço da imagem
                                  Container(
                                    height: 1,  // Espessura da linha
                                    color: Colors.white, // Cor da linha de separação
                                  ),
                                  
                                  // Parte inferior para a imagem ou conteúdo adicional no futuro
                                  Expanded(
                                    child: Center(
                                      child: Image.asset(
                                        'assets/images/default_project.png',
                                      fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
