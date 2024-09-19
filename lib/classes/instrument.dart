import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
// For rootBundle


class Note {
  final String noteName;
  final double startTime;
  final double duration;

  Note({
    required this.noteName,
    required this.startTime,
    required this.duration
  });

  @override
  String toString() {
    return "Note: $noteName, Start Time: $startTime, Duration: $duration";
  }
}


class Instrument {
  Map<String, String> sounds = {};
  Map<String, AudioPlayer> activePlayers = {}; // Store active players for each note
  Map<String, bool> isFadingOut = {}; // Track whether a fade-out is in progress for each note
  double volume = 0.5;
  String name = "Piano";
  Color color = Color.fromARGB(255, 60, 104, 248);
  late List tracks;

  Instrument() {
    loadSounds();
  }

  // Toca um som de uma nota
  void playSound(String key) async {
    key = key.toUpperCase();

    // Verifica se a nota existe
    if (!sounds.containsKey(key)) {
      return;
    }

    // Se a nota já está sendo tocada, não a toca novamente
    if (activePlayers.containsKey(key)) {
      return;
    }

    // Cria um novo AudioPlayer para tocar o som
    AudioPlayer notePlayer = AudioPlayer();
    
    // Define o volume inicial
    notePlayer.setVolume(volume);

    // Toca o som usando assets
    await notePlayer.play(AssetSource(sounds[key]!));
    
    // Armazena o player no map
    activePlayers[key] = notePlayer;
    isFadingOut[key] = false;

    // Libera o recurso do player após o término da reprodução
    notePlayer.onPlayerComplete.listen((event) {
      activePlayers.remove(key); // Remove o player do map quando terminar
      isFadingOut.remove(key); // Remove o flag de fade-out
      notePlayer.dispose();
    });
  }

  // Para o som de uma nota com fade out
  void stopSound(String key, {Duration fadeOutDuration = const Duration(milliseconds: 500)}) async {
    key = key.toUpperCase();

    // Verifica se há um player tocando essa nota
    if (activePlayers.containsKey(key)) {
      AudioPlayer notePlayer = activePlayers[key]!;

      // Se o fade-out já está em progresso, não inicia outro
      if (isFadingOut.containsKey(key) && isFadingOut[key]!) {
        return;
      }

      // Marca que o fade-out está em progresso
      isFadingOut[key] = true;

      // Gradualmente reduz o volume
      await fadeOut(notePlayer, fadeOutDuration);

      // Para o som e remove o player do map
      await notePlayer.stop();
      activePlayers.remove(key);
      isFadingOut.remove(key);
      notePlayer.dispose();
    }
  }

  // Método para o fade out
  Future<void> fadeOut(AudioPlayer player, Duration duration) async {
    double initialVolume = player.volume;
    int steps = 20; // Number of steps for fading out
    double volumeStep = initialVolume / steps;
    int stepDuration = (duration.inMilliseconds / steps).round();

    for (int i = 0; i < steps; i++) {
      await Future.delayed(Duration(milliseconds: stepDuration));
      double newVolume = initialVolume - (i + 1) * volumeStep;
      if (newVolume < 0) newVolume = 0;
      if (player == activePlayers.values.firstWhere((p) => p == player, orElse: () => player)) {
        await player.setVolume(newVolume);
      }
    }
  }

