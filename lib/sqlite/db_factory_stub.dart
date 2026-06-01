// Default stub — used on platforms where no specific init is needed (e.g. Android/iOS).
// sqflite already works out of the box on those platforms.
Future<void> initDatabaseFactory() async {
  // No-op: sqflite has a built-in factory on mobile platforms
}
