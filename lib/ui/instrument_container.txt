import 'package:flutter/material.dart';
import 'package:maisound/classes/instrument.dart';

class InstrumentSidebar extends StatefulWidget {
  @override
  _InstrumentSidebarState createState() => _InstrumentSidebarState();
}

class _InstrumentSidebarState extends State<InstrumentSidebar> {
  List<Widget> _instrumentContainers = [];

  @override
  void initState() {
    super.initState();
    _addInstrumentContainer("Piano", Icons.piano, Colors.purple);
    _addInstrumentContainer("Guitar", Icons.music_note, Colors.orange);
  }

  void _addInstrumentContainer(
      String instrumentName, IconData icon, Color color) {
    setState(() {
      _instrumentContainers.add(
        _InstrumentContainer(
            instrumentName: instrumentName,
            icon: icon,
            color: color,
            instrument: Instrument()),
      );
    });
  }

  void _showAddInstrumentDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Add Instrument"),
          content: Container(
            width: double.maxFinite,
            child: ListView(
              shrinkWrap: true,
              children: [
                ListTile(
                  title: Text("Piano"),
                  onTap: () {
                    Navigator.of(context).pop();
                    _addInstrumentContainer(
                        "Piano", Icons.music_note, Colors.blue);
                  },
                ),
                ListTile(
                  title: Text("Violino"),
                  onTap: () {
                    Navigator.of(context).pop();
                    _addInstrumentContainer(
                        "Violino", Icons.audiotrack, Colors.green);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ..._instrumentContainers,
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: IconButton(
            icon: Icon(Icons.add, color: Colors.white),
            onPressed: _showAddInstrumentDialog,
            color: Colors.black,
            iconSize: 40,
          ),
        ),
      ],
    );
  }
}

class _InstrumentContainer extends StatefulWidget {
  final String instrumentName;
  final IconData icon;
  final Color color;
  final Instrument instrument;

  _InstrumentContainer({
    required this.instrumentName,
    required this.icon,
    required this.color,
    required this.instrument,
  });

  @override
  _InstrumentContainerState createState() => _InstrumentContainerState();
}

class _InstrumentContainerState extends State<_InstrumentContainer> {
  double _sliderValue = 5; // Initial value for the slider

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Material(
        color: Colors.transparent,
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Container(
          width: double.infinity,
          height: 100,
          decoration: BoxDecoration(
            color: widget.color,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              width: 0,
            ),
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Icon(widget.icon, color: Colors.white, size: 40),
              ),
              Expanded(
                child: Text(
                  widget.instrumentName,
                  style: const TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Slider(
                  value: _sliderValue,
                  min: 0,
                  max: 10,
                  activeColor: Colors.white,
                  inactiveColor: Colors.white38,
                  onChanged: (newValue) {
                    setState(() {
                      _sliderValue = newValue; // Update slider value
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
