import 'package:maisound/classes/instrument.dart';

class Track {
  // Instrumento associado a esta track
  late Instrument instrument;
  
  // Notas associada a esta track
  // Formato [[Name, Start, Duration] ...]
  late List<Note> notes;

  Track(Instrument inst) {
    instrument = inst;
    notes = List.empty();
  }
}