import 'package:flutter/material.dart';
import 'package:maisound/classes/globals.dart';
import 'package:maisound/classes/instrument.dart';
import 'package:maisound/classes/track.dart';
import 'package:maisound/ui/controlbar.dart';
import 'package:maisound/ui/piano_row.dart';
import 'package:universal_html/html.dart' as html;

// Mostra uma track visualmente (Classe Track)
class TrackPageWidget extends StatefulWidget {
  Track track;
  TrackPageWidget({super.key, required this.track}); //, required Track track});

  @override
  _TrackPageWidgetState createState() => _TrackPageWidgetState();
}

class _TrackPageWidgetState extends State<TrackPageWidget> {
  // Debug
  late Track track = widget.track;//Track(inst);
  late Instrument inst = track.instrument;

  // Desabilita clique com botão direito de abrir a janela padrão 
  @override
  void initState() {
    currentTrack = widget.track;
    
    // Só é possivel deste if acontecer se voce abrir diretamente esta pagina
    inTrack = true;
    super.initState();

    //recorder.setTrack(track);
    // Prevent default event handler
    html.document.onContextMenu.listen((event) {
      event.preventDefault(); // Impede o menu de contexto de ser exibido
    });
  }

  @override
  void dispose() {

    inTrack = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF303047),
      body: Column(
        children: [
          // Barra de controle no topo
          ControlBarWidget(),

          // Piano Row expanded to take full horizontal space
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: PianoRowWidget(track: track),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
