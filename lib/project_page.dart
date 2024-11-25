import 'package:flutter/material.dart';
import 'package:maisound/track_page.dart';
import 'package:maisound/ui/controlbar.dart';
import 'package:maisound/ui/instrument_tracks.dart';
import 'package:maisound/ui/marker.dart';
import 'package:universal_html/html.dart' as html;

class ProjectPageWidget extends StatefulWidget {
  const ProjectPageWidget({super.key, projectName});

  @override
  State<ProjectPageWidget> createState() => _ProjectPageWidgetState();
}

class _ProjectPageWidgetState extends State<ProjectPageWidget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();

    //recorder.setTrack(track);
    // Prevent default event handler
    html.document.onContextMenu.listen((event) {
      event.preventDefault(); // Impede o menu de contexto de ser exibido
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: scaffoldKey,
        backgroundColor: const Color(0xFF303047),
        body: Column(children: [
          ControlBarWidget(),
          //TimestampMarker(),

          // Main content area with sidebar and expanded content
          Expanded(
            // Sidebar for instrument tracks
            child: InstrumentTracks(),
          )
        ]));
  }
}
