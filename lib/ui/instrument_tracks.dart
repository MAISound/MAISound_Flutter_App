import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:maisound/classes/globals.dart';
import 'package:maisound/classes/instrument.dart';
import 'package:maisound/classes/recorder.dart';
import 'package:maisound/classes/track.dart';
import 'package:maisound/track_page.dart';
import 'package:maisound/ui/marker.dart';

class InstrumentTracks extends StatefulWidget {
  @override
  _InstrumentTracksState createState() => _InstrumentTracksState();
}

class _InstrumentTracksState extends State<InstrumentTracks>{
  double _markerPosition = 0.0;

  double? initialMouseOffsetX;
  double snapStep = 64;

  List<String> availableInstruments = ["Piano", "Bass", "Saxofone", "Arpa", "Guitarra"];

  bool _isExpanded = true;

  late final ScrollController _horizontalScrollController;
  late final ScrollController _verticalScrollController;
  late final ScrollController _verticalScroll2Controller;

  

  // Métodos para os listeners
  void _onCurrentTimestampChanged() {
    setState(() {
      _updateMarkerPosition(recorder.getTimestamp(false));
    });
  }

  void _onPlayOnlyTrackChanged() {
    setState(() {
      // A lógica que você deseja quando playOnlyTrack mudar
    });
  }

  void _updateMarkerPosition(double newPosition) {
    setState(() {
      _markerPosition = newPosition - XScrollOffset.value;
    });
  }
  

  @override
  void initState() {
    recorder.currentTimestamp.addListener(_onCurrentTimestampChanged);
    recorder.playOnlyTrack.addListener(_onPlayOnlyTrackChanged);
    _horizontalScrollController = ScrollController();
    _verticalScrollController = ScrollController();
    _verticalScroll2Controller = ScrollController();

    _verticalScrollController.addListener(() {
      if (_verticalScrollController.offset != _verticalScroll2Controller.offset) {
        _verticalScroll2Controller.jumpTo(_verticalScrollController.offset);
      }
    });

    _verticalScroll2Controller.addListener(() {
      if (_verticalScrollController.offset != _verticalScroll2Controller.offset) {
        _verticalScrollController.jumpTo(_verticalScroll2Controller.offset);
      }
    });

    _horizontalScrollController.addListener(() {
      XScrollOffset.value = _horizontalScrollController.offset;
      _onCurrentTimestampChanged();
      setState(() {
        //_markerPosition = recorder.getTimestamp(false) - XScrollOffset.value;
      }); // Rebuild on horizontal scroll
    });

    super.initState();
  }

  @override
  void dispose(){
    _horizontalScrollController.dispose();
    _verticalScrollController.dispose();
    _verticalScroll2Controller.dispose();
    recorder.currentTimestamp.removeListener(_onCurrentTimestampChanged);
    recorder.playOnlyTrack.removeListener(_onPlayOnlyTrackChanged);
    super.dispose();
  }

  // Notes that are being played currently
  // List<Note> playing_notes = [];
  // void _updateMarkerPosition(double newPosition) {
  //   // Play music
  //   if (playingCurrently.value && playingTrack == null) {
  //     // Loop through tracks
  //     for (var t = 0; t < tracks_structure.length; t++) {
  //       Track track = tracks_structure[t][0];
  //       double trackStart = tracks_structure[t][1];

  //       // Check if the track is relevant to the marker position
  //       if (_markerPosition < trackStart) {
  //         // Skip this track if it's not yet reached by the marker
  //         continue;
  //       }

  //       // Loop through notes in the track
  //       for (var i = 0; i < track.notes.length; i++) {
  //         Note current_note = track.notes[i];

  //         double noteStartTime = current_note.startTime + trackStart;
  //         double noteEndTime = current_note.startTime + current_note.duration + trackStart;

  //         if (playing_notes.contains(current_note)) {
  //           // Stop notes if marker is out of note's time range
  //           if (_markerPosition < noteStartTime || _markerPosition > noteEndTime) {
  //             playing_notes.remove(current_note);
  //             track.instrument.stopSound(current_note.noteName);
  //           }
  //         } else {
  //           // Play note if marker is within note's time range
  //           if (_markerPosition > noteStartTime && _markerPosition < noteEndTime) {
  //             playing_notes.add(current_note);
  //             track.instrument.playSound(current_note.noteName);
  //           }
  //         }
  //       }
  //     }
  //   }

