import 'package:more/functional.dart';

import 'disposable.dart';
import 'reference.dart';

/// A [Disposable] with a callback that is called exactly once on disposal.
class ActionDisposable extends ReferenceDisposable<Callback0> {
  ActionDisposable(super.callback);

  @override
  void onDispose(Callback0 value) => value();
}
