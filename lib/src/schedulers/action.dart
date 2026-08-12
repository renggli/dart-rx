import 'package:meta/meta.dart';
import 'package:more/functional.dart';

import '../disposables/stateful.dart';

abstract class SchedulerAction extends StatefulDisposable {
  @nonVirtual
  void run() {
    if (isDisposed) return;
    doRun();
  }

  @protected
  void doRun();
}

class SchedulerActionCallback0 extends SchedulerAction {
  new(this.callback);

  final Callback0 callback;

  @override
  void doRun() => callback();
}

class SchedulerActionCallback1 extends SchedulerAction {
  new(this.callback);

  final Callback1<SchedulerAction> callback;

  @override
  void doRun() => callback(this);
}
