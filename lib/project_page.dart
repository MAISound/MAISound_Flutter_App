import 'package:flutter/material.dart';
import 'package:maisound/track_page.dart';
import 'package:maisound/ui/controlbar.dart';
import 'package:maisound/ui/instrument_tracks.dart';
import 'package:maisound/ui/marker.dart';


class ProjectPageWidget extends StatefulWidget {
  const ProjectPageWidget({super.key, projectName});

  @override
  State<ProjectPageWidget> createState() => _ProjectPageWidgetState();
}

class _ProjectPageWidgetState extends State<ProjectPageWidget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: const Color(0xFF303047),

      body: Column(
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
              ...List.generate(4, (index) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: FlutterFlowIconButton(
                      borderColor: const Color(0xFF242436),
                      borderRadius: 10,
                      borderWidth: 1,
                      buttonSize: 40,
                      fillColor: const Color(0xFF4B4B5B),
                      icon: const Icon(Icons.crop_square, color: Colors.white, size: 24),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HomePage(),
                          ),
                        );
                      },
                    ),
                  )),
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
              value: _volume,
              onChanged: (newValue) {
                setState(() {
                  _volume = newValue;
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
                onPressed: () {},
              ),
              FlutterFlowIconButton(
                borderColor: const Color(0xFF242436),
                borderRadius: 10,
                borderWidth: 1,
                buttonSize: 40,
                fillColor: const Color(0xFF4B4B5B),
                icon: _isPlaying
                    ? const Icon(Icons.pause_circle, color: Colors.white, size: 24)
                    : const Icon(Icons.play_circle, color: Colors.white, size: 24),
                onPressed: () {
                  setState(() {
                    _isPlaying = !_isPlaying;
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
              
              // Dropdown placeholder
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.purple),
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.black54,
                ),
                child: Row(
                  children: const [
                    Text(
                      "Piano Solo #2",
                      style: TextStyle(color: Colors.white),
                    ),
                    Icon(Icons.arrow_drop_down, color: Colors.white),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}



  // Sidebar for managing sound containers (instrument tracks)
  Widget _buildSidebar() {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Expanded(
          child: Container(
            width: 202,
            height: 100,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1D1D26), Color(0xFF131319)],
                stops: [0, 1],
                begin: AlignmentDirectional(0, -1),
                end: AlignmentDirectional(0, 1),
              ),
            ),
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(0, 10, 0, 0),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Align(
                    alignment: AlignmentDirectional(0, 0),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Container(
                            width: 100,
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
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                FlutterFlowIconButton(
                                  borderColor: const Color(0xFF242436),
                                  borderRadius: 10,
                                  borderWidth: 1,
                                  buttonSize: 40,
                                  fillColor: const Color(0xFF4B4B5B),
                                  icon: const Icon(
                                    Icons.menu,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                  onPressed: () {
                                    print('MenuBtn pressed ...');
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => HomePage(),
                                      ),
                                    );
                                  },
                                ),
                                Slider(
                                  activeColor:
                                      FlutterFlowTheme.of(context).primary,
                                  inactiveColor:
                                      FlutterFlowTheme.of(context).alternate,
                                  min: 0,
                                  max: 10,
                                  value: _volume,
                                  onChanged: (newValue) {
                                    setState(() {
                                      _volume = newValue;
                                    });
                                  },
                                ),
                                FlutterFlowIconButton(
                                  borderColor: const Color(0xFF242436),
                                  borderRadius: 10,
                                  borderWidth: 1,
                                  buttonSize: 40,
                                  fillColor: const Color(0xFF4B4B5B),
                                  icon: const Icon(
                                    Icons.fast_rewind,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                  onPressed: () {
                                    print('RewindBtn pressed ...');
                                  },
                                ),
                                FlutterFlowIconButton(
                                  borderColor: const Color(0xFF242436),
                                  borderRadius: 10,
                                  borderWidth: 1,
                                  buttonSize: 40,
                                  fillColor: const Color(0xFF4B4B5B),
                                  icon: _isPlaying
                                      ? const Icon(
                                          Icons.pause_circle,
                                          color: Colors.white,
                                          size: 24,
                                        )
                                      : const Icon(
                                          Icons.play_circle,
                                          color: Colors.white,
                                          size: 24,
                                        ),
                                  onPressed: () {
                                    setState(() {
                                      _isPlaying = !_isPlaying;
                                    });
                                    print('PlayBtn pressed ...');
                                  },
                                ),
                                FlutterFlowIconButton(
                                  borderColor: const Color(0xFF242436),
                                  borderRadius: 10,
                                  borderWidth: 1,
                                  buttonSize: 40,
                                  fillColor: const Color(0xFF4B4B5B),
                                  icon: const Icon(
                                    Icons.loop,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                  onPressed: () {
                                    print('LoopBtn pressed ...');
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Container(
                                width: 202,
                                height: 100,
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Color(0xFF1D1D26),
                                      Color(0xFF131319)
                                    ],
                                    stops: [0, 1],
                                    begin: AlignmentDirectional(0, -1),
                                    end: AlignmentDirectional(0, 1),
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                      0, 10, 0, 0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      ..._soundContainers, 
                                      Padding(
                                        padding: const EdgeInsetsDirectional
                                            .fromSTEB(0, 20, 0, 0),
                                        child: FlutterFlowIconButton(
                                          borderColor: const Color(0xFF242436),
                                          borderRadius: 10,
                                          borderWidth: 1,
                                          buttonSize: 40,
                                          fillColor: const Color(0xFF4B4B5B),
                                          icon: const Icon(
                                            Icons.add,
                                            color: Colors.white,
                                            size: 24,
                                          ),
                                          onPressed: () {
                                            _addSoundContainer();
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [],
                          ),
                        ),
                      ],
                    )
                  ),
                  ..._soundContainers, // List of sound containers
                  

                  // Add sound container button
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(0, 20, 0, 0),
                    child: FlutterFlowIconButton(
                      borderColor: const Color(0xFF242436),
                      borderRadius: 10,
                      borderWidth: 1,
                      buttonSize: 40,
                      fillColor: const Color(0xFF4B4B5B),
                      icon: const Icon(Icons.add, color: Colors.white, size: 24),
                      onPressed: _addSoundContainer,

                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Sound container widget (individual track)
class _SoundContainer extends StatefulWidget {
  final double widthFactor;
  final double heightFactor;

  const _SoundContainer({
    required this.widthFactor,
    required this.heightFactor,
  });

  @override
  _SoundContainerState createState() => _SoundContainerState();
}

class _SoundContainerState extends State<_SoundContainer> {
  double _volume = 5; // Local volume control for each sound container

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Material(
        color: Colors.transparent,
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Container(
          width: MediaQuery.of(context).size.width * widget.widthFactor,
          height: MediaQuery.of(context).size.height * widget.heightFactor,
          decoration: BoxDecoration(
            color: Color(0xFF593884),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(width: 0),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Align(
                alignment: AlignmentDirectional(0, 0),
                child: Slider(
                  activeColor: FlutterFlowTheme.of(context).primary,
                  inactiveColor: FlutterFlowTheme.of(context).alternate,
                  min: 0,
                  max: 10,
                  value: _volume,
                  onChanged: (newValue) {
                    setState(() {
                      _volume = newValue;
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ),
          ControlBarWidget(),
          //TimestampMarker(),

          // Main content area with sidebar and expanded content
          Expanded(
              // Sidebar for instrument tracks
              child: InstrumentTracks(),
            )
        ]
      )
    );
  }

}