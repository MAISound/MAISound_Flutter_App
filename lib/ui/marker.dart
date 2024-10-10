import 'dart:async';

import 'package:flutter/material.dart';
import 'package:maisound/classes/globals.dart';

// Retorna a linha que estende do marcador
Widget getLine(_markerPosition, screenHeight, xoffset) {
  // Thin line extending from marker to the bottom of the screen
  return Positioned(
    left: _markerPosition -
        0.5 +
        xoffset, // Align the line with the marker's position
    top: 15, // Start just below the marker
    child: Container(
      width: 1, // Thin line
      height: screenHeight - 30, // Extend to the bottom of the screen
      color: Colors.green, // Line color (same as the marker)
    ),
  );
}

class TimestampMarker extends StatefulWidget {
  final Function(double) onPositionChanged; // Callback for position changes
  bool trackMarker;

  TimestampMarker({required this.onPositionChanged, required this.trackMarker}); // callback

  @override
  _TimestampMarkerState createState() => _TimestampMarkerState();
}

class _TimestampMarkerState extends State<TimestampMarker> {
  // Posição do marcador
  double _markerPosition = 0.0;

  Timer? _timer;

  void _onTap(BuildContext context, TapDownDetails details) {
    //if (!widget.trackMarker && recorder.playOnlyTrack.value) return;

    // Pega posição X relativa ao container
    final RenderBox box = context.findRenderObject() as RenderBox;
    final localPosition = box.globalToLocal(details.globalPosition);

    recorder.setTimestamp(localPosition.dx, widget.trackMarker);
    setState(() {
      _markerPosition = recorder.getTimestamp(widget.trackMarker);

      // Notifica a classe pai da mudança
      widget.onPositionChanged(_markerPosition);
    });
  }

  @override
  void initState() {
    _markerPosition = recorder.getTimestamp(widget.trackMarker);

    recorder.currentTimestamp.addListener(() {
      _markerPosition = recorder.getTimestamp(widget.trackMarker);
    });

    // if (widget.trackMarker) {
    //   recorder.currentTimestamp.addListener(() {
    //     _markerPosition = recorder.getTimestamp(true);//recorder.currentTimestamp.value;
    //   });
    // } else {
    //   recorder.currentProjectTimestamp.addListener(() {
    //     if (!widget.trackMarker && recorder.playOnlyTrack.value) return;

    //     _markerPosition = recorder.currentProjectTimestamp.value;
    //   });
    // }

    _timer = Timer.periodic(Duration(milliseconds: 1), (_) {
      setState(() {
        _markerPosition = recorder.getTimestamp(widget.trackMarker);
      });
    });

    super.initState();
  }
  
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return (!widget.trackMarker && recorder.playOnlyTrack.value) ?
      Container(
        height: 15,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color.fromARGB(255, 92, 92, 92).withOpacity(0.4), // Mais escuro ao topo
              const Color.fromARGB(255, 155, 155, 155).withOpacity(0.1), // Mais claro embaixo
            ],
          ),
        ),)
    : GestureDetector(
      onTapDown: (details) => _onTap(context, details),
      child: Container(
        height: 15,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacity(0.4), // Mais escuro ao topo
              Colors.black.withOpacity(0.1), // Mais claro embaixo
            ],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              left: _markerPosition - 10, // Offset na seta
              top: 0,
              child: Icon(
                Icons.arrow_drop_down,
                size: 20, // Tamanho da seta
                color: Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
