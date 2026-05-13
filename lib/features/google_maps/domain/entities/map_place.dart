import 'package:freezed_annotation/freezed_annotation.dart';

part 'map_place.freezed.dart';
part 'map_place.g.dart';

@freezed
class LatLng with _$LatLng {
  const factory LatLng({
    required double latitude,
    required double longitude,
  }) = _LatLng;

  factory LatLng.fromJson(Map<String, dynamic> json) => _$LatLngFromJson(json);
}

@freezed
class MapPlace with _$MapPlace {
  const factory MapPlace({
    required String id,
    required String name,
    required String address,
    required LatLng location,
    String? phoneNumber,
    String? website,
    double? rating,
  }) = _MapPlace;

  factory MapPlace.fromJson(Map<String, dynamic> json) =>
      _$MapPlaceFromJson(json);
}

@freezed
class MapMarker with _$MapMarker {
  const factory MapMarker({
    required String id,
    required LatLng position,
    String? title,
    String? snippet,
  }) = _MapMarker;

  factory MapMarker.fromJson(Map<String, dynamic> json) =>
      _$MapMarkerFromJson(json);
}
