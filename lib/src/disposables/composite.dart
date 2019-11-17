library rx.disposables.composite;

import 'disposable.dart';
import 'errors.dart';
import 'stateful.dart';

class CompositeDisposable extends StatefulDisposable {
  final Set<Disposable> _subscriptions = {};

  CompositeDisposable();

  CompositeDisposable.of(Iterable<Disposable> subscriptions) {
    subscriptions.forEach(add);
  }

  Set<Disposable> get subscriptions => {..._subscriptions};

  void add(Disposable subscription) {
    ArgumentError.checkNotNull(subscription, 'subscription');
    if (isDisposed) {
      subscription.dispose();
      return;
    }
    if (subscription.isDisposed) {
      return;
    }
    _subscriptions.add(subscription);
  }

  void remove(Disposable subscription) {
    ArgumentError.checkNotNull(subscription, 'subscription');
    if (_subscriptions.remove(subscription)) {
      subscription.dispose();
    }
  }

  @override
  void dispose() {
    if (isDisposed) {
      return;
    }
    final subscriptions = _subscriptions.toList();
    super.dispose();
    _subscriptions.clear();
    final errors = [];
    for (final subscription in subscriptions) {
      try {
        subscription.dispose();
      } catch (error) {
        errors.add(error);
      }
    }
    DisposeError.checkList(errors);
  }
}
