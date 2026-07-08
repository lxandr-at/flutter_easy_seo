import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/hotel.dart';
import '../models/sample_data.dart';

class HotelsAsyncNotifier extends AsyncNotifier<List<Hotel>> {
  @override
  Future<List<Hotel>> build() async {
    await Future.delayed(const Duration(milliseconds: 50));
    return SampleData.hotels;
  }
}

final hotelsProvider = AsyncNotifierProvider<HotelsAsyncNotifier, List<Hotel>>(
  HotelsAsyncNotifier.new,
);

final selectedHotelProvider = Provider.family<Hotel?, String>((ref, id) {
  return SampleData.hotels.where((h) => h.id == id).firstOrNull;
});
