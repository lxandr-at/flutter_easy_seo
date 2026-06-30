import 'package:flutter/material.dart';

abstract class RouterAdapter {
  Widget buildApp(String initialLocale);
  void push(BuildContext context, String path);
  void go(BuildContext context, String path);
  void pop(BuildContext context);
  String getCurrentPath(BuildContext context);
  List<String> getPathSegments(BuildContext context);
  String getLocale(BuildContext context);
  String replaceLocale(BuildContext context, String newLocale);

  static RouterAdapter of(BuildContext context) => RouterAdapterScope.of(context);
}

class RouterAdapterScope extends InheritedWidget {
  final RouterAdapter adapter;

  const RouterAdapterScope({
    super.key,
    required this.adapter,
    required super.child,
  });

  static RouterAdapter of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<RouterAdapterScope>();
    assert(scope != null, 'No RouterAdapterScope found in context');
    return scope!.adapter;
  }

  @override
  bool updateShouldNotify(RouterAdapterScope oldWidget) => adapter != oldWidget.adapter;
}
