import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_common/src/constant.dart';
import 'package:sqflite_common/src/database.dart';
import 'package:sqflite_common/src/database_mixin.dart';
import 'package:sqflite_common/src/exception.dart';
import 'package:sqflite_common/src/factory.dart';
import 'package:sqflite_common/src/mixin/factory.dart';
import 'package:sqflite_common/src/open_options.dart';
import 'package:synchronized/synchronized.dart';

/// Base factory implementation
abstract class SqfliteDatabaseFactoryBase with SqfliteDatabaseFactoryMixin {}

/// Named lock, unique by name and its private class
class _NamedLock {
  factory _NamedLock(String name) {
    // Add to cache, create if needed
    return cacheLocks[name] ??= _NamedLock._(name, Lock(reentrant: true));
  }

  _NamedLock._(this.name, this.lock);

  // Global cache per db name
  // Remain allocated forever but that is fine.
  static final cacheLocks = <String, _NamedLock>{};

  final String name;
  final Lock lock;
}

/// Common factory mixin
mixin SqfliteDatabaseFactoryMixin
    implements SqfliteDatabaseFactory, SqfliteInvokeHandler {
  /// To override to wrap wanted exception
  @override
  Future<T> wrapDatabaseException<T>(Future<T> Function() action) => action();

  /// Invoke native method and wrap exception.
  Future<T> safeInvokeMethod<T>(String method, [dynamic arguments]) =>
      wrapDatabaseException<T>(() => invokeMethod(method, arguments));

  /// Open helpers for single instances only.
  Map<String, SqfliteDatabaseOpenHelper> databaseOpenHelpers =
      <String, SqfliteDatabaseOpenHelper>{};

  // open lock mechanism
  @override
  @deprecated
  final Lock lock = Lock(reentrant: true);

  /// Avoid concurrent open operation on the same database
  Lock _getDatabaseOpenLock(String path) => _NamedLock(path).lock;

  @override
  @override
  SqfliteDatabase newDatabase(
      SqfliteDatabaseOpenHelper openHelper, String path) {
    return SqfliteDatabaseBase(openHelper, path);
  }

  @override
  void removeDatabaseOpenHelper(String path) {
    databaseOpenHelpers.remove(path);
  }

  // Close an instance of the database
  @override
  Future<void> closeDatabase(SqfliteDatabase database) {
    // Lock per database name
    final lock = _getDatabaseOpenLock(database.path);
    return lock.synchronized(() async {
      await (database as SqfliteDatabaseMixin)
          .openHelper!
          .closeDatabase(database);
      if (database.options?.singleInstance != false) {
        removeDatabaseOpenHelper(database.path);
      }
    });
  }

  @override
  Future<Database> openDatabase(String path,
      {OpenDatabaseOptions? options}) async {
    path = await fixPath(path);
    // Lock per database name
    final lock = _getDatabaseOpenLock(path);
    return lock.synchronized(() async {
      options ??= SqfliteOpenDatabaseOptions();

      if (options?.singleInstance != false) {
        SqfliteDatabaseOpenHelper? getExistingDatabaseOpenHelper(String path) {
          return databaseOpenHelpers[path];
        }

        void setDatabaseOpenHelper(SqfliteDatabaseOpenHelper? helper) {
          if (helper == null) {
            databaseOpenHelpers.remove(path);
          } else {
            databaseOpenHelpers[path] = helper;
          }
        }

        var databaseOpenHelper = getExistingDatabaseOpenHelper(path);

        final firstOpen = databaseOpenHelper == null;
        if (firstOpen) {
          databaseOpenHelper = SqfliteDatabaseOpenHelper(this, path, options);
          setDatabaseOpenHelper(databaseOpenHelper);
        }
        try {
          return await (databaseOpenHelper!.openDatabase()
              as FutureOr<Database>);
        } catch (e) {
          // If first open fail remove the reference
          if (firstOpen) {
            removeDatabaseOpenHelper(path);
          }
          rethrow;
        }
      } else {
        final databaseOpenHelper =
            SqfliteDatabaseOpenHelper(this, path, options);
        return await (databaseOpenHelper.openDatabase() as FutureOr<Database>);
      }
    });
  }

  @override
  Future<void> deleteDatabase(String path) async {
    path = await fixPath(path);
    // Lock per database name
    final lock = _getDatabaseOpenLock(path);
    return lock.synchronized(() async {
      // Handle already single instance open database
      removeDatabaseOpenHelper(path);
      return safeInvokeMethod<void>(
          methodDeleteDatabase, <String, dynamic>{paramPath: path});
    });
  }

  @override
  Future<bool> databaseExists(String path) async {
    path = await fixPath(path);
    return safeInvokeMethod<bool>(
        methodDatabaseExists, <String, dynamic>{paramPath: path});
  }

  String? _databasesPath;

  @override
  Future<String> getDatabasesPath() async {
    if (_databasesPath == null) {
      final path = await safeInvokeMethod<String?>(methodGetDatabasesPath);

      if (path == null) {
        throw SqfliteDatabaseException('getDatabasesPath is null', null);
      }
      _databasesPath = path;
    }
    return _databasesPath!;
  }

  /// Set the databases path.
  @override
  Future<void> setDatabasesPath(String? path) async {
    _databasesPath = path;
  }

  /// True if a database path is in memory
  static bool isInMemoryDatabasePath(String path) {
    return path == inMemoryDatabasePath;
  }

  /// path must be non null
  Future<String> fixPath(String path) async {
    if (isInMemoryDatabasePath(path)) {
      // nothing
    } else {
      if (isRelative(path)) {
        path = join(await getDatabasesPath(), path);
      }
      path = absolute(normalize(path));
    }
    return path;
  }

  /// True if it is a real path. Unused?
  @deprecated
  bool isPath(String path) {
    return !isInMemoryDatabasePath(path);
  }

  /// Debug information.
  Future<SqfliteDebugInfo> getDebugInfo() async {
    final info = SqfliteDebugInfo();
    final dynamic map =
        await safeInvokeMethod(methodDebug, <String, dynamic>{'cmd': 'get'});
    final dynamic databasesMap = map[paramDatabases];
    if (databasesMap is Map) {
      info.databases = databasesMap.map((dynamic id, dynamic info) {
        final dbInfo = SqfliteDatabaseDebugInfo();
        final databaseId = id.toString();

        if (info is Map) {
          dbInfo.fromMap(info);
        }
        return MapEntry<String, SqfliteDatabaseDebugInfo>(databaseId, dbInfo);
      });
    }
    info.logLevel = map[paramLogLevel] as int?;
    return info;
  }
}

