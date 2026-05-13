import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_apis_flutter/features/google_maps/domain/entities/map_place.dart';
import 'package:google_apis_flutter/features/google_maps/presentation/providers/maps_providers.dart';
import 'package:google_apis_flutter/features/google_maps/presentation/widgets/workspace_map.dart';

class MapsDemoScreen extends ConsumerStatefulWidget {
  const MapsDemoScreen({super.key});

  @override
  ConsumerState<MapsDemoScreen> createState() => _MapsDemoScreenState();
}

class _MapsDemoScreenState extends ConsumerState<MapsDemoScreen> {
  LatLng _center = const LatLng(latitude: 30.0444, longitude: 31.2357); // Cairo
  final List<MapMarker> _markers = <MapMarker>[];
  final TextEditingController _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _doGeocode() async {
    final res = await ref.read(geocodingRepositoryProvider).geocode(_search.text);
    if (!mounted) return;
    res.fold(
      (err) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(err.userMessage)),
      ),
      (results) {
        if (results.isEmpty) return;
        setState(() {
          _center = results.first;
          _markers
            ..clear()
            ..add(MapMarker(
              id: 'searched',
              position: results.first,
              title: _search.text,
            ));
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Map')),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _search,
                    decoration: const InputDecoration(
                      hintText: 'Search address…',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _doGeocode(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _doGeocode,
                ),
              ],
            ),
          ),
          Expanded(
            child: WorkspaceMap(
              center: _center,
              markers: _markers,
              onTap: (latLng) {
                setState(() {
                  _markers.add(MapMarker(
                    id: 'tap_${DateTime.now().millisecondsSinceEpoch}',
                    position: latLng,
                    title: 'Pinned',
                  ));
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
