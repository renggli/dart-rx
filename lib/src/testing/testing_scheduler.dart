library rx.testing.test_scheduler;

import 'package:rx/core.dart';
import 'package:rx/src/core/observable.dart';
import 'package:rx/src/core/scheduler.dart';
import 'package:rx/src/testing/cold_observable.dart';
import 'package:rx/src/testing/hot_observable.dart';
import 'package:rx/src/testing/test_message.dart';

const advanceMarker = '-';
const completionMarker = '|';
const errorMarker = '#';
const groupEndMarker = ')';
const groupStartMarker = '(';
const whitespaceMarker = ' ';
const subscriptionMarker = '^';
const unsubscriptionMarker = '!';

class TestScheduler extends Scheduler {
  final List<TestAction> actions = [];

  final List<Observable> coldObservables = [];
  final List<Observable> hotObservables = [];

  TestScheduler();

  int _millis = 0;

  @override
  DateTime get now => DateTime.fromMillisecondsSinceEpoch(_millis);

  @override
  Subscription schedule(Callback callback) => null;

  @override
  Subscription scheduleIteration(IterationCallback callback) => null;

  @override
  Subscription scheduleTimeout(Duration duration, Callback callback) => null;

  @override
  Subscription schedulePeriodic(Duration duration, Callback callback) => null;

  int createTime(String marbles) {
    final completionIndex = marbles.indexOf(completionMarker);
    if (completionIndex < 0) {
      throw ArgumentError.value(
          marbles, 'Missing completion marker "$completionMarker".');
    }
    return completionIndex;
  }

  Observable<T> createColdObservable<T>(String marbles,
      {Map<String, T> values = const {}, Object error = 'Error'}) {
    if (marbles.contains(subscriptionMarker)) {
      throw ArgumentError.value(
          marbles, 'Unexpected subscription marker "$subscriptionMarker".');
    }
    if (marbles.contains(unsubscriptionMarker)) {
      throw ArgumentError.value(
          marbles, 'Unexpected unsubscription marker "$unsubscriptionMarker".');
    }
    final messages = _parseMarbles<T>(marbles, values, error);
    final observable = ColdObservable<T>(this, messages);
    coldObservables.add(observable);
    return observable;
  }

  Observable<T> createHotObservable<T>(String marbles,
      {Map<String, T> values = const {}, Object error = 'Error'}) {
    if (marbles.contains(unsubscriptionMarker)) {
      throw ArgumentError.value(
          marbles, 'Unexpected unsubscription marker "$unsubscriptionMarker".');
    }
    final messages = _parseMarbles<T>(marbles, values, error);
    final observable = HotObservable<T>(this, messages);
    hotObservables.add(observable);
    return observable;
  }

  List<TestMessage<T>> _parseMarbles<T>(
      String marbles, Map<String, T> values, Object error) {
    final messages = <TestMessage<T>>[];
    var frame = 0, group = -1;
    for (var i = 0; i < marbles.length; i++) {
      Notification<T> notification;
      switch (marbles[i]) {
        case whitespaceMarker:
          break;
        case advanceMarker:
          frame++;
          break;
        case groupStartMarker:
          group = frame;
          frame++;
          break;
        case groupEndMarker:
          group = -1;
          frame++;
          break;
        case errorMarker:
          notification = ErrorNotification<T>(error);
          frame++;
          break;
        case completionMarker:
          notification = CompleteNotification<T>();
          frame++;
          break;
        default:
          final value = values[marbles[i]] ?? marbles[i];
          notification = NextNotification<T>(value);
          frame++;
          break;
      }
      if (notification != null) {
        messages.add(TestMessage(group < 0 ? frame : group, notification));
      }
    }
    return messages;
  }
}

class TestAction<T> {}

//class TestAction<T> extends Subscription {
//  final TestScheduler scheduler;
//
//  TestAction(this.scheduler);
//}

// xport class TestScheduler extends VirtualTimeScheduler {
//  public readonly hotObservables: HotObservable<any>[] = [];
//  public readonly coldObservables: ColdObservable<any>[] = [];
//  private flushTests: FlushableTest[] = [];
//  private runMode = false;
//
//  constructor(public assertDeepEqual: (actual: any, expected: any) => boolean | void) {
//    super(VirtualAction, defaultMaxFrame);
//  }
//

