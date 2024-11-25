import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutterflow_ui/flutterflow_ui.dart';
import 'package:maisound/cadastro_page.dart';
import 'package:maisound/classes/globals.dart';
import 'package:maisound/home_page.dart';
import 'package:maisound/project_page.dart';
import 'package:maisound/services/project_service.dart';
import 'package:maisound/track_page.dart';
import 'package:maisound/ui/chat_page.dart';
import 'package:numberpicker/numberpicker.dart';


class ControlBarWidget extends StatefulWidget {
  const ControlBarWidget({super.key});

  @override
  State<ControlBarWidget> createState() => _ControlBarWidget();
}

class _ControlBarWidget extends State<ControlBarWidget> {
  OverlayEntry? _chatOverlayEntry; // Mantém a referência do OverlayEntry
  bool _isChatOpen = false; // Estado para controlar se o chat está aberto
  ProjectService _projectService = ProjectService();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
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
        width: MediaQuery.of(context).size.width * 0.3, // Defina a largura desejada
        height: MediaQuery.of(context).size.height, // Defina a altura como a tela inteira
        child: Material(
          color: Colors.transparent,
          child: ChatPage(),
        ),
      ),
    );
  }

  

  void _toggleChat() {
    setState(() {
      if (_isChatOpen) {
        _chatOverlayEntry?.remove(); 
        _chatOverlayEntry = null;
      } else {
        _chatOverlayEntry = _createChatOverlay();
        Overlay.of(context).insert(_chatOverlayEntry!);
      }
      _isChatOpen = !_isChatOpen; 
    });
  }
  void _showBpmPicker() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        int tempBpm = BPM.toInt(); // Armazena o BPM temporariamente
        return StatefulBuilder( // Permite que o diálogo atualize seu próprio estado
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1D1D25), // Combina com o tema
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text(
                "Ajustar BPM",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Escolha o valor do BPM",
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 20),
                  NumberPicker(
                    minValue: 50,
                    maxValue: 300,
                    value: tempBpm,
                    step: 1,
                    haptics: true,
                    textStyle: const TextStyle(color: Colors.white38, fontSize: 16),
                    selectedTextStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(color: Colors.white24, width: 1),
                        bottom: BorderSide(color: Colors.white24, width: 1),
                      ),
                    ),
                    onChanged: (newValue) {
                      setState(() {
                        tempBpm = newValue; // Atualiza o BPM temporário no diálogo
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Fecha o diálogo sem salvar
                  },
                  child: const Text(
                    "Cancelar",
                    style: TextStyle(color: Colors.redAccent, fontSize: 16),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      BPM = tempBpm.toDouble(); // Atualiza o BPM globalmente
                    });
                    Navigator.of(context).pop(); // Fecha o diálogo após salvar
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("BPM ajustado para $tempBpm"),
                        backgroundColor: Colors.green,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  child: const Text(
                    "Salvar",
                    style: TextStyle(color: Colors.greenAccent, fontSize: 16),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }



  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional(0, 0),
      child: Container(
        height: 70,
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
                  onPressed: () async {
                    Navigator.pushReplacement(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation1, animation2) =>
                            HomePage(),
                        transitionDuration: Duration.zero,
                        reverseTransitionDuration: Duration.zero,
                      ),
                    );
                  },
                ),
                // Salvar
                FlutterFlowIconButton(
                  borderColor: const Color(0xFF242436),
                  borderRadius: 10,
                  borderWidth: 1,
                  buttonSize: 40,
                  fillColor: const Color(0xFF4B4B5B),
                  icon: const Icon(Icons.save, color: Colors.white, size: 24),
                  onPressed: () async {
                    try {
                      await _projectService.save(current_projectId);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Projeto salvo com sucesso!'),
                          backgroundColor: Colors.green,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Erro ao salvar o projeto.'),
                          backgroundColor: Colors.red,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                ),
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
            Padding(padding: EdgeInsets.only(right: 30)),

            // Volume slider
            SizedBox(
              width: 200, 
              child: Row(
                children: [
                  Icon(
                    master_volume > 0.50? Icons.volume_up : master_volume == 0? Icons.volume_off : Icons.volume_down,
                    color: Colors.white,
                    size: 24,
                  ),
                  Expanded( 
                    child: Slider(
                      activeColor: const Color(0xFF4B4B5B),
                      inactiveColor: const Color(0xFF4B4B5B),
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
                ],
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
                    //se apertar rewind enquanto grava
                  },
                ),

                FlutterFlowIconButton(
                  borderColor: const Color(0xFF242436),
                  borderRadius: 10,
                  borderWidth: 1,
                  buttonSize: 40,
                  fillColor: recordingCurrently.value ? const Color(0xFF888888) : const Color(0xFF4B4B5B),
                  icon: getPlayIcon(),
                  onPressed:recordingCurrently.value? null : () {
                    
                    setState(() {
                      playingCurrently.value = !playingCurrently.value;
                    });

                  },
                ),
              ],
            ),

            if(inTrack)
              FlutterFlowIconButton(
              borderColor: const Color(0xFF242436),
              borderRadius: 10,
              borderWidth: 1,
              buttonSize: 40,
              fillColor: const Color(0xFF4B4B5B),
              icon: recordingCurrently.value
                  ? const Icon(Icons.square, color: Colors.white, size: 20)
                  : const Icon(Icons.fiber_manual_record, color: Colors.white, size: 24),
              onPressed: () {
                print(recordingCurrently.value);
                setState(() {
                  recordingCurrently.value = !recordingCurrently.value;
                  print(recordingCurrently.value);
                  if(recordingCurrently.value){
                    recorder.startRecording();
                    print("Entraria no método");

                  }
                });
              },
            ),
            
            
            Padding(padding: EdgeInsets.only(right: 30)),

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
            FlutterFlowIconButton(
              borderColor: const Color(0xFF242436),
              borderRadius: 10,
              borderWidth: 1,
              buttonSize: 40,
              fillColor: const Color(0xFF4B4B5B),
              icon: const Icon(Icons.speed, color: Colors.white, size: 24),
              onPressed: _showBpmPicker, // Chama o seletor de BPM
            ),
            
          ],
        ),
      ),
    );
  }
}
