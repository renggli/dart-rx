library rx.subscriptions.serial;

import '../core/subscription.dart';
import 'stateful.dart';

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
    final current = subscription.isClosed ? subscription : Subscription.empty();
    final previous = _current;
    _current = current;
    previous.unsubscribe();
  }

  @override
  void unsubscribe() {
    if (isClosed) {
      return;
    }
    super.unsubscribe();
    final previous = _current;
    _current = Subscription.empty();
    previous.unsubscribe();
  }
}
