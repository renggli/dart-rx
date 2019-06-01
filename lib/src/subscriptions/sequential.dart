library rx.subscriptions.serial;

import 'package:rx/src/core/subscription.dart';
import 'package:rx/src/subscriptions/stateful.dart';

class SequentialSubscription extends StatefulSubscription {
  Subscription _current;

  SequentialSubscription([Subscription current]) {
    this.current = current;
  }

  Subscription get current => _current;

  set current(Subscription subscription) {
    if (isClosed) {
      if (subscription != null) {
        subscription.unsubscribe();
      }
      return;
    }
    final previous = _current;
    _current = subscription;
    if (previous != null) {
      previous.unsubscribe();
    }
  }

  @override
  void unsubscribe() {
    if (isClosed) {
      return;
    }
    final previous = _current;
    super.unsubscribe();
    _current = null;
    if (previous != null) {
      previous.unsubscribe();
    }
  }
}