//
//  private materializeInnerObservable(observable: Observable<any>,
//                                     outerFrame: number): TestMessage[] {
//    const messages: TestMessage[] = [];
//    observable.subscribe((value) => {
//      messages.push({ frame: this.frame - outerFrame, notification: Notification.createNext(value) });
//    }, (err) => {
//      messages.push({ frame: this.frame - outerFrame, notification: Notification.createError(err) });
//    }, () => {
//      messages.push({ frame: this.frame - outerFrame, notification: Notification.createComplete() });
//    });
//    return messages;
//  }
//
//  expectObservable(observable: Observable<any>,
//                   subscriptionMarbles: string = null): ({ toBe: observableToBeFn }) {
//    const actual: TestMessage[] = [];
//    const flushTest: FlushableTest = { actual, ready: false };
//    const subscriptionParsed = TestScheduler.parseMarblesAsSubscriptions(subscriptionMarbles, this.runMode);
//    const subscriptionFrame = subscriptionParsed.subscribedFrame === Number.POSITIVE_INFINITY ?
//      0 : subscriptionParsed.subscribedFrame;
//    const unsubscriptionFrame = subscriptionParsed.unsubscribedFrame;
//    let subscription: Subscription;
//
//    this.schedule(() => {
//      subscription = observable.subscribe(x => {
//        let value = x;
//        // Support Observable-of-Observables
//        if (x instanceof Observable) {
//          value = this.materializeInnerObservable(value, this.frame);
//        }
//        actual.push({ frame: this.frame, notification: Notification.createNext(value) });
//      }, (err) => {
//        actual.push({ frame: this.frame, notification: Notification.createError(err) });
//      }, () => {
//        actual.push({ frame: this.frame, notification: Notification.createComplete() });
//      });
//    }, subscriptionFrame);
//
//    if (unsubscriptionFrame !== Number.POSITIVE_INFINITY) {
//      this.schedule(() => subscription.unsubscribe(), unsubscriptionFrame);
//    }
//
//    this.flushTests.push(flushTest);
//    const { runMode } = this;
//
//    return {
//      toBe(marbles: string, values?: any, errorValue?: any) {
//        flushTest.ready = true;
//        flushTest.expected = TestScheduler.parseMarbles(marbles, values, errorValue, true, runMode);
//      }
//    };
//  }
//
//  expectSubscriptions(actualSubscriptionLogs: SubscriptionLog[]): ({ toBe: subscriptionLogsToBeFn }) {
//    const flushTest: FlushableTest = { actual: actualSubscriptionLogs, ready: false };
//    this.flushTests.push(flushTest);
//    const { runMode } = this;
//    return {
//      toBe(marbles: string | string[]) {
//        const marblesArray: string[] = (typeof marbles === 'string') ? [marbles] : marbles;
//        flushTest.ready = true;
//        flushTest.expected = marblesArray.map(marbles =>
//          TestScheduler.parseMarblesAsSubscriptions(marbles, runMode)
//        );
//      }
//    };
//  }
//
//  flush() {
//    const hotObservables = this.hotObservables;
//    while (hotObservables.length > 0) {
//      hotObservables.shift().setup();
//    }
//
//    super.flush();
//
//    this.flushTests = this.flushTests.filter(test => {
//      if (test.ready) {
//        this.assertDeepEqual(test.actual, test.expected);
//        return false;
//      }
//      return true;
//    });
//  }
//
//  /** @nocollapse */
//  static parseMarblesAsSubscriptions(marbles: string, runMode = false): SubscriptionLog {
//    if (typeof marbles !== 'string') {
//      return new SubscriptionLog(Number.POSITIVE_INFINITY);
//    }
//    const len = marbles.length;
//    let groupStart = -1;
//    let subscriptionFrame = Number.POSITIVE_INFINITY;
//    let unsubscriptionFrame = Number.POSITIVE_INFINITY;
//    let frame = 0;
//
//    for (let i = 0; i < len; i++) {
//      let nextFrame = frame;
//      const advanceFrameBy = (count: number) => {
//        nextFrame += count * this.frameTimeFactor;
//      };
//      const c = marbles[i];
//      switch (c) {
//        case ' ':
//          // Whitespace no longer advances time
//          if (!runMode) {
//            advanceFrameBy(1);
//          }
//          break;
//        case '-':
//          advanceFrameBy(1);
//          break;
//        case '(':
//          groupStart = frame;
//          advanceFrameBy(1);
//          break;
//        case ')':
//          groupStart = -1;
//          advanceFrameBy(1);
//          break;
//        case '^':
//          if (subscriptionFrame !== Number.POSITIVE_INFINITY) {
//            throw new Error('found a second subscription point \'^\' in a ' +
//              'subscription marble diagram. There can only be one.');
//          }
//          subscriptionFrame = groupStart > -1 ? groupStart : frame;
//          advanceFrameBy(1);
//          break;
//        case '!':
//          if (unsubscriptionFrame !== Number.POSITIVE_INFINITY) {
//            throw new Error('found a second subscription point \'^\' in a ' +
//              'subscription marble diagram. There can only be one.');
//          }
//          unsubscriptionFrame = groupStart > -1 ? groupStart : frame;
//          break;
//        default:
//          // time progression syntax
//          if (runMode && c.match(/^[0-9]$/)) {
//            // Time progression must be preceeded by at least one space
//            // if it's not at the beginning of the diagram
//            if (i === 0 || marbles[i - 1] === ' ') {
//              const buffer = marbles.slice(i);
//              const match = buffer.match(/^([0-9]+(?:\.[0-9]+)?)(ms|s|m) /);
//              if (match) {
//                i += match[0].length - 1;
//                const duration = parseFloat(match[1]);
//                const unit = match[2];
//                let durationInMs: number;
//
//                switch (unit) {
//                  case 'ms':
//                    durationInMs = duration;
//                    break;
//                  case 's':
//                    durationInMs = duration * 1000;
//                    break;
//                  case 'm':
//                    durationInMs = duration * 1000 * 60;
//                    break;
//                  default:
//                    break;
//                }
//
//                advanceFrameBy(durationInMs / this.frameTimeFactor);
//                break;
//              }
//            }
//          }
//
//          throw new Error('there can only be \'^\' and \'!\' markers in a ' +
//            'subscription marble diagram. Found instead \'' + c + '\'.');
//      }
//
//      frame = nextFrame;
//    }
//
//    if (unsubscriptionFrame < 0) {
//      return new SubscriptionLog(subscriptionFrame);
//    } else {
//      return new SubscriptionLog(subscriptionFrame, unsubscriptionFrame);
//    }
//  }
//
//  /** @nocollapse */
//  static parseMarbles(marbles: string,
//                      values?: any,
//                      errorValue?: any,
//                      materializeInnerObservables: boolean = false,
//                      runMode = false): TestMessage[] {
//    if (marbles.indexOf('!') !== -1) {
//      throw new Error('conventional marble diagrams cannot have the ' +
//        'unsubscription marker "!"');
//    }
//    const len = marbles.length;
//    const testMessages: TestMessage[] = [];
//    const subIndex = runMode ? marbles.replace(/^[ ]+/, '').indexOf('^') : marbles.indexOf('^');
//    let frame = subIndex === -1 ? 0 : (subIndex * -this.frameTimeFactor);
//    const getValue = typeof values !== 'object' ?
//      (x: any) => x :
//      (x: any) => {
//        // Support Observable-of-Observables
//        if (materializeInnerObservables && values[x] instanceof ColdObservable) {
//          return values[x].messages;
//        }
//        return values[x];
//      };
//    let groupStart = -1;
//
//    for (let i = 0; i < len; i++) {
//      let nextFrame = frame;
//      const advanceFrameBy = (count: number) => {
//        nextFrame += count * this.frameTimeFactor;
//      };
//
//      let notification: Notification<any>;
//      const c = marbles[i];
//      switch (c) {
//        case ' ':
//          // Whitespace no longer advances time
//          if (!runMode) {
//            advanceFrameBy(1);
//          }
//          break;
//        case '-':
//          advanceFrameBy(1);
//          break;
//        case '(':
//          groupStart = frame;
//          advanceFrameBy(1);
//          break;
//        case ')':
//          groupStart = -1;
//          advanceFrameBy(1);
//          break;
//        case '|':
//          notification = Notification.createComplete();
//          advanceFrameBy(1);
//          break;
//        case '^':
//          advanceFrameBy(1);
//          break;
//        case '#':
//          notification = Notification.createError(errorValue || 'error');
//          advanceFrameBy(1);
//          break;
//        default:
//          // Might be time progression syntax, or a value literal
//          if (runMode && c.match(/^[0-9]$/)) {
//            // Time progression must be preceeded by at least one space
//            // if it's not at the beginning of the diagram
//            if (i === 0 || marbles[i - 1] === ' ') {
//              const buffer = marbles.slice(i);
//              const match = buffer.match(/^([0-9]+(?:\.[0-9]+)?)(ms|s|m) /);
//              if (match) {
//                i += match[0].length - 1;
//                const duration = parseFloat(match[1]);
//                const unit = match[2];
//                let durationInMs: number;
//
//                switch (unit) {
//                  case 'ms':
//                    durationInMs = duration;
//                    break;
//                  case 's':
//                    durationInMs = duration * 1000;
//                    break;
//                  case 'm':
//                    durationInMs = duration * 1000 * 60;
//                    break;
//                  default:
//                    break;
//                }
//
//                advanceFrameBy(durationInMs / this.frameTimeFactor);
//                break;
//              }
//            }
//          }
//
//          notification = Notification.createNext(getValue(c));
//          advanceFrameBy(1);
//          break;
//      }
//
//      if (notification) {
//        testMessages.push({ frame: groupStart > -1 ? groupStart : frame, notification });
//      }
//
//      frame = nextFrame;
//    }
//    return testMessages;
//  }
//
//  run<T>(callback: (helpers: RunHelpers) => T): T {
//    const prevFrameTimeFactor = TestScheduler.frameTimeFactor;
//    const prevMaxFrames = this.maxFrames;
//
//    TestScheduler.frameTimeFactor = 1;
//    this.maxFrames = Number.POSITIVE_INFINITY;
//    this.runMode = true;
//    AsyncScheduler.delegate = this;
//
//    const helpers = {
//      cold: this.createColdObservable.bind(this),
//      hot: this.createHotObservable.bind(this),
//      flush: this.flush.bind(this),
//      expectObservable: this.expectObservable.bind(this),
//      expectSubscriptions: this.expectSubscriptions.bind(this),
//    };
//    try {
//      const ret = callback(helpers);
//      this.flush();
//      return ret;
//    } finally {
//      TestScheduler.frameTimeFactor = prevFrameTimeFactor;
//      this.maxFrames = prevMaxFrames;
//      this.runMode = false;
//      AsyncScheduler.delegate = undefined;
//    }
//  }
//}
