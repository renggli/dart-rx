library rx.testing.hot_observable;

import 'package:rx/src/core/observable.dart';
import 'package:rx/src/core/observer.dart';
import 'package:rx/src/core/scheduler.dart';
import 'package:rx/src/core/subscription.dart';
import 'package:rx/src/testing/test_events.dart';

class HotObservable<T> with Observable<T> {
  final Scheduler scheduler;
  final List<TestEvent<T>> messages;

  HotObservable(this.scheduler, this.messages);

  @override
  Subscription subscribe(Observer<T> observer) => null;
}