  //   // Update the marker position
  //   if (mounted) {
  //     setState(() {
  //       _markerPosition = newPosition;
  //     });
  //   }
  // }

  bool _isOverlapping(Track newTrack, List<Track> existingTracks) {
    for (Track track in existingTracks) {
      if ((newTrack.startTime < track.startTime + track.duration) &&
          (newTrack.startTime + newTrack.duration > track.startTime)) {
        // Overlap detected
        return true;
      }
    }
    return false;
  }

  void _addTrackToPosition(Offset position, int instrumentIndex, Instrument instrument) {
    setState(() {
      double newTrackStartTime = ((position.dx + _horizontalScrollController.offset) / snapStep).floor() * snapStep;  // Calculate the grid-aligned start time

      Track newTrack = Track(instrument);
      newTrack.startTime = newTrackStartTime;

      // Check if the new track would overlap with any existing track
      if (_isOverlapping(newTrack, tracks.where((track) => track.instrument == instrument).toList())) {
        // If there's an overlap, don't add the new track
        print('Cannot place track, overlap detected.');
        return;
      }

      // If no overlap, add the new track
      setState(() {
        tracks.add(newTrack);
      });
    });
}

  double _getMaxTrackWidth() {
    double highestEndTime = 0.0;
    for (Track track in tracks) {
      double time = track.startTime + track.duration;
      if (time > highestEndTime) {
        highestEndTime = time;
      }
    }

    return highestEndTime;
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    //final screenWidth = MediaQuery.of(context).size.width;
    final maxTrackWidth = _getMaxTrackWidth() + 400; // Add some margin
    
    return Stack(
      children: [

        Column(
          
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                // `constraints.maxWidth` provides the available width of the parent
                final minWidth = constraints.maxWidth - (_isExpanded ? 400 : 200);

                return Container(
                  margin: EdgeInsets.only(left: _isExpanded ? 400 : 200),
                  child: RawScrollbar(
                    controller: _horizontalScrollController,

                    thumbColor: Color.fromRGBO(58, 58, 71, 1),
                    trackColor: Color.fromRGBO(20, 20, 28, 1),
                    thumbVisibility: true,
                    trackVisibility: true,
                    radius: Radius.circular(20),
                    thickness: 12,

                    child: SingleChildScrollView(
                      controller: _horizontalScrollController,
                      scrollDirection: Axis.horizontal,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minWidth: minWidth, // Set the minimum width to the available context width
                        ),
                        child: SizedBox(
                          width: maxTrackWidth,
                          height: 12,
                          child: SizedBox(),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            
            // Marcador do tempo
            Padding(
              padding: EdgeInsets.only(left: _isExpanded? 400 : 200,),
              child: TimestampMarker(onPositionChanged: _updateMarkerPosition, trackMarker: false),
            ),
            
            Expanded(
              // Scrollbar horizontal
              child: Row(
                children: [
                  Scrollbar(
                    controller: _verticalScroll2Controller,
                    thickness: 0,
                  
                  // Coluna dos instrumentos
                    child: AnimatedContainer(
                    duration: Duration(milliseconds: 600),
                    width: _isExpanded? 400 : 200,
                    color: const Color(0xFF1D1D26),
                    child: Column(
                      children: [
                        Expanded(
                          // Constroi cada instrumento
                          child: ListView.builder(
                            controller: _verticalScroll2Controller,
                            itemCount: instruments.length,
                            itemBuilder: (context, index) {
                              // Instrumento atual
                              final instrument = instruments[index];
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                child: Stack(
                                  children: [
                                    Material(
                                      color: instrument.color,
                                      elevation: 5,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(24),
                                      ),
                                      child: Container(
                                        height: 120,
                                        padding: const EdgeInsets.all(16.0),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                // Nome do instrumento / Mudar instrumento
                                                InkWell(
                                                  onTap: () {
                                                    showModalBottomSheet(
                                                      context: context,
                                                      builder: (context) {
                                                        return ListView.builder(
                                                          itemCount: availableInstruments.length,  // List of available instruments
                                                          itemBuilder: (context, idx) {
                                                            final availableInstrument = availableInstruments[idx];
                                                            return ListTile(
                                                              title: Text(availableInstrument),
                                                              onTap: () {
                                                                setState(() {
                                                                  if (availableInstrument == "Bass") {
                                                                    instrument.setInstrumentType(InstrumentTypes.bass);
                                                                  }
                                                                  if (availableInstrument == "Piano") {
                                                                    instrument.setInstrumentType(InstrumentTypes.piano);
                                                                  }
                                                                  if (availableInstrument == "Saxofone") {
                                                                    instrument.setInstrumentType(InstrumentTypes.saxofone);
                                                                  }
                                                                  if (availableInstrument == "Arpa") {
                                                                    instrument.setInstrumentType(InstrumentTypes.arpa);
                                                                  }
                                                                  if (availableInstrument == "Guitarra") {
                                                                    instrument.setInstrumentType(InstrumentTypes.guitarra);
                                                                  }
                                                                  
                                                                });
                                                                Navigator.pop(context);  // Close the bottom sheet after selection
                                                              },
                                                            );
                                                          },
                                                        );
                                                      },
                                                    );
                                                  },
                                                  child: Text(
                                                    instrument.name,
                                                    style: TextStyle(fontSize: 18),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            // Slider de volume
                                            _isExpanded? Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Expanded(
                                                  child: Slider(
                                                    value: instrument.volume,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        instrument.volume = value;
                                                      });
                                                    },
                                                    min: 0,
                                                    max: 1,
                                                    divisions: 100,
                                                    label: instrument.volume.toStringAsFixed(2),
                                                  ),
                                                ),
                                                IconButton(
                                                  icon: Icon(Icons.volume_off),
                                                  onPressed: () {
                                                    setState(() {
                                                      instrument.volume = 0;
                                                    });
                                                  },
                                                ),
                                              ],
                                            ) : SizedBox(),
                                          ],
                                        ),
                                      ),
                                    ),
                                    // Botão de remover
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: IconButton(
                                        icon: Icon(Icons.close),
                                        onPressed: () {
                                          setState(() {
                                            for(int i = 0; i < tracks.length; i++) {
                                              if(tracks[i].instrument == instrument) {
                                                tracks.removeAt(i);
                                              }
                                            }	
                                            instruments.removeAt(index);
                                            
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                        // Botão de adicionar instrumento
                        IconButton(
                          icon: Icon(Icons.add),
                          iconSize: 48,
                          onPressed: () {
                            setState(() {
                              instruments.add(Instrument());
                            });
                          },
                        ),
                        IconButton(
                          icon: Icon(_isExpanded? Icons.arrow_back : Icons.arrow_forward),
                        onPressed: () {
                          setState(() {
                            _isExpanded = !_isExpanded;
                          });
                        }),
                      ],
                    ),
                  ),),

                  // Coluna de Tracks (de cada instrumento)
                  Expanded(
                    child: Container(
                      color: const Color(0x00051681),
                      // Sroll bar vertical
                      child: RawScrollbar(
                        controller: _verticalScrollController, // Associates the ScrollController

                        thumbColor: Color.fromRGBO(58, 58, 71, 1),
                        trackColor: Color.fromRGBO(20, 20, 28, 1),
                        thumbVisibility: true,
                        trackVisibility: true,
                        radius: Radius.circular(20),
                        thickness: 12,

                        child: ListView.builder(
                          controller: _verticalScrollController, // Syncs the ListView with the ScrollController
                          itemCount: instruments.length,
                          itemBuilder: (context, index) {
                            final instrument = instruments[index];

                            // Filter tracks specific to the current instrument
                            final instrumentTracks = tracks.where((Track track) {
                              return track.instrument == instrument;
                            }).toList();

                            return GestureDetector(
                              child: Stack(
                                children: [
                                  // Show the background line for the track
                                  Container(
                                    height: 120,
                                    color: instrument.color.withOpacity(0.1),
                                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                                  ),

                                  // Build the track for the current instrument
                                  ...instrumentTracks.map((Track track) {
                                    double startTime = track.startTime - _horizontalScrollController.offset;
                                    PointerDownEvent? _cachedPointerDownEvent;
                                    print(track);
                                    print(track.notes);

                                    return Positioned(
                                      left: startTime,
                                      top: 8.0,
                                      child: Listener(
                                        
                                        // Deleta uma track
                                        onPointerDown: (event) {
                                          _cachedPointerDownEvent = event;
                                          // Lógica para tratar PointerDown
                                          if (event.kind == PointerDeviceKind.mouse && event.buttons == kSecondaryMouseButton) {
                                            setState(() {
                                              tracks.remove(track);
                                            });
                                          }
                                        },

                                        child: GestureDetector(
                                          child: Stack(
                                            children: [
                                              Container(
                                                decoration: BoxDecoration(
                                                  color: Color.fromARGB(255, 17, 0, 80),
                                                  border: Border.all(
                                                    color: Color.fromARGB(255, 41, 13, 168),
                                                    width: 2,
                                                  ),
                                                ),
                                                width: track.duration.toDouble(),
                                                height: 120,
                                              ),
                                              Container(
                                                color: instrument.color,
                                                width: track.duration.toDouble(),
                                                height: 30,
                                              ),
                                              Positioned(
                                                top: 0,
                                                left: 0,
                                                right: 0,
                                                child: Center(
                                                  child: Text(
                                                    instrument.name,
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ),

                                              // Draw track notes
                                              for (var note in track.notes)

                                                Positioned(
                                                  top: 30.0 +
                                                      (track.highestNoteIndex -
                                                              note.noteNameToInteger()) *
                                                          (90.0 / (track.noteRange + 1)),
                                                  left: note.startTime.toDouble(),
                                                  width: note.duration.toDouble(),
                                                  height:
                                                      _calculateNoteHeight(track.noteRange, 90.0),
                                                  child: Container(
                                                    color: Colors.blue, // Replace with desired color
                                                  ),
                                                ),

                                              // Draw playback bar
                                              if (currentTrack == track &&
                                                  playingCurrently.value == true)
                                                Positioned(
                                                  top: 30.0,
                                                  left: recorder.getTimestamp(true),
                                                  width: 2,
                                                  height: 90,
                                                  child: Container(
                                                    color: Colors.green, // Replace with desired color
                                                  ),
                                                )
                                            ],
                                          ),
                                          onPanStart: (details) {
                                            setState(() {
                                              double clickXPosition = details.globalPosition.dx - _horizontalScrollController.offset;
                                              double trackXPosition = startTime - _horizontalScrollController.offset; // Current X position of the track

                                              // Calculate the initial mouse offset correctly
                                              initialMouseOffsetX = clickXPosition - trackXPosition - _horizontalScrollController.offset;
                                            });
                                          },
                                          onPanUpdate: (details) {
                                            // Deleta um projeto
                                            // if (_cachedPointerDownEvent != null) {
                                            //   print(_cachedPointerDownEvent);
                                            //   if (_cachedPointerDownEvent!.kind == PointerDeviceKind.mouse && _cachedPointerDownEvent!.buttons == kSecondaryMouseButton) {
                                            //     return;
                                            //   }
                                            // }

                                            setState(() {
                                              double clickXPosition = details.globalPosition.dx;

                                              // Convert absolute mouse position to grid position
                                              double adjustedMouseX =
                                                  clickXPosition - initialMouseOffsetX!;
                                              double mouseGridX =
                                                  (adjustedMouseX / snapStep).floor() * snapStep;

                                              // Update the track position
                                              track.startTime = mouseGridX;
                                            });
                                          },
                                          onPanEnd: (details) {
                                            setState(() {});
                                          },
                                          onTap: () {
                                            currentTrack = track;
                                          },
                                          onDoubleTap: () {
                                            Navigator.pushReplacement(
                                              context,
                                              PageRouteBuilder(
                                                pageBuilder: (context, animation1, animation2) =>
                                                    TrackPageWidget(track: track),
                                                transitionDuration: Duration.zero,
                                                reverseTransitionDuration: Duration.zero,
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ],
                              ),
                              onTapDown: (details) {
                                _addTrackToPosition(details.localPosition, index, instrument);
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
        Container(
          child: recorder.playOnlyTrack.value ? SizedBox() : ((_markerPosition + (_isExpanded? 400 : 200)) < (_isExpanded? 400 : 200) ? SizedBox() : getLine(_markerPosition, screenHeight, _isExpanded? 400 : 200,))
          )
      ],
    );
  }
}

double _calculateNoteHeight(int noteRange, double containerHeight) {
  const minNoteHeight = 1.0; // Adjust as needed
  double maxNoteHeight = containerHeight; // Adjust as needed

  if (noteRange == -1 || noteRange == 0) {
    return maxNoteHeight; // Handle empty or single-note cases
  }

  double calculatedHeight = containerHeight / (noteRange + 1);
  return calculatedHeight.clamp(minNoteHeight, maxNoteHeight);
}
