import 'package:flutter_riverpod/flutter_riverpod.dart';

class BreadcrumbSegment {
  final String label;
  final String slug;

  const BreadcrumbSegment({required this.label, required this.slug});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BreadcrumbSegment && label == other.label && slug == other.slug;

  @override
  int get hashCode => Object.hash(label, slug);
}

class BreadcrumbNotifier extends Notifier<List<BreadcrumbSegment>> {
  @override
  List<BreadcrumbSegment> build() => [];

  void push(BreadcrumbSegment segment) => state = [...state, segment];

  void pop() {
    if (state.isNotEmpty) {
      state = state.sublist(0, state.length - 1);
    }
  }

  void set(List<BreadcrumbSegment> segments) => state = segments;

  void clear() => state = [];
}

final breadcrumbProvider =
    NotifierProvider<BreadcrumbNotifier, List<BreadcrumbSegment>>(
  BreadcrumbNotifier.new,
);
