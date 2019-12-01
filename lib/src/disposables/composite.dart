library rx.disposables.composite;

import 'disposable.dart';
import 'errors.dart';
import 'stateful.dart';

/// A [Disposable] container that holds other disposables.
class CompositeDisposable extends StatefulDisposable {
  final Set<Disposable> _disposables = Set.identity();

  CompositeDisposable([Iterable<Disposable> disposables]) : super() {
    if (disposables != null && disposables.isNotEmpty) {
      disposables.forEach(add);
    }
  }

  Set<Disposable> get disposables => {..._disposables};

  void add(Disposable disposable) {
    ArgumentError.checkNotNull(disposable, 'disposable');
    if (isDisposed) {
      disposable.dispose();
      return;
    }
    if (disposable.isDisposed) {
      return;
    }
    _disposables.add(disposable);
  }

  void remove(Disposable disposable) {
    ArgumentError.checkNotNull(disposable, 'disposable');
    if (isDisposed) {
      return;
    }
    if (_disposables.remove(disposable)) {
      disposable.dispose();
    }
  }

  @override
  void dispose() {
    if (isDisposed) {
      return;
    }
    final disposables = _disposables.toList();
    super.dispose();
    _disposables.clear();
    final errors = [];
    for (final disposable in disposables) {
      try {
        disposable.dispose();
      } catch (error) {
        errors.add(error);
      }
    }
    DisposeError.checkList(errors);
  }
}