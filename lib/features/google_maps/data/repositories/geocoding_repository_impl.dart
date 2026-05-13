import 'package:geocoding/geocoding.dart' as geo;
import 'package:google_apis_flutter/core/errors/guard.dart';
import 'package:google_apis_flutter/core/errors/result.dart';
import 'package:google_apis_flutter/features/google_maps/domain/entities/map_place.dart';

class GeocodingRepository {
  /// Forward geocode: address text -> coordinates.
  Future<Result<List<LatLng>>> geocode(String address) =>
      guard<List<LatLng>>(() async {
        final results = await geo.locationFromAddress(address);
        return results
            .map((l) => LatLng(latitude: l.latitude, longitude: l.longitude))
            .toList(growable: false);
      }, operation: 'geocoding.forward');

  /// Reverse geocode: coordinates -> human-readable address.
  Future<Result<String>> reverse(LatLng coords) =>
      guard<String>(() async {
        final placemarks = await geo.placemarkFromCoordinates(
          coords.latitude,
          coords.longitude,
        );
        if (placemarks.isEmpty) return '';
        final p = placemarks.first;
        return <String?>[
          p.street,
          p.subLocality,
          p.locality,
          p.administrativeArea,
          p.country,
        ].whereType<String>().where((s) => s.isNotEmpty).join(', ');
      }, operation: 'geocoding.reverse');
}
