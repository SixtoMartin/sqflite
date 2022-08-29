import 'dart:io';

import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_common_ffi/src/database_factory_ffi.dart';
import 'package:sqflite_common_ffi/src/windows/setup.dart';

/// The database factory to use for ffi.
///
/// Check support documentation.
///
/// Currently supports Win/Mac/Linux.
DatabaseFactory get databaseFactoryFfi => databaseFactoryFfiImpl;

/// Creates an FFI database factory.
/// Optionally the FFIInit function can be provided if you want to override
/// some behavior with the sqlite3 dynamic library opening. This function should
/// be either a top level function or a static function.
/// Prefer the use of the [databaseFactoryFfi] getter if you don't need this functionality.
DatabaseFactory createDatabaseFactoryFfi({FFIInit? ffiInit}) {
  return createDatabaseFactoryFfiImpl(ffiInit: ffiInit);
}

/// Optional. Initialize ffi loader.
///
/// Call in main until you find a loader for your needs.
void sqfliteFfiInit() {
  if (Platform.isWindows) {
    windowsInit();
  }
}
