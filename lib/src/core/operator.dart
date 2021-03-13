import '../disposables/disposable.dart';
import 'observable.dart';
import 'subscriber.dart';

typedef Operator<T, R> = Disposable Function(
    Observable<T> source, Subscriber<R> subscriber);
