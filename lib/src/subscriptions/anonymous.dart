library rx.subscriptions.anonymous;

import 'package:rx/src/core/errors.dart';
import 'package:rx/src/shared/functions.dart';
import 'package:rx/src/subscriptions/stateful.dart';

class AnonymousSubscription extends StatefulSubscription {
  final CompleteCallback _unsubscribeAction;

  AnonymousSubscription(this._unsubscribeAction);

  @override
  void unsubscribe() {
    if (isClosed) {
      return;
    }
    super.unsubscribe();
    try {
      _unsubscribeAction();
    } catch (exception) {
      throw UnsubscriptionError([exception]);
    }
  }
}
