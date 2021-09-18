// Copyright 2019, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:e2e/e2e.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

void main() {
  E2EWidgetsFlutterBinding.ensureInitialized();

  group('sqflite', () {
    group('open', () {
      test('missing directory', () async {
        var path = join('test_missing_sub_dir', 'simple.db');
        try {
          await Directory(dirname(path)).delete(recursive: true);
        } catch (_) {}
        var db =
            await openDatabase(path, version: 1, onCreate: (db, version) async {
          expect(await db.getVersion(), 0);
        });
        expect(await db.getVersion(), 1);
        await db.close();
      });
    });
  });
}
