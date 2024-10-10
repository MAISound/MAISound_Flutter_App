import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutterflow_ui/flutterflow_ui.dart';
import 'package:maisound/cadastro_page.dart';
import 'package:maisound/classes/globals.dart';
import 'package:maisound/project_page.dart';
import 'package:maisound/track_page.dart';


class ControlBarWidget extends StatefulWidget {
  const ControlBarWidget({super.key});

  @override
  State<ControlBarWidget> createState() => _ControlBarWidget();
}

class _ControlBarWidget extends State<ControlBarWidget> {
  late TextEditingController _controller;


  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: '130');

    // Add a listener to the controller
    _controller.addListener(_onTextChanged);

      setState(() {
      });


  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }



  // Texto do bpm mudou
  void _onTextChanged() {
    String text = _controller.text;

    int? value = int.tryParse(text);
    if (value != null) {
      if (value < 1) {
        _controller.text = '1';
        _controller.selection = TextSelection.fromPosition(
          TextPosition(offset: _controller.text.length),
        );
      } else if (value > 999) {
        _controller.text = '999';
        _controller.selection = TextSelection.fromPosition(
          TextPosition(offset: _controller.text.length),
        );
      }

      BPM = value.toDouble();
    }
  }

  Icon getPlayIcon() {
    if (playingCurrently.value) {
      return const Icon(Icons.pause_circle, color: Colors.white, size: 24);
    } else {
      return const Icon(Icons.play_circle, color: Colors.white, size: 24);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional(0, 0),
      child: Container(
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
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Placeholder buttons on the left
            Row(
              // Menu
              children: [
                FlutterFlowIconButton(
                  borderColor: const Color(0xFF242436),
                  borderRadius: 10,
                  borderWidth: 1,
                  buttonSize: 40,
                  fillColor: const Color(0xFF4B4B5B),
                  icon: const Icon(Icons.menu, color: Colors.white, size: 24),
                  onPressed: () {},
                ),

                // Alternate between selected track and project page
                FlutterFlowIconButton(
                  borderColor: const Color(0xFF242436),
                  borderRadius: 10,
                  borderWidth: 1,
                  buttonSize: 40,
                  fillColor: const Color(0xFF4B4B5B),
                  icon: const Icon(Icons.piano, color: Colors.white, size: 24),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      PageRouteBuilder(
                          pageBuilder: (context, animation1, animation2) => ProjectPageWidget(),
                          transitionDuration: Duration.zero,
                          reverseTransitionDuration: Duration.zero,
                      ),
                    );
                  },
                ),

                // Play Track/Project
                FlutterFlowIconButton(
                  borderColor: const Color(0xFF242436),
                  borderRadius: 10,
                  borderWidth: 1,
                  buttonSize: 40,
                  fillColor: recorder.playOnlyTrack.value ? Color.fromARGB(255, 255, 125, 38) : const Color(0xFF4B4B5B),
                  icon: Icon(recorder.playOnlyTrack.value ? Icons.headphones : Icons.headphones, color: Colors.white, size: 24),
                  onPressed: () {
                    setState(() {
                      recorder.playOnlyTrack.value = !recorder.playOnlyTrack.value;

                      // Deixa o marcador na posição 0 relativa a track caso a posição atual seja incompativel com a track
                      
                      if (currentTrack != null) {
                        double timestamp = recorder.getTimestamp(true);
                        if (timestamp < 0 || timestamp > currentTrack!.duration) {
                          recorder.setTimestamp(0, true);
                        }
                      }

                    });
                  },
                ),
              ],
            ),

            // Volume slider
            SizedBox(
              width: 100, // Adjust width as per design
              child: Slider(
                activeColor: Colors.black,
                inactiveColor: Colors.white30,
                min: 0,
                max: 1,
                value: master_volume,
                onChanged: (newValue) {
                  setState(() {
                    master_volume = newValue;
                  });
                },
              ),
            ),

            // Rewind, Play/Pause, Loop buttons and time indicator
            Row(
              children: [
                // Botão de voltar
                FlutterFlowIconButton(
                  borderColor: const Color(0xFF242436),
                  borderRadius: 10,
                  borderWidth: 1,
                  buttonSize: 40,
                  fillColor: const Color(0xFF4B4B5B),
                  icon: const Icon(Icons.fast_rewind,
                      color: Colors.white, size: 24),
                  onPressed: () {
                    if (recorder.playOnlyTrack.value || inTrack) {
                      recorder.setTimestamp(0.0, true);
                    } else {
                      recorder.setTimestamp(0.0, false);
                      setState(() {
                        playingCurrently.value = false;//SEMPRE QUE APERTAR BOTÃO DE REWIND, PAUSAR NO INICIO(isso se estiver fora da track)
                        recorder.stop();
                    });
                    }
                    
                  },
                ),

                // Botão de pausar
                FlutterFlowIconButton(
                  borderColor: const Color(0xFF242436),
                  borderRadius: 10,
                  borderWidth: 1,
                  buttonSize: 40,
                  fillColor: const Color(0xFF4B4B5B),
                  icon: getPlayIcon(),
                  onPressed: () {
                    setState(() {
                      playingCurrently.value = !playingCurrently.value;
                    });
                  },
                ),

                // Botão de loop
                FlutterFlowIconButton(
                  borderColor: const Color(0xFF242436),
                  borderRadius: 10,
                  borderWidth: 1,
                  buttonSize: 40,
                  fillColor: const Color(0xFF4B4B5B),
                  icon: recordingCurrently.value
                      ? const Icon(Icons.square, color: Colors.white, size: 24)
                      : const Icon(Icons.circle,
                          color: Colors.white, size: 24),
                  onPressed: () {
                    setState(() {
                      recordingCurrently.value = !recordingCurrently.value;
                    });

                  },
                ),
                // BPM TEXT
                Padding(
                  padding: const EdgeInsets.only(left: 12.0),
                  child: DefaultTextStyle(
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontFamily: "Courier",
                      ),
                      child: Text('BPM')),
                ),
                
                // BPM
                // Tempo
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Container(
                    height: 40,
                    width: 60,
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextField(
                      decoration: const InputDecoration(
                        border: InputBorder.none, // Remove the underline
                      ),
                      textAlign: TextAlign.center,
                      textAlignVertical: TextAlignVertical.center,
                      controller: _controller,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontFamily: "Courier",
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  
}
