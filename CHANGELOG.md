# Changelog

## 0.4.0

- Addg `Subject.isObserved` (thanks to [tsouza](https://github.com/tsouza)).
- Add "inclusive" option to `Observable.takeWhile` (thanks to [tsouza](https://github.com/tsouza)).

## 0.3.0

- Dart 3.0 requirement.
- Make `Event` and `TestEvent` sealed classes.
- Fix bug in finalize operator (thanks to [tsouza](https://github.com/tsouza)).
- Add pairwise operator (thanks to [tsouza](https://github.com/tsouza)).

## 0.2.0

- Dart 2.17 requirement.
- Add a redux like store, and example.
- Add `race` constructor.
- Add `takeUntil` and `skipUntil` operators.
- Move assertions earlier when possible.
- Improved testing infrastructure, and test coverage.

## 0.1.3

- Dart 2.14 requirement.

## 0.1.2

- Dart 2.13 requirement.
- Various typing improvements and optimizations.

## 0.1.0

- Dart 2.12 requirement and null-safety.

## 0.0.8

- `catchError` is now properly typed by the exception.

## 0.0.7

- Cleanup action callback code.
- StackTrace is always optional.
- Improve documentation.

## 0.0.6

- Reworked or added time based operators: `audit`, `debounce`, `throttle`, and `sample`.

## 0.0.5

- Renamed Subscription to Disposable.
- Countless simplifications and optimizations.
- Better tests for async scheduler.

## 0.0.4

- Operators as static extension methods.
- More operators, converters, and constructors.

## 0.0.3

- Subject and multicast basics.

## 0.0.2

- Operator and composition basics.

## 0.0.1

- Initial version.
