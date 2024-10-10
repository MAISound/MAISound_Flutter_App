import 'dart:async';

import 'package:flutter/material.dart';
import 'package:maisound/classes/globals.dart';
import 'package:maisound/classes/instrument.dart';
import 'package:maisound/classes/track.dart';

class Recorder {
  // Modo de tocar track individual
  // Caso True: Toca apenas a track selecionada
  // Caso False: Toca o projeto inteiro a partir da timestamp do projeto
  ValueNotifier<bool> playOnlyTrack = ValueNotifier<bool>(false);

  // Timestamp na track atual (É uma posição relativa)  TIMESTAMP("TEMPO") DA TRACK
  ValueNotifier<double> currentTimestamp = ValueNotifier<double>(0.0);

  // Timestamp no projeto inteiro (É uma posição absoluta)
  //ValueNotifier<double> currentProjectTimestamp = ValueNotifier<double>(0.0);

  // Este timer serve para dar update no recorder
  Timer? _timer;

  // Tempo decorrido
  ValueNotifier<double> elapsedTime = ValueNotifier<double>(0.0);

  // Notas a serem tocadas e paradas
  List<List<dynamic>> toPlay = []; // [Note, instrumentIndex, startTime]
  List<List<dynamic>> playingNotes = []; // [Note, InstrumentIndex, stopTime]

  Recorder() {
    // Caso a pessoa clique no botão de play, o recorder vai começar/parar de tocar
    playingCurrently.addListener(() {
      if (playingCurrently.value) {
        play();
      } else {
        stop();
      }
    });
  }

  

  // Caso TRUE:  retorna a posição do marcador na track atual (Tempo relativo)
  // Caso FALSE: retorna a posição do marcador no projeto (Tempo absoluto)
  double getTimestamp(bool inTrackPosition) {
    if (inTrackPosition && currentTrack != null) {
      return currentTimestamp.value - currentTrack!.startTime;
    }
    return currentTimestamp.value;
  }

  // Muda a timestamp do recorder
  void setTimestamp(double timestamp, bool inTrackPosition) {
    if (inTrackPosition && currentTrack != null) {
      currentTimestamp.value = timestamp + currentTrack!.startTime;
    } else {
      currentTimestamp.value = timestamp;
    }

    // Caso a musica ainda esteja sendo tocada, para e começa a tocar ela devolta (impede alguns bugs)
    if (playingCurrently.value) {
      stop();
      play();
    }
  }

  // Tocando a track... (Usado para descobrir quando uma track mudou de repente)
  Track? playingTheTrack;
  

  String getElapsedTimeString() {
    int minutes = (elapsedTime.value / 60).floor();
    int seconds = (elapsedTime.value % 60).floor();
    return minutes.toString().padLeft(2, '0') + ":" + seconds.toString().padLeft(2, '0');
  }

  double getElapsedTime() {
    return elapsedTime.value;
  }

  void setElapsedTime(double time) {
    elapsedTime.value = time;
  }



