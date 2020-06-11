library rx.schedulers.action;

import 'package:meta/meta.dart';

import '../disposables/stateful.dart';
import '../shared/functions.dart';

abstract class SchedulerAction extends StatefulDisposable {
  @nonVirtual
  void run() {
    if (isDisposed) {
      return;
    }
    doRun();
  }

  @protected
  void doRun();
}

class SchedulerActionCallback0 extends SchedulerAction {
  final Callback0 callback;

  SchedulerActionCallback0(this.callback);

  @override
  void doRun() => callback();
}

class SchedulerActionCallback1 extends SchedulerAction {
  final Callback1<SchedulerAction> callback;

  SchedulerActionCallback1(this.callback);

  @override
  void doRun() => callback(this);
}
