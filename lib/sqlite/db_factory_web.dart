// Web platform — sqflite is not natively supported on web.
// The app will show a graceful error state for database operations.
Future<void> initDatabaseFactory() async {
  // No-op on web: sqflite does not support browser environments.
  // HomeScreen and other screens will show error/empty states.
}
