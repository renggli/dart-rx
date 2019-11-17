library rx.disposables.emtpy;

import 'disposable.dart';

class EmptyDisposable implements Disposable {
  const EmptyDisposable();

  @override
  bool get isDisposed => true;

  @override
  void dispose() {}
}
