import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RouteMapWidget extends StatelessWidget {
  final LatLng origin;
  final LatLng destination;
  final List<LatLng> polylinePoints;
  const RouteMapWidget({
    super.key,
    required this.origin,
    required this.destination,
    required this.polylinePoints,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: GoogleMap(
        initialCameraPosition: CameraPosition(target: origin, zoom: 13),
        markers: {
          Marker(markerId: MarkerId('origin'), position: origin),
          Marker(markerId: MarkerId('destination'), position: destination),
        },
        polylines: {
          Polyline(
            polylineId: PolylineId('route'),
            color: Colors.blue,
            width: 5,
            points: polylinePoints,
          ),
        },
      ),
    );
  }
}
