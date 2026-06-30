import 'package:flutter/material.dart';

PageRouteBuilder<void> buildDialogRoute({
  required RouteSettings settings,
  required Widget child,
}) {
  return PageRouteBuilder<void>(
    settings: settings,
    pageBuilder: (_, __, ___) => child,
    opaque: false,
    barrierDismissible: true,
    barrierColor: Colors.black54,
    transitionsBuilder: (_, animation, __, child) =>
        FadeTransition(opacity: animation, child: child),
    transitionDuration: const Duration(milliseconds: 200),
  );
}
