library rx.schedulers.action;

import 'package:rx/src/core/functions.dart';
import 'package:rx/src/subscriptions/stateful.dart';

abstract class SchedulerAction extends StatefulSubscription {
  void run();
}

class SchedulerActionCallback extends SchedulerAction {
  final Map0<void> _callback;

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
  final Map1<SchedulerAction, void> _callback;

  SchedulerActionCallbackWith(this._callback);

  @override
  void run() {
    if (isClosed) {
      return;
    }
    _callback(this);
  }
}
