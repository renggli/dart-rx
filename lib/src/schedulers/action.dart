library rx.schedulers.action;

import '../disposables/stateful.dart';
import '../shared/functions.dart';

abstract class SchedulerAction extends StatefulDisposable {
  void run();
}

class SchedulerActionCallback extends SchedulerAction {
  final Callback0 _callback;

  SchedulerActionCallback(this._callback);

  @override
  void run() {
    if (isDisposed) {
      return;
    }
    _callback();
  }
}

class SchedulerActionCallbackWith extends SchedulerAction {
  final Callback1<SchedulerAction> _callback;

  SchedulerActionCallbackWith(this._callback);

  @override
  void run() {
    if (isDisposed) {
      return;
    }
    _callback(this);
  }
}
