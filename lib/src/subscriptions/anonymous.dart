library rx.subscriptions.anonymous;

import 'package:rx/src/subscriptions/stateful.dart';

typedef UnsubscribeAction = void Function();

class AnonymousSubscription extends StatefulSubscription {
  final UnsubscribeAction _unsubscribeAction;

  AnonymousSubscription(this._unsubscribeAction);

  @override
  void unsubscribe() {
    if (isClosed) {
      return;
    }
    super.unsubscribe();
    _unsubscribeAction();
  }
}
