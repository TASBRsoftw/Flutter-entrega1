// Choose the correct storage implementation for the current platform.
// On web, this will use localStorage. On io platforms, it will use the file system.
import 'storage_io.dart' if (dart.library.html) 'storage_web.dart' as impl;

// Re-export a stable API that forwards to the platform implementation.
Future<void> initStorage() => impl.initStorage();
Future<bool> storageExists() => impl.storageExists();
Future<String?> readStorage() => impl.readStorage();
Future<void> writeStorage(String data) => impl.writeStorage(data);