// When opening the database (bool)
/// Native parameter (int)
const String paramLogLevel = 'logLevel';

/// Native parameter
const String paramDatabases = 'databases';

/// Debug information
class SqfliteDatabaseDebugInfo {
  /// Database path
  String? path;

  /// Whether the database was open as a single instance
  bool? singleInstance;

  /// Log level
  int? logLevel;

  /// Deserializer
  void fromMap(Map<dynamic, dynamic> map) {
    path = map[paramPath]?.toString();
    singleInstance = map[paramSingleInstance] as bool?;
    logLevel = map[paramLogLevel] as int?;
  }

  /// Debug formatting helper
  Map<String, dynamic> toDebugMap() {
    final map = <String, dynamic>{
      paramPath: path,
      paramSingleInstance: singleInstance
    };
    if ((logLevel ?? sqfliteLogLevelNone) > sqfliteLogLevelNone) {
      map[paramLogLevel] = logLevel;
    }
    return map;
  }

  @override
  String toString() => toDebugMap().toString();
}

/// Internal debug info
class SqfliteDebugInfo {
  /// List of databases
  Map<String, SqfliteDatabaseDebugInfo>? databases;

  /// global log level (set for new opened databases)
  int? logLevel;

  /// Debug formatting helper
  Map<String, dynamic> toDebugMap() {
    final map = <String, dynamic>{};
    if (databases != null) {
      map[paramDatabases] = databases!.map(
          (String key, SqfliteDatabaseDebugInfo dbInfo) =>
              MapEntry<String, Map<String, dynamic>>(key, dbInfo.toDebugMap()));
    }
    if ((logLevel ?? sqfliteLogLevelNone) > sqfliteLogLevelNone) {
      map[paramLogLevel] = logLevel;
    }
    return map;
  }

  @override
  String toString() => toDebugMap().toString();
}