  void update() {
    setElapsedTime(getElapsedTime()+1);
    
    // Track mudou do nada
    if (playOnlyTrack.value && playingTheTrack != currentTrack) {
      stop();
      setTimestamp(0.0, true);
      play();
    }

    // Atualiza a posição da timestamp na track e no projeto
    currentTimestamp.value += BPM / 60;

    // Toca as notas conforme o tempo passa
    while (toPlay.isNotEmpty && currentTimestamp.value >= toPlay[0][2]) { // Use adjustedStartTime (3rd value)
      // Remove nota que esta sendo tocada da lista de notas a serem tocadas
      List<dynamic> nextToPlay = toPlay.removeAt(0);
      Note note = nextToPlay[0];
      int instrumentIndex = nextToPlay[1];
      double adjustedStartTime = nextToPlay[2];

      // Toca a nota
      instruments[instrumentIndex].playSound(note.noteName);

      // Calcula quando deve parar de tocar e adiciona a lista de notas a serem paradas
      double stopTime = adjustedStartTime + note.duration;
      playingNotes.add([note, instrumentIndex, stopTime]); // Store the adjusted stop time
    }

    // Pare de tocar as notas que passaram do tempo de duração
    for (int i = playingNotes.length - 1; i >= 0; i--) {
      List<dynamic> playingNote = playingNotes[i];
      Note note = playingNote[0];
      int instrumentIndex = playingNote[1];
      double stopTime = playingNote[2];

      if (currentTimestamp.value >= stopTime) {
        instruments[instrumentIndex].stopSound(note.noteName);
        playingNotes.removeAt(i);
      }
    }

    // Optionally stop when no more notes to play or stop
    // if (toPlay.isEmpty && playingNotes.isEmpty) {
    //   stop();
    // }

    // Terminou a track começa denovo
    if (playOnlyTrack.value) {
      if (currentTimestamp.value >= currentTrack!.startTime + currentTrack!.duration) {
        stop();
        setTimestamp(0, true);
        play();
      }
    }
    // else{
    //   if(currentTimestamp.value){//implementar sistema de tamanho de track normal
    //     stop();
    //     setTimestamp(0, false);
    //   }
    // }      
  }
  
  // Começa a tocar a musica
  void play() {
    stop();

    if (playOnlyTrack.value && currentTrack == null) { // VERIFICAÇÃO SE EXISTE ALGO PARA TOCAR
      return;
    }

    // Modo de track unica
    // Procura por todas as notas que serão tocadas a partir do momento atual
    if (playOnlyTrack.value && currentTrack != null) {
      // double timestamp = getTimestamp(true);

      // List<Note> notes = currentTrack!.getNotes();
      // int instrumentIndex = instruments.indexOf(currentTrack!.instrument);

      // for (int i = 0; i < notes.length; i++) {
      //   Note note = notes[i];

      //   if (timestamp <= note.startTime) {
      //     toPlay.add([note, instrumentIndex, note.startTime]);
      //   }
      // }

      Track track = currentTrack!;//[0];
      double trackStartTime = track.startTime;//[1]; // The start time for this track
      List<Note> notes = track.getNotes();
      int instrumentIndex = instruments.indexOf(track.instrument);

      // Collect all the notes from the track
      for (Note note in notes) {
        double adjustedStartTime = trackStartTime + note.startTime;
        
        // Only add the notes that are not yet past the current timestamp
        if (currentTimestamp.value <= adjustedStartTime) {
          toPlay.add([note, instrumentIndex, adjustedStartTime]);
        }
      }

      playingTheTrack = currentTrack;
    }
    
    // Modo de tocar o projeto inteiro (multiplas tracks simultaneamente)
    if (!playOnlyTrack.value) {
      // Iterate over each track in tracks_structure
      for (var trackEntry in tracks) {
        Track track = trackEntry;//[0];
        double trackStartTime = trackEntry.startTime;//[1]; // The start time for this track
        List<Note> notes = track.getNotes();
        int instrumentIndex = instruments.indexOf(track.instrument);

        // Collect all the notes from the track
        for (Note note in notes) {
          double adjustedStartTime = trackStartTime + note.startTime;
          
          // Only add the notes that are not yet past the current timestamp
          if (currentTimestamp.value <= adjustedStartTime) {
            toPlay.add([note, instrumentIndex, adjustedStartTime]);
          }
        }
      }

      // Sort the notes by their adjusted start time to ensure they are played in the correct order
      toPlay.sort((a, b) => a[2].compareTo(b[2])); // Compare by adjustedStartTime
    }

    // Começa o update do recorder
    _timer = Timer.periodic(Duration(milliseconds: 1), (timer) {
      update();
    });
  }


  // Para o recorder e limpa algumas listas
  void stop() {
    if (_timer != null && _timer!.isActive) {
      _timer?.cancel();
    }

    toPlay.clear();
    playingNotes.clear();
  }

  

}