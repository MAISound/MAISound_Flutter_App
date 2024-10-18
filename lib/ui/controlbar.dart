import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutterflow_ui/flutterflow_ui.dart';
import 'package:maisound/cadastro_page.dart';
import 'package:maisound/classes/globals.dart';
import 'package:maisound/project_page.dart';
import 'package:maisound/track_page.dart';
import 'package:maisound/ui/chat_page.dart';


class ControlBarWidget extends StatefulWidget {
  const ControlBarWidget({super.key});

  @override
  State<ControlBarWidget> createState() => _ControlBarWidget();
}

class _ControlBarWidget extends State<ControlBarWidget> {
  late TextEditingController _controller;
  OverlayEntry? _chatOverlayEntry; // Mantém a referência do OverlayEntry
  bool _isChatOpen = false; // Estado para controlar se o chat está aberto

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: '130');
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

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

  // Cria o OverlayEntry para a tela de chat
  OverlayEntry _createChatOverlay() {
  return OverlayEntry(
    builder: (context) => Positioned(
      right: 0,
      top: 0,
      width: MediaQuery.of(context).size.width * 0.7, // Defina a largura desejada
      height: MediaQuery.of(context).size.height, // Defina a altura como a tela inteira
      child: Material(
        color: Colors.transparent,
        child: ChatPage(), // A sua ChatPage aqui
      ),
    ),
  );
}

  

  void _toggleChat() {
    setState(() {
      if (_isChatOpen) {
        _chatOverlayEntry?.remove(); // Fecha a janela de chat
        _chatOverlayEntry = null;
      } else {
        _chatOverlayEntry = _createChatOverlay();
        Overlay.of(context).insert(_chatOverlayEntry!); // Abre a janela de chat
      }
      _isChatOpen = !_isChatOpen; // Alterna o estado do chat
    });
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
                        pageBuilder: (context, animation1, animation2) =>
                            ProjectPageWidget(),
                        transitionDuration: Duration.zero,
                        reverseTransitionDuration: Duration.zero,
                      ),
                    );
                  },
                ),
              ],
            ),

            // Volume slider
            SizedBox(
              width: 100, // Ajustar a largura do slider
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
                FlutterFlowIconButton(
                  borderColor: const Color(0xFF242436),
                  borderRadius: 10,
                  borderWidth: 1,
                  buttonSize: 40,
                  fillColor: const Color(0xFF4B4B5B),
                  icon: const Icon(Icons.fast_rewind, color: Colors.white, size: 24),
                  onPressed: () {
                    if (recorder.playOnlyTrack.value || inTrack) {
                      recorder.setTimestamp(0.0, true);
                    } else {
                      recorder.setTimestamp(0.0, false);
                      setState(() {
                        playingCurrently.value = false;
                        recorder.stop();
                      });
                    }
                  },
                ),

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
              ],
            ),

            // Botão de IA que abre o chat no topo de toda a tela
            FlutterFlowIconButton(
              borderColor: const Color(0xFF242436),
              borderRadius: 10,
              borderWidth: 1,
              buttonSize: 40,
              fillColor: const Color(0xFF4B4B5B),
              icon: const Icon(Icons.memory, color: Colors.white, size: 24),
              onPressed: _toggleChat, // Abre ou fecha o chat
            ),
          ],
        ),
      ),
    );
  }
}
