library rx.core.subscription;

import '../shared/functions.dart';
import 'anonymous.dart';
import 'composite.dart';
import 'empty.dart';
import 'sequential.dart';
import 'stateful.dart';

/// A disposable resource.
abstract class Disposable {
  const Disposable();

  /// Creates a [Disposable] for the provided teardown logic.
  factory Disposable.of(Object tearDownLogic) {
    if (tearDownLogic == null) {
      return Disposable.empty();
    } else if (tearDownLogic is CompleteCallback) {
      return Disposable.create(tearDownLogic);
    } else if (tearDownLogic is Disposable) {
      return tearDownLogic;
    } else {
      throw ArgumentError.value('tearDownLogic', tearDownLogic);
    }
  }

  /// Creates a [Disposable] that invokes the specified action when
  /// unsubscribed.
  factory Disposable.create(CompleteCallback unsubscribeAction) =>
      AnonymousDisposable(unsubscribeAction);

  /// Creates a [Disposable] that is already closed.
  factory Disposable.empty() => const EmptyDisposable();

  /// Creates a [Disposable] that can be closed.
  factory Disposable.stateful() => StatefulDisposable();

  /// Creates a [CompositeDisposable] that aggregates over multiple other
  /// subscriptions.
  static CompositeDisposable composite(
          [Iterable<Disposable> subscriptions = const []]) =>
      CompositeDisposable.of(subscriptions);

  /// Creates a [SequentialDisposable] that holds onto a single other
  /// subscription.
  static SequentialDisposable sequential() => SequentialDisposable();

  /// Disposes the resource.
  void dispose();

  /// Returns true, if this resource has been disposed.
  bool get isDisposed;
}
