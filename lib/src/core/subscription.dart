library rx.core.subscription;

import 'package:rx/src/shared/functions.dart';
import 'package:rx/src/subscriptions/anonymous.dart';
import 'package:rx/src/subscriptions/composite.dart';
import 'package:rx/src/subscriptions/empty.dart';
import 'package:rx/src/subscriptions/sequential.dart';
import 'package:rx/src/subscriptions/stateful.dart';

abstract class Subscription {
  const Subscription();

  /// Creates a [Subscription] for the provided teardown logic.
  factory Subscription.of(Object tearDownLogic) {
    if (tearDownLogic == null) {
      return Subscription.empty();
    } else if (tearDownLogic is CompleteCallback) {
      return Subscription.create(tearDownLogic);
    } else if (tearDownLogic is Subscription) {
      return tearDownLogic;
    } else {
      throw ArgumentError.value('tearDownLogic', tearDownLogic);
    }
  }

  /// Creates a [Subscription] that invokes the specified action when
  /// unsubscribed.
  factory Subscription.create(CompleteCallback unsubscribeAction) =>
      AnonymousSubscription(unsubscribeAction);

  /// Creates a [Subscription] that is already closed.
  factory Subscription.empty() => const EmptySubscription();

  /// Creates a [Subscription] that can be closed.
  factory Subscription.stateful() => StatefulSubscription();

  /// Creates a [CompositeSubscription] that aggregates over multiple other
  /// subscriptions.
  static CompositeSubscription composite() => CompositeSubscription();

  /// Creates a [SequentialSubscription] that holds onto a single other
  /// subscription.
  static SequentialSubscription sequential() => SequentialSubscription();

  /// Returns true, if this [Subscription] is no longer active.
  bool get isClosed;

  /// Disposes the resources held by this [Subscription].
  void unsubscribe();
}
