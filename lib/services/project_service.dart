import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:maisound/classes/globals.dart';
import 'package:maisound/classes/instrument.dart';
import 'package:maisound/classes/track.dart';

class Project {
  // URL base da API
  final String baseUrl = "http://localhost:5000";

  Future<void> save() async {
    final url = Uri.parse(baseUrl);
    // final body = json.encode({
    //   "name": projectName,
    //   "bpm": bpm,
    //   "instruments": instruments,
    //   "tracks": tracks,
    // });

    // Inicializa jsonFinal vazio
    Map<String, dynamic> jsonFinal = {};

    // Converte instrumentos (objeto) em uma lista de instrumentos (JSON)
    List<Map<String, dynamic>> instrumentsMap = [];

    instruments.forEach((instrumentNew) {
      Map<String, dynamic> instrumentJson = {
        "name": instrumentNew.name,
        "color": instrumentNew.color,
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

    // Converte jsonFinal para uma string JSON
    String jsonString = jsonEncode(jsonFinal);

    try {
      final response = await http.post(url,
          headers: {"content-Type": "application/json"}, body: jsonString);

      if (response.statusCode == 201) {
        print('Projeto salvo com sucesso');
      } else {
        print('Falha ao salvar o projeto: ${response.body}');
      }
    } catch (error) {
      print('Erro ao salvar o projeto: $error');
    }
  }
}
