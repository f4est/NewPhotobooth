abstract interface class StartupRepository {
  Future<void> setRunOnStartup(bool enabled);
}
