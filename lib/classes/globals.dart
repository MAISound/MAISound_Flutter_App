library MAISound.globals;

import 'package:maisound/classes/instrument.dart';
import 'package:maisound/classes/recorder.dart';

// User
String username = "user";

// Config
String project_name  = "Generic";
double master_volume = 1;
double BPM           = 130; // Influencia o quão rapido o valor de timestamp aumenta
double timestamp     = 0.00; // Timestamp da musica em geral (Não é de uma track individual)
bool playingCurrently = false;

// Lista de instrumentos do projeto
List instruments = [
  Instrument()
];

// Estruturação das tracks do projeto
List main_tracks = [];

// Global recorder
final Recorder recorder = Recorder();
