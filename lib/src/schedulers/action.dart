library rx.schedulers.action;

import 'package:rx/src/subscriptions/stateful.dart';

typedef SchedulerCallback = void Function();

typedef SchedulerCallbackWith = void Function(SchedulerAction);

abstract class SchedulerAction extends StatefulSubscription {
  factory SchedulerAction(Function callback) {
    if (callback is SchedulerCallback) {
      return SchedulerCallbackAction(callback);
    } else if (callback is SchedulerCallbackWith) {
      return SchedulerCallbackWithAction(callback);
    } else {
      throw ArgumentError.value(callback);
    }
  }

  SchedulerAction._();

  void run();
}

class SchedulerCallbackAction extends SchedulerAction {
  final SchedulerCallback _callback;

  SchedulerCallbackAction(this._callback) : super._();

  @override
  void run() {
    if (isClosed) {
      return;
    }
    _callback();
  }
}

class SchedulerCallbackWithAction extends SchedulerAction {
  final SchedulerCallbackWith _callback;

  SchedulerCallbackWithAction(this._callback) : super._();

  @override
  void run() {
    if (isClosed) {
      return;
    }
    _callback(this);
  }
}
