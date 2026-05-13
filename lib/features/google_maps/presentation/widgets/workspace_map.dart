import 'package:flutter/material.dart';
import 'package:google_apis_flutter/features/google_maps/domain/entities/map_place.dart' as dom;
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;

/// Reusable map widget used across verticals (BizCalendar event locations,
/// DriveVault site map, etc). Wraps `google_maps_flutter` with a simpler
/// interface using domain types.
class WorkspaceMap extends StatefulWidget {
  const WorkspaceMap({
    super.key,
    required this.center,
    this.zoom = 12,
    this.markers = const <dom.MapMarker>[],
    this.onTap,
    this.myLocationEnabled = false,
  });

  final dom.LatLng center;
  final double zoom;
  final List<dom.MapMarker> markers;
  final void Function(dom.LatLng)? onTap;
  final bool myLocationEnabled;

  @override
  State<WorkspaceMap> createState() => _WorkspaceMapState();
}

class _WorkspaceMapState extends State<WorkspaceMap> {
  gmaps.GoogleMapController? _controller;

  @override
  void didUpdateWidget(covariant WorkspaceMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.center != widget.center && _controller != null) {
      _controller!.animateCamera(
        gmaps.CameraUpdate.newLatLng(
          gmaps.LatLng(widget.center.latitude, widget.center.longitude),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return gmaps.GoogleMap(
      initialCameraPosition: gmaps.CameraPosition(
        target: gmaps.LatLng(widget.center.latitude, widget.center.longitude),
        zoom: widget.zoom,
      ),
      markers: widget.markers
          .map(
            (m) => gmaps.Marker(
              markerId: gmaps.MarkerId(m.id),
              position: gmaps.LatLng(m.position.latitude, m.position.longitude),
              infoWindow: gmaps.InfoWindow(
                title: m.title,
                snippet: m.snippet,
              ),
            ),
          )
          .toSet(),
      myLocationEnabled: widget.myLocationEnabled,
      onMapCreated: (c) => _controller = c,
      onTap: widget.onTap == null
          ? null
          : (latLng) => widget.onTap!(
                dom.LatLng(
                  latitude: latLng.latitude,
                  longitude: latLng.longitude,
                ),
              ),
    );
  }
}
