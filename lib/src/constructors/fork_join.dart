library rx.constructors.fork_join;

import 'package:rx/src/constructors/create.dart';
import 'package:rx/src/constructors/empty.dart';
import 'package:rx/src/core/observable.dart';
import 'package:rx/src/core/observer.dart';

extension ForkJoinConstructor on Observable {
  /// Waits for all passed [Observable] to complete and then it will emit an
  /// list with last values from corresponding observables.
  static Observable<List<T>> forkJoin<T>(List<Observable<T>> sources) =>
      sources.isEmpty
          ? empty()
          : create<List<T>>((subscriber) {
              var completed = 0, emitted = 0;
              final values =
                  List<T>.filled(sources.length, null, growable: false);
              for (var i = 0; i < sources.length; i++) {
                var hasValue = false;
                subscriber.add(sources[i].subscribe(Observer(
                  next: (value) {
                    if (!hasValue) {
                      hasValue = true;
                      emitted++;
                    }
                    values[i] = value;
                  },
                  error: (error, [stack]) => subscriber.error(error, stack),
                  complete: () {
                    completed++;
                    if (completed == sources.length || !hasValue) {
                      if (emitted == sources.length) {
                        subscriber.next(values);
                      }
                      subscriber.complete();
                    }
                  },
                )));
              }
            });
}
