import 'package:flutter/material.dart';
import 'package:maisound/classes/globals.dart';
import 'package:maisound/classes/instrument.dart';
import 'package:maisound/ui/marker.dart';

class InstrumentTracks extends StatefulWidget {
  @override
  _InstrumentTracksState createState() => _InstrumentTracksState();
}

class _InstrumentTracksState extends State<InstrumentTracks> {
  double _markerPosition = 0.0;

  void _updateMarkerPosition(double newPosition) {
    setState(() {
      _markerPosition = newPosition;
    });
  }

  // Handle adding a track to the global list
  void _addTrackToPosition(Offset localPosition, int index) {
    // Here, you calculate the start and end based on the position
    // For this example, I'm setting a constant duration (end-start)
    double start = localPosition.dx; // Starting point based on the click
    double end = start + 100; // A default length for the new track block

    setState(() {
      main_tracks.add([index, start, end]);
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Stack(
      children: [
        Column(
          children: [
            // Timestamp marker with an update callback
            Container(
              child: TimestampMarker(onPositionChanged: _updateMarkerPosition),
            ),
            Expanded(
              child: Row(
                children: [
                  // First Column: Instrument Details
                  Container(
                    width: 400,
                    color: const Color(0xFF1D1D26),
                    child: Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            itemCount: instruments.length,
                            itemBuilder: (context, index) {
                              final instrument = instruments[index];
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8.0),
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
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(
                                                  instrument.name,
                                                  style: TextStyle(fontSize: 18),
                                                ),
                                              ],
                                            ),
                                            Slider(
                                              value: instrument.volume,
                                              min: 0,
                                              max: 100,
                                              divisions: 10,
                                              label: '${instrument.volume.round()}',
                                              onChanged: (newValue) {
                                                setState(() {
                                                  instrument.volume = newValue;
                                                });
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
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
                        IconButton(
                          icon: Icon(Icons.add),
                          iconSize: 48,
                          onPressed: () {
                            setState(() {
                              instruments.add(Instrument());
                            });
                          },
                        ),
                      ],
                    ),
                  ),

                  // Second Column: Tracks
                  Container(
                    width: 1600,
                    color: const Color(0x00051681),
                    child: ListView.builder(
                      itemCount: instruments.length,
                      itemBuilder: (context, index) {
                        final instrument = instruments[index];
                        return GestureDetector(
                          onTapDown: (details) {
                            _addTrackToPosition(details.localPosition, index);
                          },
                          child: Stack(
                            children: [
                              Container(
                                height: 120, // Match the height with the first column
                                color: instrument.color.withOpacity(0.1),
                                margin: const EdgeInsets.symmetric(vertical: 8.0),
                                child: Center(),
                              ),
                              for (var track in main_tracks.where((track) => track[0] == index))
                                Positioned(
                                  left: track[1], // Set the position
                                  child: Draggable<Map<String, dynamic>>(
                                    data: {'track': track, 'index': index},
                                    feedback: Container(
                                      width: track[2] - track[1],
                                      height: 120,
                                      decoration: BoxDecoration(
                                        color: instrument.color.withOpacity(0.6),
                                        border: Border.all(color: Colors.black, width: 1),
                                      ),
                                      child: Column(
                                        children: [
                                          // Top bar with track name
                                          Container(
                                            height: 20,
                                            color: Colors.black54,
                                            child: Center(
                                              child: Text(
                                                '${instrument.name} #${index + 1}',
                                                style: TextStyle(color: Colors.white, fontSize: 14),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Container(),
                                          ),
                                        ],
                                      ),
                                    ),
                                    childWhenDragging: Container(),
                                    child: Container(
                                      width: track[2] - track[1],
                                      height: 120,
                                      decoration: BoxDecoration(
                                        color: instrument.color.withOpacity(0.6),
                                        border: Border.all(color: Colors.black, width: 1),
                                      ),
                                      child: Column(
                                        children: [
                                          // Top bar with track name
                                          Container(
                                            height: 20,
                                            color: Colors.black54,
                                            child: Center(
                                              child: Text(
                                                '${instrument.name} #${index + 1}',
                                                style: TextStyle(color: Colors.white, fontSize: 14),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Container(),
                                          ),
                                        ],
                                      ),
                                    ),
                                    onDragEnd: (details) {
                                      setState(() {
                                        // Update the start position after dragging
                                        track[1] = details.offset.dx;
                                        track[2] = track[1] + 100; // Recalculate end
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
                ],
              ),
            ),
          ],
        ),
        // Thin line extending from marker to the bottom of the screen
        Positioned(
          left: _markerPosition - 0.5, // Align the line with the marker's position
          top: 15, // Start just below the marker
          child: Container(
            width: 1, // Thin line
            height: screenHeight - 30, // Extend to the bottom of the screen
            color: Colors.green, // Line color (same as the marker)
          ),
        ),
      ],
    );
  }
}
