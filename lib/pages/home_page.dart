import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:positioned_tap_detector_2/positioned_tap_detector_2.dart';

class HomePage extends StatefulWidget {
  static const String route = '/';

  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<LatLng> tappedPoints = [];

  @override
  Widget build(BuildContext context) {
    final markers = tappedPoints.map((latlng) {
      return Marker(
        width: 80,
        height: 80,
        point: latlng,
        builder: (ctx) => const Icon(Icons.pin_drop),
      );
    }).toList();
    // final markers = <Marker>[
    //   Marker(
    //       width: 80,
    //       height: 80,
    //       point: LatLng(19.888603, 73.835057),
    //       builder: (ctx) => const Icon(Icons.pin_drop)),
    // ];
    final circleMarkers = <CircleMarker>[
      CircleMarker(
          point: LatLng(19.888603, 73.835057),
          color: Colors.transparent.withOpacity(0.1),
          borderStrokeWidth: 2,
          useRadiusInMeter: true,
          borderColor: Colors.blue,
          radius: 200 // 2000 meters | 2 km
          ),
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 8, bottom: 8),
              child:
                  Text('This is a map that is showing (19.888603, 73.835057).'),
            ),
            Flexible(
              child: FlutterMap(
                options: MapOptions(
                    center: LatLng(19.888603, 73.835057),
                    zoom: 15,
                    onTap: _handleTap),
                nonRotatedChildren: [
                  AttributionWidget.defaultWidget(
                    source: 'OpenStreetMap contributors',
                    onSourceTapped: () {},
                  ),
                ],
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'dev.fleaflet.flutter_map.example',
                  ),
                  MarkerLayer(markers: markers),
                  CircleLayer(circles: circleMarkers),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleTap(TapPosition tapPosition, LatLng latlng) {
    print("this is point location: $latlng");
    setState(() {
      tappedPoints.add(latlng);
    });
  }
}
