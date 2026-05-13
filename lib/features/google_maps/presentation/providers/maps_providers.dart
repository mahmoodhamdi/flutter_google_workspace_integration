import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_apis_flutter/features/google_maps/data/repositories/geocoding_repository_impl.dart';

final Provider<GeocodingRepository> geocodingRepositoryProvider =
    Provider<GeocodingRepository>(
  (Ref ref) => GeocodingRepository(),
);
