import 'activity_repository.dart';

/// Web fallback: no dart:io / Drift native, so use in-memory storage.
/// Persistence on web (drift wasm) is a later enhancement.
ActivityRepository createPersistentRepository() => InMemoryActivityRepository();
