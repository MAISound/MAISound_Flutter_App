import 'package:flutter/material.dart';
import 'package:maisound/classes/globals.dart';
import 'package:maisound/track_page.dart';

class ControlBarWidget extends StatefulWidget {
  const ControlBarWidget({super.key});

  @override
  State<ControlBarWidget> createState() => _ControlBarWidget();
}

class _ControlBarWidget extends State<ControlBarWidget> {
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
              ],
            ),

            // Volume slider
            SizedBox(
              width: 100, // Adjust width as per design
              child: Slider(
                activeColor: FlutterFlowTheme.of(context).primary,
                inactiveColor: FlutterFlowTheme.of(context).alternate,
                min: 0,
                max: 10,
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
                  icon: const Icon(Icons.fast_rewind,
                      color: Colors.white, size: 24),
                  onPressed: () {},
                ),
                FlutterFlowIconButton(
                  borderColor: const Color(0xFF242436),
                  borderRadius: 10,
                  borderWidth: 1,
                  buttonSize: 40,
                  fillColor: const Color(0xFF4B4B5B),
                  icon: playingCurrently
                      ? const Icon(Icons.pause_circle,
                          color: Colors.white, size: 24)
                      : const Icon(Icons.play_circle,
                          color: Colors.white, size: 24),
                  onPressed: () {
                    setState(() {
                      playingCurrently = !playingCurrently;
                    });
                  },
                ),
                FlutterFlowIconButton(
                  borderColor: const Color(0xFF242436),
                  borderRadius: 10,
                  borderWidth: 1,
                  buttonSize: 40,
                  fillColor: const Color(0xFF4B4B5B),
                  icon: const Icon(Icons.loop, color: Colors.white, size: 24),
                  onPressed: () {},
                ),

                // Time display
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      "00:00:00",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontFamily: "Courier",
                      ),
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