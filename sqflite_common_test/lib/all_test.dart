import 'package:test/test.dart';
import 'package:sqflite_common_test/sqflite_test.dart';

import 'batch_test.dart' as batch_test;
import 'doc_test.dart' as doc_test;
import 'exception_test.dart' as exception_test;
import 'exp_test.dart' as exp_test;
import 'log_test.dart' as log_test;
import 'open_flutter_test.dart' as open_flutter_test;
import 'open_test.dart' as open_test;
import 'raw_test.dart' as raw_test;
import 'slow_test.dart' as slow_test;
import 'statement_test.dart' as statement_test;
import 'type_test.dart' as type_test;

/// Run all common tests.
void run(SqfliteTestContext context) {
  group('all', () {
    batch_test.run(context);
    log_test.run(context);
    doc_test.run(context);
    open_flutter_test.run(context);
    slow_test.run(context);
    type_test.run(context);
    statement_test.run(context);
    raw_test.run(context);
    open_test.run(context);
    exception_test.run(context);
    exp_test.run(context);
  });
}
