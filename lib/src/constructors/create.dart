library rx.constructors.create;

import 'package:rx/src/core/observable.dart';

/// Creates an observable sequence from a specified subscribe method
/// implementation.
Observable<T> create<T>(SubscribeFunction<T> subscribeFunction) =>
    SubscribeObservable<T>(subscribeFunction);
