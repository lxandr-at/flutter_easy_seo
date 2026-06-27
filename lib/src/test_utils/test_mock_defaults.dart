part of 'package:flutter_easy_seo/flutter_easy_seo.dart';

class EasySEOMockPlatformChannels {
  static void useHeadlessDefaultMocks() {
    _allowRealNetWorkRequests();
    _mockPathProvider();
    _mockConnectivityPlugin();
    _mockSharedPreferences();
  }

  static void _allowRealNetWorkRequests() {
    HttpOverrides.global = null;
  }

  static void _mockConnectivityPlugin({String initialResult = 'wifi'}) {
    // 1. Establish a reference to the exact channel name from the exception
    const MethodChannel channel = MethodChannel('dev.fluttercommunity.plus/connectivity');

    // 2. Set the mock method call handler using the modern TestDefaultBinaryMessenger API
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {

      // 3. Robust route handling based on the channel's API contract
      switch (methodCall.method) {
        case 'check':
        // Returns a string or a list of strings representing the active connection type
        // For connectivity_plus v6+, it typically expects a List<String> or a String matching enum names
          return <String>[initialResult];

        default:
        // Fail gracefully for unexpected methods to maintain test safety
          throw MissingPluginException(
            'No implementation found for method ${methodCall.method} on channel ${channel.name}',
          );
      }
    });
  }

  static void _mockPathProvider() {
    const channel = MethodChannel('plugins.flutter.io/path_provider');

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
        switch (methodCall.method) {
          case 'getApplicationSupportDirectory': // Maps to getApplicationSupportPath()
            return '.';
          case 'getTemporaryDirectory':
            return '.';
          case 'getApplicationDocumentsDirectory':
            return '.';
          default:
            return null;
        }
      },
    );
  }

  static void _mockSharedPreferences({Map<String, Object> initialValues = const {}}) {
    // 1. Target the exact internal channel string for SharedPreferences
    const MethodChannel channel = MethodChannel('plugins.flutter.io/shared_preferences');

    // 2. Register the mock handler on the test binary messenger
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {

      switch (methodCall.method) {
        case 'getAll':
        // The shared_preferences plugin expects a prefixed key-value map
        // containing your initial testing states
          return initialValues;

        case 'setBool':
        case 'setString':
        case 'setInt':
        case 'setDouble':
        case 'setStringList':
        case 'remove':
        case 'clear':
        // Return true to simulate a successful disk write operation
          return true;

        default:
          throw MissingPluginException(
            'No implementation found for method ${methodCall.method} on channel ${channel.name}',
          );
      }
    });
  }
}

class JsonCacheInfoRepository {
  final String databaseName;
  File? _targetFile;
  bool _isInitialized = false;
  final Map<String, dynamic> _memoryStorage = {};

  JsonCacheInfoRepository({required this.databaseName});

  bool get _isUnderTest => Platform.environment.containsKey('FLUTTER_TEST');

  /// Initialize the cache file target using native OS paths
  Future<void> open() async {
    if (_isInitialized) return;

    if (!_isUnderTest) {
      // NATIVE REPLACEMENT: Grabs the OS system temp directory directly
      final Directory systemTempDir = Directory.systemTemp;

      // Namespace it so it is cleanly siloed on the user's host file system
      final String directoryPath = p.join(systemTempDir.path, 'flutter_easy_seo_cache');
      await Directory(directoryPath).create(recursive: true);

      _targetFile = File(p.join(directoryPath, '$databaseName.json'));
    }

    _isInitialized = true;
  }

  Future<void> deleteDataFile() async {
    if (_isUnderTest) {
      _memoryStorage.clear();
    } else if (_targetFile != null && await _targetFile!.exists()) {
      await _targetFile!.delete();
    }
  }
}