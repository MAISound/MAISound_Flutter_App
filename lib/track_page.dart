import 'package:flutter/material.dart';
import 'package:maisound/classes/instrument.dart';
import 'package:flutterflow_ui/flutterflow_ui.dart';
import 'package:maisound/project_page.dart';
import 'dart:async';
import 'package:maisound/widget_piano.dart';
export 'package:flutterflow_ui/flutterflow_ui.dart';

// Carrega o instrumento
final Instrument instrument = Instrument();

bool isPlaying = false;


class RecordingController {
  List<Note> recordedNotes = [];
  bool isRecording = false;
  late double recordingStartTime;
  Timer? _recordingTimer;
  bool isPlaying = false;

  // Variable to control the playback position
  double playbackPosition = 0.0; 
  Timer? _playbackTimer;

  void recordNote(String noteName) {
    if (isRecording) {
      double currentTime = DateTime.now().millisecondsSinceEpoch / 1000;
      double noteTime = currentTime - recordingStartTime;
      if (noteTime <= 15.0) { 
        recordedNotes.add(Note(
          noteName: noteName,
          startTime: noteTime,
          duration: 1,
        ));
      }
      print(isRecording);
      print(recordedNotes.length);
    }
    notifyListeners();
  }

  void startRecording() {
    recordedNotes.clear();
    isRecording = true;
    recordingStartTime = DateTime.now().millisecondsSinceEpoch / 1000;

    // Start the timer to check the recording time
    _recordingTimer = Timer.periodic(Duration(milliseconds: 100), (timer) {
      double currentTime = DateTime.now().millisecondsSinceEpoch / 1000;
      double recordingTime = currentTime - recordingStartTime;
      if (recordingTime >= 15.0) {
        stopRecording();
        timer.cancel(); // Stop the timer
      }
    });
  }

  void stopRecording() {
    isRecording = false;
    _recordingTimer?.cancel(); // Stop the timer
  }

  void playRecording(Function onPlaybackComplete) {
    isPlaying = true;

    if (recordedNotes.isEmpty) {
      return;
    }

    // Sort notes by startTime
    recordedNotes.sort((a, b) => a.startTime.compareTo(b.startTime));

    double startTime = recordedNotes.first.startTime;
    
    _playbackTimer = Timer.periodic(Duration(milliseconds: 100), (timer) {
        playbackPosition += 0.1;
        notifyListeners(); // Notify listeners that playbackPosition has changed
        if (playbackPosition >= 15.0) {
          stopPlayback(); // Stop playback when it reaches the end
        }
      });

    // Delay to align the playback with the first note's start time
    double initialDelay = startTime * 1000;
    Timer(Duration(milliseconds: initialDelay.round()), () {
      // Start the timer to update the playback position
      

      for (Note note in recordedNotes) {
        double delay = (note.startTime - startTime) * 1000; // Convert to milliseconds
        print("delay = " + delay.toString() + " da nota: " + note.noteName);

        Timer(Duration(milliseconds: delay.round()), () {
          print(note.noteName);
          instrument.playSound(note.noteName);
        });
      }

      // Schedule the state change for when the last note finishes
      double totalDuration = (recordedNotes.last.startTime - startTime) * 1000;
      Timer(Duration(milliseconds: totalDuration.round()), () {
        onPlaybackComplete();
        stopPlayback();
      });
    });

    notifyListeners();  
  }

  void stopPlayback() {
    isPlaying = false;
    _playbackTimer?.cancel();
    playbackPosition = 0.0; // Reset playback position
  }

  final List<Function> _listeners = [];

  void addListener(Function listener) {
    _listeners.add(listener);
  }

  void removeListener(Function listener) {
    _listeners.remove(listener);
  }

  void notifyListeners() {
    for (var listener in _listeners) {
      listener();
    }
  }
}



final RecordingController recordingController = RecordingController();



class TrackWidget extends StatefulWidget {
  final Color color = const Color.fromARGB(57, 68, 70, 94);
  final double space;

  const TrackWidget({super.key, required this.space});

  @override
  _TrackWidgetState createState() => _TrackWidgetState();
}

class _TrackWidgetState extends State<TrackWidget> {
  List<Note> recordedNotes = recordingController.recordedNotes;
  double playbackPosition = recordingController.playbackPosition; // Estado para a posição de reprodução
  @override
  void initState() {
    super.initState();
    recordingController.addListener(_updateState);
  }

  @override
  void dispose() {
    recordingController.removeListener(_updateState);
    super.dispose();
  }

  void _updateState() {
    setState(() {});
  }

   void updatePlaybackPosition() {
    if (recordingController.isPlaying) {
      playbackPosition = recordingController.playbackPosition;
    }
  }

  // Mapear as notas para posições verticais
  final Map<String, double> notePositions = {
    'C3': 0.0,
    'C#3': 1.0,
    'D3': 2.0,
    'D#3': 3.0,
    'E3': 4.0,
    'F3': 5.0,
    'F#3': 6.0,
    'G3': 7.0,
    'G#3': 8.0,
    'A3': 9.0,
    'A#3': 10.0,
    'B3': 11.0,
    'C4': 12.0,
    'C#4': 13.0,
    'D4': 14.0,
    'D#4': 15.0,
    'E4': 16.0,
    'F4': 17.0,
    'F#4': 18.0,
    'G4': 19.0,
    'G#4': 20.0,
    'A4': 21.0,
    'A#4': 22.0,
    'B4': 23.0,
  };

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        double width = constraints.maxWidth;
        double height = constraints.maxHeight;

        // Verificar se o espaço é menor que o espaço entre as notas
        double adjustedSpace = widget.space;
        if (width < widget.space) adjustedSpace = width;
        if (height < widget.space) adjustedSpace = height;

