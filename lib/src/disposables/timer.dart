import 'dart:async';

import 'reference.dart';

class TimerDisposable extends ReferenceDisposable<Timer> {
  TimerDisposable(Timer value) : super(value);

  @override
  void onDispose(Timer value) => value.cancel();
}
