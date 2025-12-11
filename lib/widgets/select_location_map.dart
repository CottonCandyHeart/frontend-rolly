import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class SelectLocationMap extends StatefulWidget {
  final Function(LatLng) onLocationSelected;

  const SelectLocationMap({super.key, required this.onLocationSelected});

  @override
  State<SelectLocationMap> createState() => _SelectLocationMapState();
}

class _SelectLocationMapState extends State<SelectLocationMap> {
  LatLng? selectedPoint;

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: MapOptions(
        initialCenter: LatLng(52.2297, 21.0122), // Warszawa
        initialZoom: 13,
        onTap: (tapPosition, point) {
          setState(() => selectedPoint = point);
          widget.onLocationSelected(point);
        },
      ),
      children: [
        TileLayer(
          urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
          userAgentPackageName: 'com.example.app',
        ),

        if (selectedPoint != null)
          MarkerLayer(
            markers: [
              Marker(
                point: selectedPoint!,
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
