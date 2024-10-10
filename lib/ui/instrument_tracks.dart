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

  List<String> availableInstruments = ["Piano", "Bass"];

  bool _isExpanded = true;

  void _updateMarkerPosition(double newPosition) {
    setState(() {
      _markerPosition = newPosition;
    });
  }

  @override
  void initState() {
    recorder.currentTimestamp.addListener(() {
      //_markerPosition = recorder.currentProjectTimestamp.value;
      //_markerPosition = recorder.getTimestamp(false);

      setState(() {
        _updateMarkerPosition(recorder.getTimestamp(false));
      });
    });

    recorder.playOnlyTrack.addListener(() {
      setState(() {
      });
    });

    _isExpanded = true;

    // recorder.playOnlyTrack.addListener(() {
    //   setState(() {
        
    //   });
    // });

    super.initState();

    setState(() {
       _updateMarkerPosition(recorder.getTimestamp(false));
    });
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

  // Handle adding a track to the global list
  void _addTrackToPosition(Offset localPosition, int index, Instrument instrument) {
    // Here, you calculate the start and end based on the position
    // For this example, I'm setting a constant duration (end-start)
    double start = localPosition.dx; // Starting point based on the click

    setState(() {
      Track newTrack = Track(instrument);
      tracks.add(newTrack);
      newTrack.startTime = start;
      //tracks.add([newTrack, start]);
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Stack(
      children: [
        Column(
          children: [
            // Marcador do tempo
            Padding(
              padding: EdgeInsets.only(left: _isExpanded? 400 : 200,),
              child: TimestampMarker(onPositionChanged: _updateMarkerPosition, trackMarker: false),
            ),
            Expanded(
              child: Row(
                children: [
                  // Coluna dos instrumentos
                  AnimatedContainer(
                    duration: Duration(milliseconds: 600),
                    width: _isExpanded? 400 : 200,
                    color: const Color(0xFF1D1D26),
                    child: Column(
                      children: [
                        Expanded(
                          // Constroi cada instrumento
                          child: ListView.builder(
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
                  ),

                  // Coluna de Tracks (de cada instrumento)
                  Expanded(
                    child: Container(
                      color: const Color(0x00051681),
                      child: ListView.builder(
                        itemCount: instruments.length,
                        itemBuilder: (context, index) {
                          final instrument = instruments[index];
                          
                          // Filtra as tracks e obtem apenas as pertencentes ao instrumento atual
                          // final instrumentTracks = tracks_structure.where((trackStructure) {
                          //   Track track = trackStructure[0];
                          //   return track.instrument == instrument;
                          // }).toList();
                          
                          final instrumentTracks = tracks.where((Track track) {
                            return track.instrument == instrument;
                          }).toList();

                          return GestureDetector(
                            child: Stack(
                              children: [
                                // Mostra a linha da track background
                                Container(
                                  height: 120,
                                  color: instrument.color.withOpacity(0.1),
                                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                                ),

                                // Constroi a track para o instrumento atual
                                ...instrumentTracks.map((Track track) {
                                  //Track track = trackStructure[0];
                                  //double startTime = trackStructure[1];
                                  double startTime = track.startTime;

                                  return Positioned(
                                    left: startTime,
                                    top: 8.0,
                                    child: Listener(
                                      child: GestureDetector(
                                        child: Stack(
                                          children: [
                                            Container(
                                              decoration: BoxDecoration(
                                                color: Color.fromARGB(255, 17, 0, 80),
                                                border: Border.all(color: Color.fromARGB(255, 41, 13, 168), width: 2),
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
                                              top: 30.0 + (track.highestNoteIndex - note.noteNameToInteger()) * (90.0 / (track.noteRange + 1)),
                                              left: note.startTime.toDouble(),
                                              width: note.duration.toDouble(),
                                              height: _calculateNoteHeight(track.noteRange, 90.0),
                                              child: Container(
                                                color: Colors.blue, // Replace with your desired color
                                              ),
                                            ),

                                            // Draw playback bar
                                            if (currentTrack == track && playingCurrently.value == true)
                                              Positioned(
                                                top: 30.0,
                                                left: recorder.getTimestamp(true),
                                                width: 2,
                                                height: 90,
                                                child: Container(
                                                  color: Colors.green, // Replace with your desired color
                                                ),
                                              )
                                          ],
                                        ),

                                        

                                        onPanStart: (details) {
                                          // Quando o mouse é inicialmente pressionado, salva algumas informações importantes
                                          setState(() {
                                            double clickXPosition = details.globalPosition.dx;
                                            double trackXPosition = startTime; // Posição atual X da track
                                            
                                            // Calcula a posição inicial do mouse com um offset correto
                                            initialMouseOffsetX = clickXPosition - trackXPosition;
                                          });
                                        },
                                        onPanUpdate: (details) {
                                          setState(() {
                                            double clickXPosition = details.globalPosition.dx;

                                            // Converte posição absoluta do mouse em posição de grid
                                            double adjustedMouseX = clickXPosition - initialMouseOffsetX!;
                                            double mouseGridX = (adjustedMouseX / snapStep).floor() * snapStep;

                                            // Atualiza posição da musica
                                            track.startTime = mouseGridX;
                                          });
                                        },
                                        onPanEnd: (details) {
                                          // Quando para de arrastar o mouse corrige algumas coisas e atualiza a widget
                                          setState(() {
                                          });
                                        },
                                        onTap: () {
                                          currentTrack = track;
                                        },
                                        onDoubleTap: () {
                                          //recorder.setTrack(track, track.startTime);

                                         // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => TrackPageWidget(track: track)));
                                         Navigator.pushReplacement(
                                          context,
                                          PageRouteBuilder(
                                              pageBuilder: (context, animation1, animation2) => TrackPageWidget(track: track),
                                              transitionDuration: Duration.zero,
                                              reverseTransitionDuration: Duration.zero,
                                          ),
                                        );
                                        },
                                    ),
                                    
                                  ));
                                }
                                ).toList(),
                              ],
                            ),
                            // Adiciona a track na posição clicada
                            onTapDown: (details) {
                              _addTrackToPosition(details.localPosition, index, instrument);
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        Container(
          child: recorder.playOnlyTrack.value ? SizedBox() : getLine(_markerPosition, screenHeight, _isExpanded? 400 : 200,)
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


