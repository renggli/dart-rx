Reactive Dart 
=============

[![Pub Package](https://img.shields.io/pub/v/rx.svg)](https://pub.dartlang.org/packages/rx)
[![Build Status](https://travis-ci.org/renggli/dart-rx.svg)](https://travis-ci.org/renggli/dart-rx)
[![Coverage Status](https://coveralls.io/repos/renggli/dart-rx/badge.svg)](https://coveralls.io/r/renggli/dart-rx)
[![GitHub Issues](https://img.shields.io/github/issues/renggli/dart-rx.svg)](https://github.com/renggli/dart-rx/issues)
[![GitHub Forks](https://img.shields.io/github/forks/renggli/dart-rx.svg)](https://github.com/renggli/dart-rx/network)
[![GitHub Stars](https://img.shields.io/github/stars/renggli/dart-rx.svg)](https://github.com/renggli/dart-rx/stargazers)
[![GitHub License](https://img.shields.io/badge/license-MIT-blue.svg)](https://raw.githubusercontent.com/renggli/dart-rx/master/LICENSE)

Reactive Extensions Library for Dart providing an API for asynchronous programming with observable streams.

Reactive is created in the style of [ReactiveX](http://reactivex.io/), and does not depend on Dart Streams. At this point this code is quite experimental, and might miss features or have serious bugs.

This library is open source and well tested. Development happens on [GitHub](http://github.com/renggli/dart-rx). Feel free to report issues or create a pull-request there. General questions are best asked on [StackOverflow](http://stackoverflow.com/questions/tagged/rx+dart).

The package is hosted on [dart packages](https://pub.dartlang.org/packages/rx). Up-to-date [class documentation](https://pub.dartlang.org/documentation/rx/latest/) is created with every release.

Currently the Dart programming language (or my inability to use it correctly) is blocking a more pleasant API in a few places:

- The lack of extension methods in Dart makes it awkward to access operator functions and constructor methods: dart-lang/language#40, dart-lang/language#41, dart-lang/language#42, dart-lang/language#177, dart-lang/language#309, dart-lang/language#8547.
- For some reason type inference over chained operators does not work. For example `observable.pipe2(filter(()) => ...), map(() => ...))` is unable to correctly infer the types in the second operator, while `observable.pipe(filter() => ...).pipe(map(() => ...)` does.
- The lack of variable length arguments and generics requires duplicated functions and typedefs with a number suffix (see above).

### License

The MIT License, see [LICENSE](https://github.com/renggli/dart-rx/raw/master/LICENSE).