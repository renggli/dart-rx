library rx.subscriptions.serial;

import 'package:rx/src/core/subscription.dart';
import 'package:rx/src/subscriptions/stateful.dart';

class SequentialSubscription extends StatefulSubscription {
  Subscription _current = Subscription.empty();

  SequentialSubscription();

  Subscription get current => _current;

  set current(Subscription subscription) {
    ArgumentError.checkNotNull(subscription, 'subscription');
    if (isClosed) {
      subscription.unsubscribe();
      return;
    }
    if (subscription.isClosed) {
      subscription = Subscription.empty();
    }
    final previous = _current;
    _current = subscription;
    previous.unsubscribe();
  }

  @override
  void unsubscribe() {
    super.unsubscribe();
    final previous = _current;
    _current = Subscription.empty();
    previous.unsubscribe();
  }
}
