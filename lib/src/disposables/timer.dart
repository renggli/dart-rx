import 'dart:async';

import 'reference.dart';

class TimerDisposable extends ReferenceDisposable<Timer> {
  TimerDisposable(super.value);

  @override
  void onDispose(Timer value) => value.cancel();
}
