import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:maisound/classes/globals.dart';
import 'package:maisound/classes/instrument.dart';
import 'package:maisound/classes/track.dart';

// Codifica o projeto em JSON
String stringifyProject() {
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
    return jsonEncode(jsonFinal);
}

// Carrega o projeto
void loadProjectData(Map<String, dynamic> data) {
  // Configurações do projeto
  project_name = data["name"];
  current_projectId = data["_id"];
  BPM = data["bpm"]+0.0;

  // Limpa listas de instrumentos e faixas atuais
  instruments.clear();
  tracks.clear();

  // Decodifica e cria instrumentos
  List<dynamic> instrumentsData = data["instruments"];
  for (var instrumentData in instrumentsData) {
    Instrument instrument = Instrument();

    // Extrai apenas o código hexadecimal da cor
    String colorString = instrumentData["color"];
    colorString = colorString.replaceAll('Color(', '').replaceAll(')', '');

    instrument.name = instrumentData["name"];
    instrument.color = Color(int.parse(colorString)); // Converte hexadecimal para Color
    instrument.volume = instrumentData["volume"] ?? 0.5; // Define volume padrão caso não exista

    instruments.add(instrument);
  }

  // Decodifica e cria faixas
  List<dynamic> tracksData = data["tracks"];
  for (var trackData in tracksData) {
    int instrumentIndex = trackData["instrumentIndex"];
    Instrument trackInstrument = instruments[instrumentIndex];

    Track track = Track(trackInstrument);

    track.startTime = trackData["startTime"]?.toDouble();
    track.duration  = trackData["duration"]?.toDouble();

    // Decodifica e adiciona notas à faixa
    List<dynamic> notesData = trackData["notes"];
    for (var noteData in notesData) {
      Note note = Note(
        noteName: noteData["noteName"],

        // HACK
        startTime: noteData["startTime"] is int
          ? (noteData["startTime"] as int).toDouble()
          : noteData["startTime"] as double? ?? 0.0,

        duration: noteData["duration"] is int
          ? (noteData["duration"] as int).toDouble()
          : noteData["duration"] as double? ?? 0.0,
      );
      track.addNote(note);
    }

    tracks.add(track);
  }

  // Caso não tenha nenhum instrumento, adiciona um por padrão
  if (instruments.isEmpty) {
    instruments.add(Instrument());
  }
}



class ProjectService {
  // URL base da API
  final String baseUrl = "http://localhost:5000";

  // Deleta um projeto usando o ID dele
  Future<void> deleteProject(String projectId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/api/auth/project/$projectId'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      // Projeto deletado com sucesso
      print('Projeto deletado com sucesso');
    } else {
      throw Exception('Erro ao deletar o projeto: ${response.body}');
    }
  }

  // Recebe todas as informações de um projeto pelo ID
  Future<Map<String, dynamic>> loadProjectById(String projectId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/auth/project/$projectId'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);

      // Carrega o projeto
      loadProjectData(data['project']);

      return data['project']; // Retorna os dados do projeto
    } else {
      throw Exception('Erro ao receber o projeto: ${response.body}');
    }
  }

  // Recebe nome de todos projetos do usuário
  Future<Map<String, String>> getProjectNames() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/auth/project'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      
      // Converte a lista de projetos em um mapa
      final Map<String, String> projectNames = {};

      for (var project in data['projects']) {
        projectNames[project['id']] = project['name'];
      }
      
      return projectNames; // Retorna o mapa com IDs e nomes dos projetos
    } else {
      throw Exception('Erro ao receber a lista de projetos: ${response.body}');
    }
  }


  // Envia a mensagem para a API
  Future<void> create() async {

    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/project'),

      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: stringifyProject(), // Converte o projeto em um json
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

  // Envia a mensagem para a API para atualizar o projeto
  Future<void> save(String projectId) async {
    final response = await http.put(
      Uri.parse('$baseUrl/api/auth/project/$projectId'), // Inclui o ID do projeto na URL
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: stringifyProject(), // Converte o projeto em um JSON
    );

    if (response.statusCode == 200) {
      print('Projeto atualizado com sucesso');
    } else {
      throw Exception('Erro ao atualizar o projeto: ${response.body}');
    }
  }
}
