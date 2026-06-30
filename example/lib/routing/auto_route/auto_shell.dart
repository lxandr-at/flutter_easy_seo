import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import '../../widgets/shell_layout.dart';

class AutoShellPage extends StatelessWidget {
  const AutoShellPage({super.key});

  @override
  Widget build(BuildContext context) {
    final routeData = RouteData.of(context);
    final locale = routeData.pathParams.getString('locale', 'de');
    final validLocale = ['de', 'en', 'fr'].contains(locale) ? locale : 'de';
    return ShellLayout(locale: validLocale, child: const AutoRouter());
  }
}
