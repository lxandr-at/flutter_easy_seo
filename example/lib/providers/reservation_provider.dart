import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/hotel.dart';
import '../models/sample_data.dart';

class ReservationNotifier extends Notifier<List<Reservation>> {
  @override
  List<Reservation> build() {
    return List.from(SampleData.sampleReservations);
  }

  void addReservation(Reservation reservation) {
    state = [...state, reservation];
  }

  void removeReservation(String id) {
    state = state.where((r) => r.id != id).toList();
  }
}

final reservationsProvider = NotifierProvider<ReservationNotifier, List<Reservation>>(
  ReservationNotifier.new,
);
