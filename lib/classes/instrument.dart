import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:maisound/classes/globals.dart';
// For rootBundle

enum InstrumentTypes {
  piano,
  bass,
  saxofone,
}

// Define the order of note letters
List<String> noteLetterOrder = [
  "C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"
];

class Note {
  String noteName;
  double startTime;
  double duration;

  Note({
    required this.noteName,
    required this.startTime,
    required this.duration
  });

  @override
  String toString() {
    return "Note: $noteName, Start Time: $startTime, Duration: $duration";
  }

  int compareTo(Note other) {
    // Extract note letter and octave from both notes
    String noteLetter1 = noteName.substring(0, noteName.length - 1);
    int octave1 = int.parse(noteName.substring(noteName.length - 1));
    String noteLetter2 = other.noteName.substring(0, other.noteName.length - 1);
    int octave2 = int.parse(other.noteName.substring(other.noteName.length - 1));

    // Compare note letters
    int letterComparison = noteLetterOrder.indexOf(noteLetter1) - noteLetterOrder.indexOf(noteLetter2);

    // If note letters are the same, compare octaves
    if (letterComparison == 0) {
      return octave1 - octave2;
    } else {
      return letterComparison;
    }
  }

  int noteNameToInteger() {
    noteName = this.noteName;

    // Extract note letter and octave
    String noteLetter = noteName.substring(0, noteName.length - 1);
    int octave = int.parse(noteName.substring(noteName.length - 1));

    // Map note letter to an integer value (starting from 0 for C)
    int noteLetterValue = noteLetterOrder.indexOf(noteLetter);

    // Calculate the final integer value
    return noteLetterValue + (octave - 1) * 12;
  }
}


class Instrument {
  Map<String, String> sounds = {};
  Map<String, AudioPlayer> activePlayers = {}; // Store active players for each note
  Map<String, bool> isFadingOut = {}; // Track whether a fade-out is in progress for each note
  InstrumentTypes type = InstrumentTypes.piano;
  double volume = 0.5;
  String name = "Generic";
  Color color = Colors.white;
  int maxSimultaneousNotes = 10; // Limit the number of notes played at the same time
  List<String> activeNotesOrder = []; // Track order of active notes
  
  Instrument() {
    // Por padrão um piano é carregado
    setInstrumentType(InstrumentTypes.piano);
  }

  void setInstrumentType(InstrumentTypes type) {
    if (type == InstrumentTypes.bass) {
      name = "Bass";
      color = Color.fromARGB(255, 233, 38, 38);
    }
    if (type == InstrumentTypes.piano) {
      name = "Piano";
      color = Color.fromARGB(255, 60, 104, 248);
    }
    if (type == InstrumentTypes.saxofone){
      name = "Saxofone";
      color = Color.fromARGB(255, 20, 252, 78);
    }

    this.type = type;

    loadSounds(type);
  }

  void playSound(String key) async {
    key = key.toUpperCase();

    // Verifica se a nota existe
    if (!sounds.containsKey(key)) {
      return;
    }

    // Se já há notas ativas, para a mais antiga
    if (activePlayers.length >= maxSimultaneousNotes) {
      String oldestNote = activeNotesOrder.removeAt(0); // Remove o mais antigo
      stopSound(oldestNote); // Para a nota mais antiga
    }

    // Stop the current note if it's being played to allow quick repetitions
    if (activePlayers.containsKey(key)) {
      stopSound(key);
    }

    // Cria um novo AudioPlayer para tocar o som
    AudioPlayer notePlayer = AudioPlayer();
    
    // Define o volume inicial
    notePlayer.setVolume(volume * master_volume);

    // Toca o som usando assets
    await notePlayer.play(AssetSource(sounds[key]!));
    
    // Armazena o player no map
    activePlayers[key] = notePlayer;
    activeNotesOrder.add(key); // Adiciona à lista de notas ativas
    isFadingOut[key] = false;

    // Libera o recurso do player após o término da reprodução
    notePlayer.onPlayerComplete.listen((event) {
      activePlayers.remove(key); // Remove o player do map quando terminar
      activeNotesOrder.remove(key); // Remove a nota ativa
      isFadingOut.remove(key); // Remove o flag de fade-out
      notePlayer.dispose();
    });
  }

  // Para todos os sons
  void fullStopAllSounds() {
    for (String key in activePlayers.keys.toList()) {
      stopSound(key);
    }
  }

  void stopSound(String key, {Duration fadeOutDuration = const Duration(milliseconds: 250)}) async {
    key = key.toUpperCase();

    // Check if there's a player playing this note
    if (activePlayers.containsKey(key)) {
      AudioPlayer notePlayer = activePlayers[key]!;

      // If a fade-out is already in progress, do not start another
      if (isFadingOut[key] == true) {
        return;
      }

      // Mark that fade-out is in progress
      isFadingOut[key] = true;

      // Gradually reduce the volume
      await fadeOut(notePlayer, fadeOutDuration, key);

      // If the fade-out was not interrupted, stop the player
      if (isFadingOut[key] == true) {
        await notePlayer.stop();
        activePlayers.remove(key);
        activeNotesOrder.remove(key);
        isFadingOut.remove(key);
        notePlayer.dispose();
      }
    }
  }

  Future<void> fadeOut(AudioPlayer player, Duration duration, String key) async {
    double initialVolume = player.volume;
    int steps = 20; // Number of steps for fading out
    double volumeStep = initialVolume / steps;
    int stepDuration = (duration.inMilliseconds / steps).round();

    for (int i = 0; i < steps; i++) {
      await Future.delayed(Duration(milliseconds: stepDuration));

      // If fade-out was interrupted, exit early
      if (isFadingOut[key] == false) {
        return;
      }

      // Calculate new volume
      double newVolume = initialVolume - (i + 1) * volumeStep;
      if (newVolume < 0) newVolume = 0;

      // Set the new volume
      try {
        await player.setVolume(newVolume);
      } catch (e) {
        print(e); // If setting volume fails, exit the loop
      }
    }
  }


  // Carrega os sons dos assets (mesmo método que você já tem)
  Future<void> loadSounds(InstrumentTypes type) async {
    sounds.clear();

    // Parametros padrão para carregar um som
    List<String> notes = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"];
    List<int> octaves = [1, 2, 3, 4, 5, 6, 7, 8];
    String? soundPath;

    if (type == InstrumentTypes.piano) {
      octaves = [3, 4, 5];
      soundPath = "piano";
    }
    if (type == InstrumentTypes.bass) {
      octaves = [4, 5, 6];
      soundPath = "bass";
    }
    if (type == InstrumentTypes.saxofone) {
      octaves = [3, 4, 5];
      soundPath = "saxofone";
    }


    // Carrega as notas do instrumento
    for (int octave in octaves) {
      for (String note in notes) {
        String noteKey = "$note$octave";
        String fileName = "instruments/$soundPath/$octave-${note.toLowerCase().replaceAll('#', 's')}.wav";
        sounds[noteKey] = fileName;
      }
    }
  }
}