        var h = Container(width: 2, height: height, color: widget.color);
        var v = Container(width: width, height: 2, color: widget.color);

        // Iniciar o timer para atualizar a posição de reprodução quando a reprodução começar
        if (recordingController.isPlaying) {
          updatePlaybackPosition();
        }

        return Stack(
          children: <Widget>[
            // Linhas horizontais
            ...List.generate(
              notePositions.length,
              (index) => Positioned(
                top: index * (adjustedSpace / 2),
                child: v,
              ),
            ),
            // Notas gravadas
            ...recordingController.recordedNotes.map((note) {
              double topPosition = notePositions[note.noteName]! * adjustedSpace / 2;
              double leftPosition = note.startTime * (width / 15.0); // Calcular a posição horizontal

              return Positioned(
                top: topPosition,
                left: leftPosition, // Posicionar as notas de acordo com o tempo
                child: Container(
                  width: 10,
                  height: 40,
                  color: Colors.red,
                ),
              );
            }).toList(),
            // Barra de reprodução (amarela)
            Positioned(
              top: 0,
              left: playbackPosition * (width / 15.0), // Usar a posição de reprodução do estado
              child: Container(
                width: 2,
                height: height,
                color: Colors.yellow,
              ),
            ),
          ],
        );
      },
    );
  }
}



// Barra de cima, com botão de play e tudo mais
class ControlBar extends StatelessWidget {
  const ControlBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar();
  }
}

// Pagina do piano
class TrackPage extends StatefulWidget {
  const TrackPage({super.key});

  @override
  State<TrackPage> createState() => _TrackPage();
}

class _TrackPage extends State<TrackPage> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "New Project(1)",
      theme: ThemeData(
        scaffoldBackgroundColor: Color.fromARGB(255, 48, 48, 71),
      ),
      home: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: MusicPlayerHeader(
            instrument: instrument,
          ),
        ),
        body: Row(
          children: [
            SizedBox(
              width: 300,
              child: PianoWidget(octaves: [2,3].reversed.toList(),),
            ),
            Expanded(
              child: TrackWidget(
                space: 80, // Define o espaço das linhas horizontais para a altura das teclas
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MusicPlayerHeader extends StatefulWidget {
  final Instrument instrument;

  const MusicPlayerHeader({Key? key, required this.instrument}) : super(key: key);

  @override
  State<MusicPlayerHeader> createState() => _MusicPlayerHeaderState();
}

class _MusicPlayerHeaderState extends State<MusicPlayerHeader> {
  bool isRecording = false;
  bool isPlaying = false;

 @override
  void initState() {
    super.initState();
  }





  void toggleRecording() {
    setState(() {
      isRecording = !isRecording;
      if (isRecording) {
        recordingController.startRecording();
      } else {
        recordingController.stopRecording();
      }
    });
  }

  void handlePlaybackComplete() {
    setState(() {
      isPlaying = false;
    });
  }

  void togglePlayback() {
    setState(() {
      isPlaying = !isPlaying;
      if (isPlaying) {
        recordingController.playRecording(handlePlaybackComplete);

      } else {
        recordingController.stopRecording();// Parar a reprodução
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 100,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1D1D25), Color(0xFF0E0E15)],
          stops: [0, 1],
          begin: AlignmentDirectional(0, -1),
          end: AlignmentDirectional(0, 1),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FlutterFlowIconButton(
            borderColor: const Color(0xFF242436),
            borderRadius: 10,
            borderWidth: 1,
            buttonSize: 40,
            fillColor: const Color(0xFF4B4B5B),
            icon: const Icon(
              Icons.menu,
              color: Colors.white,
              size: 24,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProjectPageWidget(projectName: "New Project"),
                ),
              );
            },
          ),
          const SizedBox(width: 16),
          FlutterFlowIconButton(
            borderColor: const Color(0xFF242436),
            borderRadius: 10,
            borderWidth: 1,
            buttonSize: 40,
            fillColor: const Color(0xFF4B4B5B),
            icon: const Icon(
              Icons.fast_rewind,
              color: Colors.white,
              size: 24,
            ),
            onPressed: () {
              recordingController.isPlaying = false;
              setState(() {
                recordingController.playbackPosition = 0.0;
                isPlaying = false;
              });

            },
          ),
          const SizedBox(width: 16),
          FlutterFlowIconButton(
            borderColor: const Color(0xFF242436),
            borderRadius: 10,
            borderWidth: 1,
            buttonSize: 40,
            fillColor: const Color(0xFF4B4B5B),
            icon: Icon(
              isPlaying ? Icons.pause : Icons.play_arrow,
              color: Colors.white,
              size: 24,
            ),
            onPressed: togglePlayback,
          ),
          const SizedBox(width: 16),
          FlutterFlowIconButton(
            borderColor: const Color(0xFF242436),
            borderRadius: 10,
            borderWidth: 1,
            buttonSize: 40,
            fillColor: const Color(0xFF4B4B5B),
            icon: const Icon(
              Icons.loop,
              color: Colors.white,
              size: 24,
            ),
            onPressed: () {
              recordingController.recordedNotes.clear();
            },
          ),
          const SizedBox(width: 16),
          FlutterFlowIconButton(
            borderColor: const Color(0xFF242436),
            borderRadius: 10,
            borderWidth: 1,
            buttonSize: 40,
            fillColor: const Color(0xFF4B4B5B),
            icon: Icon(
              isRecording ? Icons.stop : Icons.mic,
              color: Colors.white,
              size: 24,
            ),
            onPressed: () {
              toggleRecording();
              print('Recording toggled: $isRecording');
            },
          ),
        ],
      ),
    );
  }
}