import 'package:flutter_test/flutter_test.dart';
import 'package:google_apis_flutter/features/google_maps/domain/entities/map_place.dart';

void main() {
  group('LatLng / MapPlace / MapMarker', () {
    test('LatLng JSON roundtrip', () {
      const ll = LatLng(latitude: 30.0444, longitude: 31.2357);
      final j = ll.toJson();
      expect(LatLng.fromJson(j), ll);
    });

    test('MapPlace requires id/name/address/location', () {
      const p = MapPlace(
        id: 'p1',
        name: 'HQ',
        address: '123 Main St',
        location: LatLng(latitude: 30.0, longitude: 31.0),
      );
      expect(p.id, 'p1');
    });

    test('MapMarker JSON roundtrip preserves title/snippet', () {
      const m = MapMarker(
        id: 'm1',
        position: LatLng(latitude: 30, longitude: 31),
        title: 'A',
        snippet: 'B',
      );
      final j = m.toJson();
      final back = MapMarker.fromJson(j);
      expect(back.id, m.id);
      expect(back.title, 'A');
      expect(back.snippet, 'B');
    });
  });
}
