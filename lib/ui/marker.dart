import 'package:flutter/material.dart';

class TimestampMarker extends StatefulWidget {
  final Function(double) onPositionChanged; // Callback for position changes

  TimestampMarker({required this.onPositionChanged}); // Add the required callback in the constructor

  @override
  _TimestampMarkerState createState() => _TimestampMarkerState();
}

class _TimestampMarkerState extends State<TimestampMarker> {
  double _markerPosition = 0.0;

  void _onTap(BuildContext context, TapDownDetails details) {
    // Get the x position relative to the container
    final RenderBox box = context.findRenderObject() as RenderBox;
    final localPosition = box.globalToLocal(details.globalPosition);
    setState(() {
      _markerPosition = localPosition.dx;

      // Call the callback to notify parent widget
      widget.onPositionChanged(_markerPosition);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (details) => _onTap(context, details),
      child: Container(
        height: 15, // Not too tall
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacity(0.4), // Darker at the top
              Colors.black.withOpacity(0.1), // Lighter towards the bottom
            ],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              left: _markerPosition - 10, // Offset to center the triangle
              top: 0,
              child: Icon(
                Icons.arrow_drop_down,
                size: 20, // Size of the green arrow
                color: Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
