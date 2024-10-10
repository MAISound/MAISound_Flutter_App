import 'package:maisound/cadastro_page.dart';
import 'package:maisound/home_page.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:maisound/project_page.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo_dart;
import 'package:maisound/track_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

export 'package:flutterflow_ui/flutterflow_ui.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  // Lista de projetos criados:
  List<String> projects = [];

  // Função para salvar um projeto no MongoDB
  Future<void> saveProjectToDatabase(String projectName) async {
    var db = await mongo.Db.create(
        'mongodb://cc23317:4nei7agNH9rVqeY3@maisound.0pola.mongodb.net/main?ssl=true&replicaSet=Main-shard-0&authSource=admin&retryWrites=true');
    await db.open();

    var collection = db.collection('projects');

    String generateProjectId() => mongo_dart.ObjectId().toHexString();
    var userId = mongo_dart.ObjectId().toHexString();

    var newProject = {
      "_id": generateProjectId(),
      "userId": userId,
      "name": projectName,
      "createdAt": DateTime.now(),
    };

    await collection.insert(newProject);
    await db.close();
  }

  //Metodo da caixa de dialogo para inserir o nome do projeto:
  Future<void> _showAddProjectDialog() async {
    String? projectName;
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // O usuário deve inserir o nome ou cancelar.
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter Project Name'),
          content: TextField(
            autofocus: true,
            maxLength: 20,
            decoration: InputDecoration(
              hintText: 'Project Name',
            ),
            onChanged: (value) {
              projectName = value;
            },
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context)
                    .pop(); // Fecha a caixa de diálogo sem criar o projeto.
              },
            ),
            ElevatedButton(
              child: Text('Create'),
              onPressed: () async {
                if (projectName != null && projectName!.isNotEmpty) {
                  setState(() {
                    projects
                        .add(projectName!); // Adiciona um novo projeto à lista.
                  });

                  _saveProjects(); // Salva o projeto criado.

                  await saveProjectToDatabase(projectName!); // Salva no MongoDB

                  Navigator.of(context).pop(); // Fecha a caixa de diálogo.
                }
              },
            ),
          ],
        );
      },
    );
  }

  // Método da caixa de diálogo para confirmar a exclusão do projeto:
  Future<void> _showDeleteConfirmationDialog(int index) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // O usuário deve confirmar.
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Project'),
          content: Text('Are you sure you want to delete this project?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Fecha a caixa de diálogo.
              },
            ),
            ElevatedButton(
              child: Text('Delete'),
              onPressed: () {
                setState(() {
                  projects.removeAt(index); // Remove o projeto da lista.
                  _saveProjects(); // Salva os projetos Atualizados.
                });
                Navigator.of(context).pop(); // Fecha a caixa de diálogo.
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  // Carrega os projetos salvos:
  void _loadProjects() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      projects = prefs.getStringList('projects') ?? [];
    });
  }

  // Salva os projetos:
  void _saveProjects() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList('projects', projects);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Color(0xFF303047),
        body: SafeArea(
          top: true,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Botões no topo da página
              Expanded(
                flex: 3,
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Botão de Menu
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
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
                              // Abre a caixa de dialogo para inserir o nome do projeto.
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
                  ].divide(SizedBox(width: 106)),
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

              // Lista de Projetos Criados
              Expanded(
                flex: 2,
                child: Scrollbar(
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: projects.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProjectPageWidget(
                                  projectName: projects[index]),
                            ),
                          );
                        },
                        child: Container(
                          width: MediaQuery.sizeOf(context).width * 0.3,
                          height: MediaQuery.sizeOf(context).width * 0.3,
                          margin: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Color(0xFF14141C),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Stack(
                            children: [
                              Center(
                                child: Text(
                                  projects[index],
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 20),
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
