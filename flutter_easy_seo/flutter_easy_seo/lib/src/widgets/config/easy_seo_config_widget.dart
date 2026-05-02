part of 'package:flutter_easy_seo/flutter_easy_seo.dart';

class EasySEOConfigWidget extends StatelessWidget {
  const EasySEOConfigWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ValueListenableBuilder<bool>(
          valueListenable: EasySEOConfig.instance.enableLiveOutput,
          builder: (context, value, child) {
            return SwitchListTile(
              title: const Text("Live DOM Injection"),
              value: value,
              onChanged: (newValue) => EasySEOConfig.instance.enableLiveOutput.value = newValue,
            );
          },
        ),
        ValueListenableBuilder<bool>(
          valueListenable: EasySEOConfig.instance.enableFileOutput,
          builder: (context, value, child) {
            return SwitchListTile(
              title: const Text("Auto-Download HTML"),
              value: value,
              onChanged: (newValue) => EasySEOConfig.instance.enableFileOutput.value = newValue,
            );
          },
        ),
      ],
    );
  }
}
