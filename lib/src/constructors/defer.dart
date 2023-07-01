import 'package:more/functional.dart';

import '../core/observable.dart';
import 'create.dart';

/// Creates an [Observable] that uses the provided `callback` to create a new
/// [Observable] on each subscribe.
Observable<T> defer<T>(Map0<Observable<T>> callback) =>
    create<T>((emitter) => emitter.add(callback().subscribe(emitter)));
