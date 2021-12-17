import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/src/factory_impl.dart';
import 'package:sqflite/src/mixin/factory.dart';
import 'package:sqflite/src/sqflite_impl.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('sqflite', () {
    const channel = MethodChannel('com.tekartik.sqflite');

    final log = <MethodCall>[];
    String response;

    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      log.add(methodCall);
      return response;
    });

    tearDown(() {
      log.clear();
    });

    test('databaseFactory', () async {
      expect(databaseFactory is SqfliteInvokeHandler, isTrue);
    });

    test('supportsConcurrency', () async {
      expect(supportsConcurrency, isFalse);
    });
  });
}
