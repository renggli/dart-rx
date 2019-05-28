library rx.core.subject;

import 'observable.dart';
import 'observer.dart';

abstract class Subject<T, S> implements Observer<T>, Observable<S> {}
