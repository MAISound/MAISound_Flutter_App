import 'dart:math';
import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';
import 'package:maisound/classes/globals.dart';
import 'package:maisound/classes/instrument.dart';
import 'package:maisound/classes/track.dart';
import 'package:maisound/ui/marker.dart';

class NoteWidget extends StatefulWidget {
  final String note;
  final bool isBlack;
  final double width;
  final double height;
  final VoidCallback onPressed;
  final VoidCallback onReleased;

  const NoteWidget({
    required this.note,
    required this.isBlack,
    this.width = 250,
    this.height = 60,
    required this.onPressed,
    required this.onReleased,
  });

  @override
  _NoteWidgetState createState() => _NoteWidgetState();
}

class _NoteWidgetState extends State<NoteWidget> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() {
          _isPressed = true;
        });
        widget.onPressed();
      },
      onTapUp: (_) {
        setState(() {
          _isPressed = false;
        });
        widget.onReleased();
      },
      onTapCancel: () {
        setState(() {
          _isPressed = false;
        });
        widget.onReleased();
      },
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: _isPressed
              ? (widget.isBlack
                  ? Color.fromARGB(255, 29, 29, 29)
                  : Colors.white70)
              : (widget.isBlack ? Colors.black : Colors.white),
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Center(
          child: Text(
            widget.note,
            style: TextStyle(
              color: widget.isBlack ? Colors.white : Colors.black,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}

class PianoRowWidget extends StatefulWidget {
  final Track track;
  const PianoRowWidget({super.key, required this.track});

  @override
  _PianoRowWidgetState createState() => _PianoRowWidgetState();
}

class _PianoRowWidgetState extends State<PianoRowWidget> {
  double _markerPosition = 0.0;
  final double _snapStep = 32;
  double? _initialMouseOffsetX;
  double? _initialNoteDuration;
  double _lastNoteDuration = 64;

  late final ScrollController _horizontalScrollController;

  late final ScrollController _verticalScrollController;
  late final ScrollController _verticalScroll2Controller;


  final List<Map<String, bool>> _notes = [
    {'C4': false}, {'C#4': true}, {'D4': false}, {'D#4': true}, {'E4': false},
    {'F4': false}, {'F#4': true}, {'G4': false}, {'G#4': true}, {'A4': false},
    {'A#4': true}, {'B4': false}, {'C5': false}, {'C#5': true}, {'D5': false},
    {'D#5': true}, {'E5': false}, {'F5': false}, {'F#5': true}, {'G5': false},
    {'G#5': true}, {'A5': false}, {'A#5': true}, {'B5': false},
  ];


  @override
  void initState() {
    super.initState();
    _horizontalScrollController = ScrollController();
    // _verticalScrollController = ScrollController();

    final group = LinkedScrollControllerGroup();
    // Assign controllers to the group
    _verticalScrollController = group.addAndGet();
    _verticalScroll2Controller = group.addAndGet();

    _verticalScrollController.addListener(() {
      setState(() {}); // Rebuild on vertical scroll
    });

    _horizontalScrollController.addListener(() {
      XScrollOffset.value = _horizontalScrollController.offset;
      setState(() {}); // Rebuild on horizontal scroll
      _updateMarkerPosition();
    });


    recorder.currentTimestamp.addListener(_updateMarkerPosition);
    _updateMarkerPosition(); // Initial update
  }

  void _updateMarkerPosition() {
    if (mounted) {
      setState(() {
        _markerPosition = recorder.getTimestamp(true) - XScrollOffset.value;
      });
    }
  }



  @override
  void dispose() {
    _horizontalScrollController.dispose();
    _verticalScrollController.dispose();
    _verticalScroll2Controller.dispose();
    recorder.currentTimestamp.removeListener(_updateMarkerPosition);
    super.dispose();
  }



  void _onNotePressed(String note) {
    widget.track.instrument.playSound(note);
  }

  void _onNoteReleased(String note) {
    widget.track.instrument.stopSound(note);
  }


  Widget _buildPianoKeys() {
    return SizedBox(
      width: 200,
      child: Stack(
        children: [
          // White keys
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: _notes.reversed
                .where((note) => !note.values.first)
                .map((note) {
              final noteName = note.keys.first;
              final height = (noteName[0] == 'B' || noteName[0] == 'C' ||
                      noteName[0] == 'E' || noteName[0] == 'F')
                  ? 60.0
                  : 80.0;

              return NoteWidget(
                note: noteName,
                isBlack: false,
                height: height,
                onPressed: () => _onNotePressed(noteName),
                onReleased: () => _onNoteReleased(noteName),
              );
            }).toList(),
          ),

          // Black keys
          Positioned(
            left: -2,
            child: Column(
              children: _notes.reversed
                  .where((note) => note.values.first)
                  .map((note) {
                final noteName = note.keys.first;
                double topPadding = 80;
                if (noteName.startsWith('F#') || noteName.startsWith('G#') || noteName.startsWith('C#') || noteName == "A#5") {
                  topPadding = 40;
                }

                return Padding(
                  padding: EdgeInsets.only(top: topPadding),
                  child: SizedBox(
                    height: 40,
                    child: NoteWidget(
                      note: noteName,
                      isBlack: true,
                      width: 197 / 1.5,
                      onPressed: () => _onNotePressed(noteName),
                      onReleased: () => _onNoteReleased(noteName),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }





  Widget _buildGrid(BuildContext context, double totalWidth) {
    final scrollbarOffsetY = _verticalScrollController.hasClients ? _verticalScrollController.offset : 0.0;
    final scrollbarOffsetX = _horizontalScrollController.hasClients ? _horizontalScrollController.offset : 0.0;

    return Expanded(
      child: Stack(
        children: [
          // Grid Background
          Container(
            color: const Color.fromARGB(54, 5, 5, 5), // Grid background
            child: GridView.builder(
              controller: _verticalScrollController,
              itemCount: _notes.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1,
                mainAxisExtent: 40,
              ),
              itemBuilder: (context, index) {
                final noteName = _notes[_notes.length - index - 1].keys.first;

                return DragTarget<Note>(
                  onWillAccept: (_) => true,
                  onAccept: (draggedNote) {
                    setState(() {
                      draggedNote.noteName = noteName;
                    });
                  },
                  builder: (context, candidateData, rejectedData) {
                    return GestureDetector(
                      onTapDown: (details) {
                        if (!playingCurrently.value) { // Check if already playing
                          _onNotePressed(noteName);
                        }
                        
                        double clickXPosition = details.localPosition.dx;
                        clickXPosition = (clickXPosition / _snapStep).floor() * _snapStep;
                        clickXPosition += scrollbarOffsetX;

                        widget.track.addNote(Note(
                          noteName: noteName,
                          startTime: clickXPosition,
                          duration: _lastNoteDuration,
                        ));
                        setState(() {});
                      },
                      onTapUp: (_) => _onNoteReleased(noteName),
                      child: Container(
                        height: 56,
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: Colors.black, width: 0.5),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),


          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: VerticalGridPainter(stepGrid: _snapStep,  scrollOffsetX: scrollbarOffsetX),
              ),
            ),
          ),

          // Displaying the notes
          ...widget.track.notes.map((note) {
            int noteIndex = _notes.indexWhere((n) => n.keys.first == note.noteName);
            double topPosition = (_notes.length - noteIndex - 1) * 40;


            return Positioned(
              left: note.startTime - scrollbarOffsetX,
              top: topPosition - scrollbarOffsetY,
              child: _buildNoteDisplay(note),
            );
          }).toList(),

        ],
      ),
    );
  }



  Widget _buildNoteDisplay(Note note) {
    return Listener(
      onPointerDown: (event) {
        if (event.kind == PointerDeviceKind.mouse && event.buttons == kSecondaryMouseButton) {
          widget.track.notes.remove(note);
          setState(() {});
        }
      },
      child: GestureDetector(
        onPanStart: (details) {
          setState(() {
            _initialMouseOffsetX = details.globalPosition.dx - note.startTime;
          });
        },
        onPanUpdate: (details) {
          _updateNotePositionAndDuration(note, details);
        },
        onPanEnd: (_) {
          setState(() {
            note.startTime = max(note.startTime, 0);
          });
        },
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 50, 168, 50),
                border: Border.all(color: const Color.fromARGB(255, 71, 201, 71), width: 2),
              ),
              width: note.duration.toDouble(),
              height: 40,
              child: Center(
                child: Text(
                  note.noteName,
                  style: const TextStyle(color: Colors.white, fontSize: 10),
                ),
              ),
            ),
            // Left Resize Handle
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: _buildResizeHandle(note, true),
            ),

            // Right Resize Handle
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              child: _buildResizeHandle(note, false),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildResizeHandle(Note note, bool isLeftHandle) {
    return GestureDetector(
      onPanStart: (details) {
        setState(() {
          _initialMouseOffsetX = details.globalPosition.dx - note.startTime;
          _initialNoteDuration = note.duration;
        });
      },
      onPanUpdate: (details) {
        setState(() {
          double clickXPosition = details.globalPosition.dx;
          double adjustedMouseX = clickXPosition - _initialMouseOffsetX!;
          double mouseGridX = (adjustedMouseX / _snapStep).floor() * _snapStep;

          if (isLeftHandle) {
            if (mouseGridX >= note.startTime + note.duration) {
              return;
            }

            if (mouseGridX < 0) {
              return;
            }
            double difference = note.startTime - mouseGridX;

            note.startTime = mouseGridX;
            note.duration += difference;


          } else {
            note.duration = _initialNoteDuration! + (mouseGridX - note.startTime);
          }
          note.duration = max(note.duration, _snapStep);
          _lastNoteDuration = note.duration;
        });
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.resizeLeftRight,
        child: Container(
          width: 10,
          color: Colors.transparent,
        ),
      ),
    );
  }


  void _updateNotePositionAndDuration(Note note, DragUpdateDetails details) {
    setState(() {
      double clickYPosition = details.globalPosition.dy + _verticalScrollController.offset;
      int mouseGridY = (clickYPosition / 40).floor();


      double clickXPosition = details.globalPosition.dx;
      double adjustedMouseX = clickXPosition - _initialMouseOffsetX!;
      double mouseGridX = (adjustedMouseX / _snapStep).floor() * _snapStep;

      note.startTime = mouseGridX;


      int newNoteIndex = (_notes.length + 2) - mouseGridY;

      if (newNoteIndex >= 0 && newNoteIndex < _notes.length) {
        String newNoteName = _notes[newNoteIndex].keys.first;
        if (note.noteName != newNoteName) {
          widget.track.instrument.playSound(newNoteName);
          widget.track.instrument.stopSound(note.noteName, fadeOutDuration: const Duration(milliseconds: 5));
        }
        note.noteName = newNoteName;
      }
    });
  }



  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    double totalWidth = widget.track.duration + 400;

    return Stack(
      children: [
        Column(
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                final minWidth = constraints.maxWidth - 200;
                return Container(
                  margin: const EdgeInsets.only(left: 200),
                  child: RawScrollbar(
                    controller: _horizontalScrollController,
                    thumbColor: const Color.fromRGBO(58, 58, 71, 1),
                    trackColor: const Color.fromRGBO(20, 20, 28, 1),
                    thumbVisibility: true,
                    trackVisibility: true,
                    radius: const Radius.circular(20),
                    thickness: 12,
                    child: SingleChildScrollView(
                      controller: _horizontalScrollController,
                      scrollDirection: Axis.horizontal,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(minWidth: minWidth),
                        child: SizedBox(
                          width: totalWidth,
                          height: 12,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),

            Padding(
              padding: const EdgeInsets.only(left: 200),
              child: TimestampMarker(onPositionChanged: _updateMarkerPosition, trackMarker: true),
            ),

            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Scrollbar(
                    controller: _verticalScroll2Controller,
                    thumbVisibility: true,
                    child: SingleChildScrollView(
                      controller: _verticalScroll2Controller,
                      child: _buildPianoKeys(),
                    ),
                  ),
                  _buildGrid(context, totalWidth),
                ],
              ),
            ),
          ],
        ),

        getLine(_markerPosition, screenHeight, 200),
      ],
    );
  }
}



class VerticalGridPainter extends CustomPainter {
  final double stepGrid;
  final double scrollOffsetX;

  VerticalGridPainter({required this.stepGrid, required this.scrollOffsetX});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.1)
      ..strokeWidth = 1;

    final paint2 = Paint()
      ..color = Colors.black.withOpacity(0.4)
      ..strokeWidth = 1;

    for (double x = stepGrid - scrollOffsetX % stepGrid; x < size.width; x += stepGrid) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    double bigStepGrid = stepGrid * 16;
    for (double x = bigStepGrid - scrollOffsetX % bigStepGrid; x < size.width; x += bigStepGrid) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint2);
    }
  }


  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
