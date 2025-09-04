class ClassifierConfig {
  static const String apiBaseUrl = String.fromEnvironment(
    'CLASSIFIER_API_URL',
    defaultValue: 'python api',
  );

  // المسار الصحيح حسب سجلات Render
  static const String apiPath = '/predict';

  // Optional: if your Render service requires a key/token, set here or via --dart-define
  static const String apiKey = String.fromEnvironment(
    'CLASSIFIER_API_KEY',
    defaultValue: '',
  );

  // إعدادات الشبكة
  static const int connectionTimeoutSeconds = 60;
  static const int maxRetries = 3;
  static const int retryDelaySeconds = 2;
  static const int serverCheckTimeoutSeconds = 10;
}
