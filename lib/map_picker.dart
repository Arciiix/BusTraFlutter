import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapPicker extends StatefulWidget {
  final LatLng? initialLocation;

  const MapPicker({Key? key, this.initialLocation}) : super(key: key);

  @override
  _MapPickerState createState() => _MapPickerState();
}

class _MapPickerState extends State<MapPicker> {
  MapController _mapController = MapController();
  LatLng? selectedPlace;

  void _changeMarkerPosition(_, LatLng coordinates) {
    print(coordinates);
    setState(() {
      selectedPlace = coordinates;
    });
  }

  @override
  void initState() {
    if (widget.initialLocation != null) {
      setState(() {
        selectedPlace = widget.initialLocation;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Zaznacz miejsce na mapie"), actions: [
          IconButton(
              icon: const Icon(Icons.check),
              onPressed: () => Navigator.pop(context, selectedPlace))
        ]),
        body: FlutterMap(
          mapController: _mapController,
          options: MapOptions(
              center: LatLng(50, 18.5), zoom: 10, onTap: _changeMarkerPosition),
          layers: [
            TileLayerOptions(
              urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
              subdomains: ['a', 'b', 'c'],
            ),
            MarkerLayerOptions(
                markers: selectedPlace != null
                    ? [
                        Marker(
                            width: 100,
                            height: 100,
                            point: selectedPlace!,
                            builder: (ctx) => Container(
                                  //The icon anchor point is its center - move it to the top by adding bottom margin
                                  margin: EdgeInsets.only(bottom: 52),
                                  child: const Icon(Icons.location_on,
                                      color: Colors.blue, size: 52),
                                )),
                      ]
                    : []),
          ],
        ));
  }
}
