import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:myapp/map_provider.dart';
import 'package:provider/provider.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Map Box Task")),
      body:
          Container(color: Colors.blue) ??
          Consumer<MapProvider>(
            builder: (context, provider, _) {
              return MapWidget(
                mapOptions: MapOptions(pixelRatio: 12),
                onMapCreated: provider.changeMapController,
              );
            },
          ),
    );
  }
}
