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
  List<LatLng> circlePosition = [];

  double _currentSliderValue = 200;

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

    final newCircle = circlePosition.map((latlng) {
      return CircleMarker(
          point: latlng,
          color: Colors.transparent.withOpacity(0.1),
          borderStrokeWidth: 2,
          useRadiusInMeter: true,
          borderColor: Colors.blue,
          radius: _currentSliderValue // 2000 meters | 2 km
          );
    }).toList();
    // final markers = <Marker>[
    //   Marker(
    //       width: 80,
    //       height: 80,
    //       point: LatLng(19.888603, 73.835057),
    //       builder: (ctx) => const Icon(Icons.pin_drop)),
    // ];
    var circleMarkers = <CircleMarker>[
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
                  CircleLayer(circles: newCircle),
                ],
              ),
            ),
            Slider(
              value: _currentSliderValue,
              max: 1000,
              divisions: 10,
              label: _currentSliderValue.round().toString(),
              onChanged: (double value) {
                setState(() {
                  _currentSliderValue = value;
                });
              },
            ),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {},
                  child: const Text("Start Geo Fencing"),
                ),
                ElevatedButton(
                  onPressed: () {},
                  child: const Text("Stop Geo Fencing"),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  void _handleTap(TapPosition tapPosition, LatLng latlng) {
    print("this is point location: $latlng");
    setState(() {
      tappedPoints.clear();
      circlePosition.clear();
      tappedPoints.add(latlng);
      circlePosition.add(latlng);
    });
  }
}
