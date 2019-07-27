library rx.operators.multicast;

import 'package:rx/src/core/operator.dart';
import 'package:rx/src/core/subject.dart';
import 'package:rx/src/shared/functions.dart';
import 'package:rx/src/subjects/async_subject.dart';
import 'package:rx/src/subjects/behavior_subject.dart';
import 'package:rx/src/subjects/replay_subject.dart';
import 'package:rx/src/subscriptions/composite.dart';

/// Returns an multicast observable that shares the underlying stream.
Operator<T, T> multicast<T>({Subject<T> subject, Map0<Subject<T>> factory}) =>
    (subscriber, source) {
      subject ??= factory() ?? Subject<T>();
      final subscription = CompositeSubscription();
      subscription.add(subject.subscribe(subscriber));
      subscription.add(source.subscribe(subject));
      return subscription;
    };

Operator<T, T> publishBehavior<T>(T value) =>
    multicast<T>(factory: () => BehaviorSubject<T>(value));

Operator<T, T> publishLast<T>() =>
    multicast<T>(factory: () => AsyncSubject<T>());

Operator<T, T> publishReplay<T>({int bufferSize}) =>
    multicast<T>(factory: () => ReplaySubject<T>(bufferSize: bufferSize));
