import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:geofence_flutter/geofence_flutter.dart';
import 'package:geolocator/geolocator.dart';
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
  String geofenceEvent = '';
  StreamSubscription<GeofenceEvent>? geofenceEventStream;

  List<LatLng> tappedPoints = [];
  List<LatLng> circlePosition = [];
  var latitude;
  var longitude;
  double _geoFenceRadius = 200;
  StreamSubscription? _subscription;
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
          radius: _geoFenceRadius // 2000 meters | 2 km
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

    void initGeoFenceService() async {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission != LocationPermission.denied) {
          print("permission for location granted");
        } else {
          print("Location Permission should be granted to use GeoFenceSerive");
        }
      } else {
        print("permission for location granted");
      }
    }

    @override
    void initState() {
      super.initState();
      initGeoFenceService();
    }

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
              value: _geoFenceRadius,
              max: 1000,
              divisions: 10,
              label: _geoFenceRadius.round().toString(),
              onChanged: (double value) {
                setState(() {
                  _geoFenceRadius = value;
                });
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                    child: const Text("Start Geo Fencing"),
                    onPressed: () async {
                      await Geofence.startGeofenceService(
                          pointedLatitude: latitude.toString(),
                          pointedLongitude: longitude.toString(),
                          radiusMeter: _geoFenceRadius.toString(),
                          eventPeriodInSeconds: 10);
                      if (geofenceEventStream == null) {
                        geofenceEventStream = Geofence.getGeofenceStream()
                            ?.listen((GeofenceEvent event) {
                          print(event.toString());
                          if (event == GeofenceEvent.exit) {
                            print(
                                "------------------------------------out of geoFense");
                          } else if (event == GeofenceEvent.enter) {
                            print(
                                "------------------------------------inside geoFense");
                          }
                          setState(() {
                            print("-----------------updating geofence event");
                            geofenceEvent = event.toString();
                          });
                        });
                      }
                    }),
                ElevatedButton(
                  onPressed: () {
                    Geofence.stopGeofenceService();
                    geofenceEventStream?.cancel();
                  },
                  child: const Text("Stop Geo Fencing"),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _handleTap(TapPosition tapPosition, LatLng latlng) {
    print("this is point location: $latlng");
    setState(() {
      latitude = latlng.latitude;
      longitude = latlng.longitude;
      tappedPoints.clear();
      circlePosition.clear();
      tappedPoints.add(latlng);
      circlePosition.add(latlng);
    });
  }
}
