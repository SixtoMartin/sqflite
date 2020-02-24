#!/usr/bin/env bash

# Fast fail the script on failures.
# and print line as they are read
set -ev

flutter packages get

flutter analyze lib test
flutter analyze --preview-dart-2 lib test

flutter test
flutter test --preview-dart-2

# example
pushd example

flutter packages get

flutter analyze lib test
flutter analyze --preview-dart-2 lib test

flutter test
flutter test --preview-dart-2

# dartdoc