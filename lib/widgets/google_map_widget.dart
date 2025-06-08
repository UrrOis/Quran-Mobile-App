import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

/// Widget Google Maps dengan fitur pencarian lokasi dan rute dasar.
class GoogleMapWidget extends StatefulWidget {
  final LatLng initialPosition;
  const GoogleMapWidget({Key? key, required this.initialPosition})
    : super(key: key);

  @override
  State<GoogleMapWidget> createState() => _GoogleMapWidgetState();
}

class _GoogleMapWidgetState extends State<GoogleMapWidget> {
  late GoogleMapController _controller;
  final TextEditingController _searchController = TextEditingController();
  Marker? _destinationMarker;
  Polyline? _routePolyline;
  String? _searchError;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Cari lokasi...',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 0,
                  ),
                ),
                onSubmitted: (value) => _searchLocation(value),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () => _searchLocation(_searchController.text),
            ),
          ],
        ),
        if (_searchError != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              _searchError!,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        const SizedBox(height: 8),
        SizedBox(
          height: 350,
          child: GoogleMap(
            initialCameraPosition: CameraPosition(
              target: widget.initialPosition,
              zoom: 14,
            ),
            onMapCreated: (controller) => _controller = controller,
            markers: {
              Marker(
                markerId: const MarkerId('start'),
                position: widget.initialPosition,
                infoWindow: const InfoWindow(title: 'Posisi Awal'),
              ),
              if (_destinationMarker != null) _destinationMarker!,
            },
            polylines: _routePolyline != null ? {_routePolyline!} : {},
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
          ),
        ),
      ],
    );
  }

  /// Ambil rute (directions) dari posisi awal ke tujuan
  Future<void> _getDirections(LatLng origin, LatLng destination) async {
    final apiKey = 'AIzaSyD7utY0gRcb9NorPbcVfVxpF2Kk911RheU';
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/directions/json?origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}&key=$apiKey',
    );
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['routes'] != null && data['routes'].isNotEmpty) {
        final points = data['routes'][0]['overview_polyline']['points'];
        final polyline = _decodePolyline(points);
        setState(() {
          _routePolyline = Polyline(
            polylineId: const PolylineId('route'),
            color: Colors.blue,
            width: 5,
            points: polyline,
          );
        });
      }
    }
  }

  /// Decode polyline Google ke List<LatLng>
  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> polyline = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;
    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;
      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;
      polyline.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return polyline;
  }

  /// Pencarian lokasi menggunakan Google Geocoding API
  Future<void> _searchLocation(String query) async {
    setState(() => _searchError = null);
    if (query.isEmpty) return;
    final apiKey = 'AIzaSyD7utY0gRcb9NorPbcVfVxpF2Kk911RheU';
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/geocode/json?address=${Uri.encodeComponent(query)}&key=$apiKey',
    );
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['results'] != null && data['results'].isNotEmpty) {
        final location = data['results'][0]['geometry']['location'];
        final latLng = LatLng(location['lat'], location['lng']);
        setState(() {
          _destinationMarker = Marker(
            markerId: const MarkerId('destination'),
            position: latLng,
            infoWindow: InfoWindow(title: query),
          );
        });
        _controller.animateCamera(CameraUpdate.newLatLngZoom(latLng, 15));
        // Ambil rute dari posisi awal ke tujuan
        await _getDirections(widget.initialPosition, latLng);
      } else {
        setState(() => _searchError = 'Lokasi tidak ditemukan.');
      }
    } else {
      setState(() => _searchError = 'Gagal menghubungi server Google Maps.');
    }
  }
}
