import 'package:more/functional.dart';

import '../core/observable.dart';
import 'create.dart';

/// Creates an [Observable] that uses the provided `callback` to create a new
/// [Observable] on each subscribe.
///
/// For example:
///
/// ```dart
/// defer(() => just(DateTime.now()))
///   .subscribe(Observer(next: print)); // prints the current time
/// ```
Observable<T> defer<T>(Map0<Observable<T>> callback) =>
    create<T>((emitter) => emitter.add(callback().subscribe(emitter)));
