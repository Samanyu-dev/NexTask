class AppConfig {
  // Override at build/run time with:
  // --dart-define=API_BASE_URL=https://your-render-service.onrender.com
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://127.0.0.1:8000',
  );
}
