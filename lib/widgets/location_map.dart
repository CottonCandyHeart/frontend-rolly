import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:frontend_rolly/models/location.dart';
import 'package:frontend_rolly/models/route_point.dart';
import 'package:latlong2/latlong.dart';

List<LatLng> toLatLng(List<RoutePoint> points) {
  return points.map((p) => LatLng(p.latitude, p.longitude)).toList();
}

class LocationMap extends StatelessWidget {
  final Location location;

  const LocationMap({super.key, required this.location});

  @override
  Widget build(BuildContext context) {
    final LatLng latLngPoint = LatLng(location.latitude, location.longitude);

    if (location.latitude.isNaN ||
        location.longitude.isNaN ||
        location.latitude.isInfinite ||
        location.longitude.isInfinite) {
      return const Text("Invalid coordinates");
    }

    return FlutterMap(
      options: MapOptions(
        initialCenter: latLngPoint,
        initialZoom: 15,
      ),
      children: [
        TileLayer(
          urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
          userAgentPackageName: 'com.example.app',
        ),

        
        MarkerLayer(
            markers: [
              Marker(
                point: latLngPoint,
                width: 40,
                height: 40,
                child: Icon(
                  Icons.location_on,
                  size: 40,
                  color: Colors.red,
                ),
              ),
            ],
          ),
      ],
    );
  }
}
