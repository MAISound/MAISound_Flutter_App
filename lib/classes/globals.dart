library MAISound.globals;

import 'package:flutter/material.dart';
import 'package:maisound/classes/instrument.dart';
import 'package:maisound/classes/recorder.dart';
import 'package:maisound/classes/track.dart';

// User
String username = "user";

// Config
String project_name = "Generic";
double master_volume = 0.75;
double BPM = 130; // Influencia o quão rapido o valor de timestamp aumenta
double timestamp =
    0.00; // Timestamp da musica em geral (Não é de uma track individual)
ValueNotifier<bool> playingCurrently = ValueNotifier<bool>(false);
Track? playingTrack;

// Lista de instrumentos do projeto
List<Instrument> instruments = [Instrument()];

// Estruturação das tracks do projeto
List<Track> tracks = [];

// Estruturação da pagina principal e o tempo de cada track
// [Track (Referencia a uma das track na lista tracks), Tempo de inicio]
List tracks_structure = [];

// Global recorder
final Recorder recorder = Recorder();
