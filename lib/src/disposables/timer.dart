library rx.disposables.timer;

import 'dart:async' as async;

import 'disposable.dart';

class TimerDisposable extends Disposable {
  async.Timer _timer;

  TimerDisposable(this._timer);

  @override
  bool get isDisposed => _timer == null;

  @override
  void dispose() {
    if (_timer != null) {
      _timer.cancel();
      _timer = null;
    }
  }
}
