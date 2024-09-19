import 'package:flutter/material.dart';
import 'package:maisound/classes/instrument.dart';
import 'package:maisound/classes/track.dart';
import 'package:maisound/ui/controlbar.dart';
import 'package:maisound/ui/piano_row.dart';



// Mostra uma track visualmente (Classe Track)
class TrackPageWidget extends StatefulWidget {
  const TrackPageWidget({super.key});//, required Track track});

  @override
  _TrackPageWidgetState createState() => _TrackPageWidgetState();
}

class _TrackPageWidgetState extends State<TrackPageWidget> {

  // Debug
  late Instrument inst = Instrument();
  late Track track = Track(inst);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF303047),
      body: Column(
        children: [
          // Barra de controle no topo
          ControlBarWidget(),
          
          // Piano Row without unnecessary Container
          Expanded(
            child: PianoRowWidget(track: track),
          ),
        ],
      ),
    );
  }


}