import 'dart:async';

import 'reference.dart';

class TimerDisposable extends ReferenceDisposable<Timer> {
  new(super.value);

  @override
  void onDispose(Timer value) => value.cancel();
}
