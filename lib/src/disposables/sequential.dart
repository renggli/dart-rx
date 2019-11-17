library rx.disposables.serial;

import 'disposable.dart';
import 'stateful.dart';

class SequentialDisposable extends StatefulDisposable {
  Disposable _current = Disposable.empty();

  SequentialDisposable();

  Disposable get current => _current;

  set current(Disposable subscription) {
    ArgumentError.checkNotNull(subscription, 'subscription');
    if (isDisposed) {
      subscription.dispose();
      return;
    }
    final current = subscription.isDisposed ? Disposable.empty() : subscription;
    final previous = _current;
    _current = current;
    previous.dispose();
  }

  @override
  void dispose() {
    if (isDisposed) {
      return;
    }
    super.dispose();
    final previous = _current;
    _current = Disposable.empty();
    previous.dispose();
  }
}
