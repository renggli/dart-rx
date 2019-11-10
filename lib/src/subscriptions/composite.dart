library rx.subscriptions.composite;

import '../core/errors.dart';
import '../core/subscription.dart';
import 'stateful.dart';

class CompositeSubscription extends StatefulSubscription {
  final Set<Subscription> _subscriptions = {};

  CompositeSubscription();

  CompositeSubscription.of(Iterable<Subscription> subscriptions) {
    subscriptions.forEach(add);
  }

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
