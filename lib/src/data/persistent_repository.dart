// Picks the platform implementation of createPersistentRepository:
// Drift (SQLite) where dart:io is available, in-memory on web.
export 'persistent_repository_stub.dart'
    if (dart.library.io) 'persistent_repository_io.dart';
