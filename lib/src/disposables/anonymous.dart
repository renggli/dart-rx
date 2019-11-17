library rx.disposables.anonymous;

import '../shared/functions.dart';
import 'errors.dart';
import 'stateful.dart';

class AnonymousDisposable extends StatefulDisposable {
  final CompleteCallback _unsubscribeAction;

  AnonymousDisposable(this._unsubscribeAction);

  @override
  void dispose() {
    if (isDisposed) {
      return;
    }
    super.dispose();
    try {
      _unsubscribeAction();
    } catch (exception) {
      throw DisposeError([exception]);
    }
  }
}
