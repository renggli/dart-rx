library rx.subscriptions.composite;

import 'package:rx/src/core/subscription.dart';
import 'package:rx/src/subscriptions/stateful.dart';

import 'stateful.dart';

class CompositeSubscription extends StatefulSubscription {
  List<Subscription> _subscriptions = [];

  CompositeSubscription();

  void add(Subscription subscription) {
    if (isClosed) {
      subscription.unsubscribe();
      return;
    }
    _subscriptions.add(subscription);
  }

  void remove(Subscription subscription) {
    if (_subscriptions.remove(subscription)) {
      subscription.unsubscribe();
    }
  }

  @override
  void unsubscribe() {
    if (isClosed) {
      return;
    }
    final subscriptions = _subscriptions;
    super.unsubscribe();
    _subscriptions = [];
    for (final subscription in subscriptions) {
      subscription.unsubscribe();
    }
  }
}
