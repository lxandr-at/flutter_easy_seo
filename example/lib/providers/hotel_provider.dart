import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/hotel.dart';
import '../models/sample_data.dart';

final hotelsProvider = Provider<List<Hotel>>((ref) => SampleData.hotels);

final selectedHotelProvider = Provider.family<Hotel?, String>((ref, id) {
  return SampleData.hotels.where((h) => h.id == id).firstOrNull;
});
