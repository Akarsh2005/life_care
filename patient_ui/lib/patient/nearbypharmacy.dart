// ignore_for_file: deprecated_member_use, library_private_types_in_public_api, use_key_in_widget_constructors, use_build_context_synchronously

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class NearbyPharmacy extends StatefulWidget {
  @override
  _NearbyPharmacyState createState() => _NearbyPharmacyState();
}

class _NearbyPharmacyState extends State<NearbyPharmacy> {
  Position? _currentPosition;
  late MapController _mapController;
  final String apiKey =
      "vk4KAuoAjiNPgl2DEtfW4wdkgobLhARj"; // Replace with your TomTom API key
  List<Marker> _pharmacyMarkers = [];
  bool _showPharmacies = false;

  // Stream subscription for real-time position updates
  StreamSubscription<Position>? _positionStreamSubscription;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _checkLocationPermissionAndFetch();
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    super.dispose();
  }

  void _checkLocationPermissionAndFetch() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showError("Location services are disabled.");
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showError("Location permission denied.");
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _showError(
        "Location permission permanently denied. Enable it from settings.",
      );
      return;
    }

    _getCurrentLocation();
  }

  void _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );
      setState(() {
        _currentPosition = position;
        _mapController.move(
          LatLng(position.latitude, position.longitude),
          15.0,
        );
      });

      // Start listening to position updates
      _positionStreamSubscription = Geolocator.getPositionStream(
        locationSettings: LocationSettings(
          accuracy: LocationAccuracy.best,
          distanceFilter: 10,
        ),
      ).listen((Position position) {
        setState(() {
          _currentPosition = position;
        });
      });
    } catch (e) {
      _showError("Failed to get location: $e");
    }
  }

  Future<void> _fetchNearbyPharmacies() async {
    if (_currentPosition == null) return;

    double lat = _currentPosition!.latitude;
    double lon = _currentPosition!.longitude;

    String url =
        "https://api.tomtom.com/search/2/nearbySearch/.json?key=$apiKey&lat=$lat&lon=$lon&radius=5000&categorySet=7397";

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        List<Marker> markers = [];

        if (data["results"] != null && data["results"].isNotEmpty) {
          for (var result in data["results"]) {
            double pharmacyLat = result["position"]["lat"];
            double pharmacyLon = result["position"]["lon"];
            markers.add(
              Marker(
                point: LatLng(pharmacyLat, pharmacyLon),
                width: 40,
                height: 40,
                child: Icon(Icons.local_pharmacy, color: Colors.red, size: 30),
              ),
            );
          }
        }

        setState(() {
          _pharmacyMarkers = markers;
          _showPharmacies = true;
        });
      } else {
        _showError("Error fetching nearby pharmacies.");
      }
    } catch (e) {
      _showError("Network error: $e");
    }
  }

  void _togglePharmacies() async {
    if (_showPharmacies) {
      setState(() {
        _pharmacyMarkers.clear();
        _showPharmacies = false;
      });
      return;
    }

    await _fetchNearbyPharmacies();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Nearby Pharmacies")),
      body: Stack(
        children: [
          Positioned.fill(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter:
                    _currentPosition != null
                        ? LatLng(
                          _currentPosition!.latitude,
                          _currentPosition!.longitude,
                        )
                        : LatLng(52.376372, 4.908066), // Default location
                initialZoom: 15.0,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      "https://api.tomtom.com/map/1/tile/basic/main/{z}/{x}/{y}.png?key=$apiKey",
                ),
                MarkerLayer(markers: _pharmacyMarkers),
              ],
            ),
          ),

          Positioned(
            bottom: 20,
            left: 10,
            right: 10,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _togglePharmacies,
                  child: Text(
                    _showPharmacies ? "Hide Pharmacies" : "Show Pharmacies",
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
