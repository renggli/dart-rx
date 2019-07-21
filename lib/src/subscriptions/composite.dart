library rx.subscriptions.composite;

import 'package:rx/core.dart';
import 'package:rx/src/core/errors.dart';
import 'package:rx/src/core/subscription.dart';
import 'package:rx/src/subscriptions/stateful.dart';

import 'stateful.dart';

class CompositeSubscription extends StatefulSubscription {
  final Set<Subscription> _subscriptions = {};

  CompositeSubscription();

  Set<Subscription> get subscriptions => {..._subscriptions};

  void add(Subscription subscription) {
    ArgumentError.checkNotNull(subscription, 'subscription');
    if (isClosed) {
      subscription.unsubscribe();
      return;
    }
    if (subscription.isClosed) {
      return;
    }
    _subscriptions.add(subscription);
  }

  void remove(Subscription subscription) {
    ArgumentError.checkNotNull(subscription, 'subscription');
    if (_subscriptions.remove(subscription)) {
      subscription.unsubscribe();
    }
  }

  @override
  void unsubscribe() {
    if (isClosed) {
      return;
    }
    final subscriptions = _subscriptions.toList();
    super.unsubscribe();
    _subscriptions.clear();
    final errors = [];
    for (final subscription in subscriptions) {
      try {
        subscription.unsubscribe();
      } catch (error) {
        errors.add(error);
      }
    }
    UnsubscriptionError.checkList(errors);
  }
}
