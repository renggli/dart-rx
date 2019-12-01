library rx.constructors.fork_join;

import '../core/observable.dart';
import '../core/observer.dart';
import 'create.dart';
import 'empty.dart';

/// Waits for all passed [Observable] to complete and then it will emit an
/// list with last values from corresponding observables.
Observable<List<T>> forkJoin<T>(List<Observable<T>> sources) => sources.isEmpty
    ? empty()
    : create<List<T>>((emitter) {
        var completed = 0, emitted = 0;
        final values = List<T>.filled(sources.length, null, growable: false);
        for (var i = 0; i < sources.length; i++) {
          var hasValue = false;
          emitter.add(sources[i].subscribe(Observer(
            next: (value) {
              if (!hasValue) {
                hasValue = true;
                emitted++;
              }
              values[i] = value;
            },
            error: (error, [stack]) => emitter.error(error, stack),
            complete: () {
              completed++;
              if (completed == sources.length || !hasValue) {
                if (emitted == sources.length) {
                  emitter.next(values);
                }
                emitter.complete();
              }
            },
          )));
        }
      });
