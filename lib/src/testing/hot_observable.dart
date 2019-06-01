library rx.testing.hot_observable;

import 'package:rx/src/core/observable.dart';
import 'package:rx/src/core/observer.dart';
import 'package:rx/src/core/scheduler.dart';
import 'package:rx/src/core/subscription.dart';
import 'package:rx/src/testing/test_message.dart';

class HotObservable<T> with Observable<T> {
  final Scheduler scheduler;
  final List<TestMessage<T>> messages;

  HotObservable(this.scheduler, this.messages);

  @override
  Subscription subscribe(Observer<T> observer) => null;
}
