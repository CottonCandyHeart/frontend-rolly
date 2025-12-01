import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:frontend_rolly/models/route.dart';
import 'package:frontend_rolly/models/route_point.dart';
import 'package:latlong2/latlong.dart';

List<LatLng> toLatLng(List<RoutePoint> points) {
  return points.map((p) => LatLng(p.latitude, p.longitude)).toList();
}

class RouteMap extends StatelessWidget {
  final TrainingRoute route;

  const RouteMap({super.key, required this.route});

  @override
  Widget build(BuildContext context) {
    final List<LatLng> latLngPoints = toLatLng(route.points);

    return FlutterMap(
      options: MapOptions(
        initialCenter: latLngPoints.isNotEmpty
            ? latLngPoints.first          // Jeśli są punkty → pierwszy punkt
            : LatLng(52.2297, 21.0122),   // Jeśli brak → Warszawa
        initialZoom: latLngPoints.isNotEmpty ? 15 : 5,
      ),
      children: [
        TileLayer(
          urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
          userAgentPackageName: 'com.example.app',
        ),

        if (latLngPoints.isNotEmpty)
          PolylineLayer(
            polylines: [
              Polyline(
                points: latLngPoints,
                strokeWidth: 4,
                color: Colors.blue,
              )
            ],
          ),

        if (route.photos.isNotEmpty)
          MarkerLayer(
            markers: [
              for (var photo in route.photos)
                Marker(
                  width: 40,
                  height: 40,
                  point: LatLng(photo.latitude, photo.longitude),
                  child: GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (_) => Dialog(
                          child: Image.network(photo.imageUrl),
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),

      ],
    );
  }
}
