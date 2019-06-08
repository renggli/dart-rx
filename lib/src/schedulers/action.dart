library rx.schedulers.action;

import 'package:rx/src/subscriptions/stateful.dart';

abstract class SchedulerAction extends StatefulSubscription {
  void run();
}

class SchedulerActionCallback extends SchedulerAction {
  final void Function() _callback;

  SchedulerActionCallback(this._callback);

  @override
  void run() {
    if (isClosed) {
      return;
    }
    _callback();
  }
}

class SchedulerActionCallbackWith extends SchedulerAction {
  final void Function(SchedulerAction action) _callback;

  SchedulerActionCallbackWith(this._callback);

  @override
  void run() {
    if (isClosed) {
      return;
    }
    _callback(this);
  }
}
