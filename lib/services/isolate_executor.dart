import 'dart:isolate';
import 'package:flutter/foundation.dart';

class IsolateExecutor {
  static Future<R> run<R, A>(R Function(A) fn, A arg) async {
    if (kIsWeb) {
      return fn(arg);
    }
    
    try {
      return await Isolate.run(() => fn(arg));
    } catch (e) {
      return compute(fn, arg);
    }
  }

  static Future<R> execute<R>(R Function() fn) async {
    if (kIsWeb) {
      return fn();
    }
    
    try {
      return await Isolate.run(fn);
    } catch (e) {
      return fn();
    }
  }
}

class IsolateTask<T, R> {
  final R Function(T) task;
  
  const IsolateTask(this.task);
  
  Future<R> run(T argument) async {
    return IsolateExecutor.run(task, argument);
  }
}
