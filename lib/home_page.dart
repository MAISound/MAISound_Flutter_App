import 'package:maisound/classes/globals.dart';
import 'package:maisound/home_page.dart';
import 'package:maisound/services/project_service.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:maisound/project_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:maisound/login_page.dart';
import 'package:maisound/services/user_service.dart'; 


export 'package:flutterflow_ui/flutterflow_ui.dart';

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
    checkUserStatus();
    _fetchUserName();  
    _scrollController = ScrollController();
  }

    // ----------------------------------------------------------------------------------------------
    // Método para buscar o nome do usuário atual
    Future<void> _fetchUserName() async {
      // Marca usuario como logado
      isLoggedIn = await _userService.isAuthenticated();
      final user = await _userService.getUser();

      setState(() {
        userName = user["name"];
      });
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
    var response = await _projectService.getProjectNames();

    print(response);

    projects.clear();
    setState(() {
      response.forEach((k, v) => projects.add([k, v]));
    });
  }

  @override
  Widget build(BuildContext context) {
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
                          PopupMenuItem<int>(
                            value: 2,
                            child: Row(
                              children: [
                                Icon(Icons.logout, color: Colors.white),  // Ícone com cor branca
                                SizedBox(width: 10),
                                Text('Logout', style: TextStyle(color: Colors.white)),  // Texto branco
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
                                  fillColor: Color.fromRGBO(18, 18, 23, 0.9),
                                  hoverColor: Color.fromRGBO(18, 18, 23, 0.6),
                                  hoverIconColor: Colors.white,
                                  icon: FaIcon(
                                    FontAwesomeIcons.bars,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                                  onPressed: () {
                                    print('MenuButton pressed ...');
                                  },
                                ),
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(0, 5, 0, 0),
                                  child: Text(
                                    'Menu',
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
                                    print('Load Project button pressed...');
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
                                            // Lógica para exportar o arquivo
                                            print('Exporting project...');
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
