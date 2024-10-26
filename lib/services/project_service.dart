import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:maisound/classes/globals.dart';
import 'package:maisound/classes/instrument.dart';
import 'package:maisound/classes/track.dart';

class ProjectService {
  // URL base da API
  final String baseUrl = "http://localhost:5000";

  // Recebe nome de todos projetos do usuario
  Future<List<String>> getProjectNames() async {

    final response = await http.get(
      Uri.parse('$baseUrl/api/auth/project'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return List<String>.from(data['projectNames']); // Extrai e retorna apenas os nomes dos projetos
    } else {
      throw Exception('Erro ao receber a lista de projetos: ${response.body}');
    }
  }


  // Envia a mensagem para a API
  Future<void> save() async {

    // =============================
    // Converte o projeto em um JSON

    // Inicializa jsonFinal vazio
    Map<String, dynamic> jsonFinal = {};

    // Converte instrumentos (objeto) em uma lista de instrumentos (JSON)
    List<Map<String, dynamic>> instrumentsMap = [];

    instruments.forEach((instrumentNew) {
      Map<String, dynamic> instrumentJson = {
        "name": instrumentNew.name,
        "color": instrumentNew.color.toString(),
        "index": instruments.indexOf(instrumentNew),
        "volume": instrumentNew.volume,
      };
      instrumentsMap.add(instrumentJson);
    });

    // Adiciona instrumentos ao jsonFinal
    jsonFinal["instruments"] = instrumentsMap;

    // Converte tracks (objeto) em uma lista de tracks (JSON)
    List<Map<String, dynamic>> tracksMap = [];

    tracks.forEach((track) {
      Map<String, dynamic> trackJson = {
        "startTime": track.startTime,
        "duration": track.duration,
        "notes": <Map<String, dynamic>>[],
        "instrumentIndex": instruments.indexOf(track.instrument),
      };

      // Adiciona as notas da track
      track.getNotes().forEach((note) {
        Map<String, dynamic> noteJson = {
          "noteName": note.noteName,
          "startTime": note.startTime,
          "duration": note.duration,
        };
        trackJson["notes"]?.add(noteJson); // Agora vai funcionar
      });

      tracksMap.add(trackJson);
    });

    // Adiciona tracks ao jsonFinal
    jsonFinal["tracks"] = tracksMap;

    // Informações do projeto
    jsonFinal["name"] = project_name;
    jsonFinal["BPM"] = BPM;

    // Converte jsonFinal para uma string JSON
    //String jsonString = jsonEncode(jsonFinal);

    // =============================

    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/project'),

      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(jsonFinal),
      // body: jsonEncode(<String, String>{
      //   "prompt": prompt,
      // }),
    );

    if (response.statusCode == 201) {
      print('Projeto salvo com sucesso');
    } else {
      throw Exception('Erro ao enviar a mensagem: ${response.body}');
    }
  }
}
