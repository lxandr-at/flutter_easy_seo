import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter_easy_seo/flutter_easy_seo.dart';

void main() {
  EasySEOManager.instance.init(
      enableInteractiveMode: kDebugMode, // enable interactive mode in debug mode
      enableLiveOutput: kDebugMode, // inject to DOM in debug mode
      baseUrl: "https://mysite.com",
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: EasySEOPage(
          title: 'Some Web Page',
          child: SizedBox.expand(
            child: Center(
              child: EasySEOTextWrapper(child: Text('Hello World')),
            ),
          ),
        ),
      ),
    );
  }
}
