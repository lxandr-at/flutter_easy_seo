import 'package:flutter/material.dart';

class DialogPage extends Page<void> {
  final Widget child;

  const DialogPage({required super.key, required this.child});

  @override
  Route<void> createRoute(BuildContext context) => PageRouteBuilder(
    settings: this,
    pageBuilder: (_, __, ___) => child,
    opaque: false,
    barrierDismissible: true,
    barrierColor: Colors.black54,
    transitionsBuilder: (_, animation, __, child) =>
        FadeTransition(opacity: animation, child: child),
    transitionDuration: const Duration(milliseconds: 200),
  );
}
