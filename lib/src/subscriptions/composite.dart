library rx.subscriptions.composite;

import 'package:rx/core.dart';
import 'package:rx/src/core/subscription.dart';
import 'package:rx/src/subscriptions/stateful.dart';

import 'stateful.dart';

class CompositeSubscription extends StatefulSubscription {
  List<Subscription> _subscriptions = [];

  CompositeSubscription();

  List<Subscription> get subscriptions => [..._subscriptions];

  void add(Subscription subscription) {
    if (subscription.isClosed) {
      return;
    }
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
    final errors = [];
    for (final subscription in subscriptions) {
      try {
        subscription.unsubscribe();
      } catch (error) {
        errors.add(error);
      }
    }
    if (errors.isNotEmpty) {
      throw errors.first;
    }
  }
}
