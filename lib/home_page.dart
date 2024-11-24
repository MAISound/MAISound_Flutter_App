import 'package:maisound/classes/globals.dart';
import 'package:maisound/home_page.dart';
import 'package:maisound/services/project_service.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:maisound/project_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:maisound/login_page.dart'; 

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

  @override
  void initState() {
    super.initState();
    fetchProjectNames();
    checkUserStatus();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // Função para verificar se o usuário está logado usando SharedPreferences
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

  //Função para salvar o ícone escolhido pelo usuário
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

  // // Função para salvar um projeto no MongoDB
  // Future<void> saveProjectToDatabase(String projectName) async {
  //   var db = await mongo.Db.create(
  //       'mongodb://cc23317:4nei7agNH9rVqeY3@maisound.0pola.mongodb.net/main?ssl=true&replicaSet=Main-shard-0&authSource=admin&retryWrites=true');
  //   await db.open();

  //   var collection = db.collection('projects');

  //   String generateProjectId() => mongo_dart.ObjectId().toHexString();
  //   var userId = mongo_dart.ObjectId().toHexString();

  //   var newProject = {
  //     "_id": generateProjectId(),
  //     "userId": userId,
  //     "name": projectName,
  //     "createdAt": DateTime.now(),
  //   };

  //   await collection.insert(newProject);
  //   await db.close();
  // }

  //Metodo da caixa de dialogo para inserir o nome do projeto:
  Future<void> _showAddProjectDialog() async {
  String? projectName;
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // O usuário deve inserir o nome ou cancelar.
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: const Color(0xFF1D1D25), // Combina com o tema
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
              Navigator.of(context).pop(); // Fecha a caixa de diálogo sem criar o projeto.
            },
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF383846), // Botão destacado
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
                project_name = projectName!; // Muda nome global do projeto

                // Aguarda a confirmação de que o projeto foi salvo
                await _projectService.create();

                // Adiciona um pequeno atraso para garantir que o banco de dados seja atualizado
                await Future.delayed(const Duration(milliseconds: 200));

                // Atualiza a lista de projetos após o atraso
                fetchProjectNames();

                Navigator.of(context).pop(); // Fecha a caixa de diálogo.
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
    barrierDismissible: false, // User must confirm.
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: const Color(0xFF1D1D25), // Background color
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
              style: TextStyle(
                color: Color.fromARGB(179, 252, 0, 0),
                fontSize: 18,
              ),
            ),
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog.
            },
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF383846), // Button color
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Delete',
              style: TextStyle(
                color: Colors.redAccent,
                fontSize: 18,
              ),
            ),
            onPressed: () async {
              await _projectService.deleteProject(projects[index][0]);

              // Add a small delay to ensure the database is updated
              await Future.delayed(const Duration(milliseconds: 200));

              // Refresh the project list after the delay
              fetchProjectNames();

              Navigator.of(context).pop(); // Close the dialog.
            },
          ),
        ],
      );
    },
  );
}


  // Carrega os projetos salvos:
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
            // Imagem de fundo
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/playing_piano.jpg'), // Caminho da imagem
                  fit: BoxFit.cover, // Ajusta a imagem para cobrir todo o espaço
                ),
              ),
            ),

            // Gradiente sobre a imagem
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF303047).withOpacity(0.97), // Cor inicial do degradê com opacidade
                    Color(0xFF1D1D26).withOpacity(0.97), // Cor final do degradê com opacidade
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          
          
          SafeArea(
            top: true,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Ícone de Perfil (Login/Logout)
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: GestureDetector(
                      onTap: () {
                        if (isLoggedIn) {
                          // Redireciona para a página do perfil -> fazer
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HomePage(), // Vai para a home page
                            ),
                          );
                        } else {
                          // Redireciona para a página de login
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
                          color: Color.fromRGBO(18, 18, 23, 0.9),
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
                    ),
                  ),
                ),

                SizedBox(height: 10), // Espaçamento abaixo do ícone de perfil

                // Botões 
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
                        // Botão de Menu
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
                        SizedBox(width: 50), // Espaço entre os botões

                        // Botão de Novo Projeto
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
                                  // Abre a caixa de diálogo para inserir o nome do projeto.
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
                        SizedBox(width: 50), // Espaço entre os botões

                        // Botão de Carregar Projeto
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
                  // Projetos
                  // Lista de Projetos Criados
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
                            // Carrega o projeto
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
                            //margin: EdgeInsets.all(10),
                            margin: EdgeInsets.only(bottom: 15, top: 2, left: 5, right: 5),
                            decoration: BoxDecoration(
                              color: Color(0xFF14141C),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Stack(
                              children: [
                                Center(
                                  child: Text(
                                    projects[index][1],
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Positioned(
                                  top: 14,
                                  right: 14,
                                  child: IconButton(
                                    icon: Icon(Icons.delete, color: Colors.red),
                                    onPressed: () {
                                      _showDeleteConfirmationDialog(index);
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                )

                // Expanded(
                  
                //   // Projetos
                //   // Lista de Projetos Criados
                  
                //   flex: 2,
                  
                //   child: Scrollbar(
                //     controller: _scrollController,
                //     child: ListView.builder(
                //       scrollDirection: Axis.horizontal,
                //       itemCount: projects.length,
                //       itemBuilder: (context, index) {
                //         return GestureDetector(
                //           onTap: () async {
                //             // Carrega o projeto
                //             await _projectService.loadProjectById(projects[index][0]);

                //             Navigator.push(
                //               context,
                //               MaterialPageRoute(
                //                 builder: (context) => ProjectPageWidget(
                //                     projectName: projects[index][1]),
                //               ),
                //             );
                //           },
                //           child: Container(
                //             width: MediaQuery.sizeOf(context).width * 0.3,
                //             height: MediaQuery.sizeOf(context).width * 0.3,
                //             margin: EdgeInsets.all(10),
                //             decoration: BoxDecoration(
                //               color: Color(0xFF14141C),
                //               borderRadius: BorderRadius.circular(20),
                //             ),
                //             child: Stack(
                //               children: [
                //                 Center(
                //                   child: Text(
                //                     projects[index][1],
                //                     //projects[index],
                //                     style: TextStyle(
                //                         color: Colors.white, fontSize: 20),
                //                     textAlign: TextAlign.center,
                //                   ),
                //                 ),
                //                 Positioned(
                //                   top: 14,
                //                   right: 14,
                //                   child: IconButton(
                //                     icon: Icon(Icons.delete, color: Colors.red),
                //                     onPressed: () {
                //                       _showDeleteConfirmationDialog(index);
                //                     },
                //                   ),
                //                 ),
                //               ],
                //             ),
                //           ),
                //         );
                //       },
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
}
