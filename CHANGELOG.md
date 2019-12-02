## 0.7.1

* add `Batch.query`, `Batch.rawQuery` and `Batch.execute`
* pack query result as colums/rows instead of List<Map>

## 0.7.0

* Add support for `--preview-dart-2`

## 0.6.2+1

* Add longer description to pubspec.yaml

## 0.6.2

* Fix travis warning

## 0.6.1

* Add Flutter SDK constraint to pubspec.yaml

## 0.6.0

* add support for `onConfigure` to allow for database configuration
 
## 0.5.0

* Escape table and column name when needed in insert/update/query/delete
* Export ConflictAlgorithm, escapeName, unescapeName in new sql.dart

## 0.4.0

* Add support for Batch (insert/update/delete)

## 0.3.1

* Remove temp concurrency experiment

## 0.3.0
 
2018/01/04

* **Breaking change**. Upgraded to Gradle 4.1 and Android Studio Gradle plugin
  3.0.1. Older Flutter projects need to upgrade their Gradle setup as well in
  order to use this version of the plugin. Instructions can be found
  [here](https://github.com/flutter/flutter/wiki/Updating-Flutter-projects-to-Gradle-4.1-and-Android-Studio-Gradle-plugin-3.0.1).
  
## 0.2.4

* Dependency on synchronized updated to >=1.1.0

## 0.2.3

* Make Android sends the reponse in the same thread then the caller to prevent unexpected behavior when an error occured

## 0.2.2

* Fix unchecked warning on Android

## 0.2.0

* Use NSOperationQueue for all db operation on iOS
* Use ThreadHandler for all db operation on Android

## 0.0.3

* Add exception handling

## 0.0.2

* Add sqlite helpers based on Razvan Lung suggestions

## 0.0.1

* Initial experimentation