  // Carrega os sons dos assets (mesmo método que você já tem)
  Future<void> loadSounds() async {
    // Adiciona os caminhos das notas manualmente
    sounds["C1"] = "instruments/piano/3-c.wav";
    sounds["C#1"] = "instruments/piano/3-cs.wav";
    sounds["D1"] = "instruments/piano/3-d.wav";
    sounds["D#1"] = "instruments/piano/3-ds.wav";
    sounds["E1"] = "instruments/piano/3-e.wav";
    sounds["F1"] = "instruments/piano/3-f.wav";
    sounds["F#1"] = "instruments/piano/3-fs.wav";
    sounds["G1"] = "instruments/piano/3-g.wav";
    sounds["G#1"] = "instruments/piano/3-gs.wav";
    sounds["A1"] = "instruments/piano/3-a.wav";
    sounds["A#1"] = "instruments/piano/3-as.wav";
    sounds["B1"] = "instruments/piano/3-b.wav";
    sounds["C2"] = "instruments/piano/3-c.wav";
    sounds["C#2"] = "instruments/piano/3-cs.wav";
    sounds["D2"] = "instruments/piano/3-d.wav";
    sounds["D#2"] = "instruments/piano/3-ds.wav";
    sounds["E2"] = "instruments/piano/3-e.wav";
    sounds["F2"] = "instruments/piano/3-f.wav";
    sounds["F#2"] = "instruments/piano/3-fs.wav";
    sounds["G2"] = "instruments/piano/3-g.wav";
    sounds["G#2"] = "instruments/piano/3-gs.wav";
    sounds["A2"] = "instruments/piano/3-a.wav";
    sounds["A#2"] = "instruments/piano/3-as.wav";
    sounds["B2"] = "instruments/piano/3-b.wav";
    sounds["C3"] = "instruments/piano/3-c.wav";
    sounds["C#3"] = "instruments/piano/3-cs.wav";
    sounds["D3"] = "instruments/piano/3-d.wav";
    sounds["D#3"] = "instruments/piano/3-ds.wav";
    sounds["E3"] = "instruments/piano/3-e.wav";
    sounds["F3"] = "instruments/piano/3-f.wav";
    sounds["F#3"] = "instruments/piano/3-fs.wav";
    sounds["G3"] = "instruments/piano/3-g.wav";
    sounds["G#3"] = "instruments/piano/3-gs.wav";
    sounds["A3"] = "instruments/piano/3-a.wav";
    sounds["A#3"] = "instruments/piano/3-as.wav";
    sounds["B3"] = "instruments/piano/3-b.wav";
    sounds["C4"] = "instruments/piano/4-c.wav";
    sounds["C#4"] = "instruments/piano/4-cs.wav";
    sounds["D4"] = "instruments/piano/4-d.wav";
    sounds["D#4"] = "instruments/piano/4-ds.wav";
    sounds["E4"] = "instruments/piano/4-e.wav";
    sounds["F4"] = "instruments/piano/4-f.wav";
    sounds["F#4"] = "instruments/piano/4-fs.wav";
    sounds["G4"] = "instruments/piano/4-g.wav";
    sounds["G#4"] = "instruments/piano/4-gs.wav";
    sounds["A4"] = "instruments/piano/4-a.wav";
    sounds["A#4"] = "instruments/piano/4-as.wav";
    sounds["B4"] = "instruments/piano/4-b.wav";
    sounds["C5"] = "instruments/piano/5-c.wav";
    sounds["C#5"] = "instruments/piano/5-cs.wav";
    sounds["D5"] = "instruments/piano/5-d.wav";
    sounds["D#5"] = "instruments/piano/5-ds.wav";
    sounds["E5"] = "instruments/piano/5-e.wav";
    sounds["F5"] = "instruments/piano/5-f.wav";
    sounds["F#5"] = "instruments/piano/5-fs.wav";
    sounds["G5"] = "instruments/piano/5-g.wav";
    sounds["G#5"] = "instruments/piano/5-gs.wav";
    sounds["A5"] = "instruments/piano/5-a.wav";
    sounds["A#5"] = "instruments/piano/5-as.wav";
    sounds["B5"] = "instruments/piano/5-b.wav";
  }

  bool isNumeric(String s) {
    if (s.isEmpty) {
      return false;
    }
    try {
      double.parse(s);
      return true;
    } catch (e) {
      return false;
    }
  }

  String normalizeName(String key) {
    String normalKey = "";
    if (isNumeric(key[0])) {
      List<String> parts = key.split("-");
      String octave = parts[0];
      String keyName = parts[1];

      normalKey += keyName[0];
      if (keyName.length == 2) {
        normalKey += "#";
      }
      normalKey += octave;
    } else {
      normalKey = key;
    }

    return normalKey.toUpperCase();
  }
}
