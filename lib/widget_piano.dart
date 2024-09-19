import 'package:flutter/material.dart';
import 'package:maisound/classes/instrument.dart';
import 'package:maisound/track_page.dart';

class PianoWidget extends StatelessWidget {
  final List octaves;

  PianoWidget({Key? key, required this.octaves}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var keys = ["C", "D", "E", "F", "G", "A", "B"].reversed.toList();

    return Scaffold(
        body: Column(
      children: [
        for (var octave in octaves)
          for (var key in keys)
            PianoButton(noteName: key, currentOctave: octave)
      ],
    ));
  }
}

final instrument = Instrument();

class PianoButton extends StatelessWidget {
  final String noteName;
  final int currentOctave;

  PianoButton({Key? key, required this.noteName, required this.currentOctave})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    const keys = ["C", "D", "E", "F", "G", "A", "B"];
    const keysWithBlack = ["C", "D", "F", "G", "A"];

    var isBlack = false;
    for (var key in keysWithBlack) {
      if (noteName.contains(key)) {
        isBlack = true;
      }
    }

    ButtonStyle style;

    if (isBlack) {
      style = ElevatedButton.styleFrom(
        primary: Colors.white60,
        side: BorderSide.none,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
      );

      return Expanded(
        child: (Stack(
          clipBehavior: Clip.none,
          children: [
            Padding(
              padding: const EdgeInsets.all(0.0),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(),
                ),
                height: double.infinity,
                width: double.infinity,
                child: ElevatedButton(
                  style: style,
                  onPressed: () {
                    instrument.playSound(noteName + currentOctave.toString());
                    print(noteName + currentOctave.toString());
                    recordingController
                        .recordNote(noteName + currentOctave.toString());
                  },
                  child: null,
                ),
              ),
            ),
            Positioned(
              top: -25.0,
              child: Container(
                height: 40.0,
                width: 190.0,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Colors.black,
                    side: BorderSide.none,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        bottomRight: Radius.circular(10.0),
                        topRight: Radius.circular(10.0),
                      ),
                    ),
                  ),
                  onPressed: () {
                    instrument
                        .playSound(noteName + "#" + currentOctave.toString());
                    print(noteName + "#" + currentOctave.toString());
                    recordingController
                        .recordNote(noteName + "#" + currentOctave.toString());
                  },
                  child: null,
                ),
              ),
            ),
          ],
        )),
      );
    } else {
      style = ElevatedButton.styleFrom(
        primary: Colors.white60,
        side: BorderSide.none,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
      );

      return Expanded(
        flex: 1,
        child: Padding(
          padding: const EdgeInsets.all(0.0),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(),
            ),
            height: double.infinity,
            width: double.infinity,
            child: ElevatedButton(
              style: style,
              onPressed: () {
                instrument.playSound(noteName + currentOctave.toString());
                print(noteName + currentOctave.toString());
                recordingController
                    .recordNote(noteName + currentOctave.toString());
              },
              child: null,
            ),
          ),
        ),
      );
    }
  }
}
