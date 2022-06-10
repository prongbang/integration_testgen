import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

extension WidgetTesterExtension on WidgetTester {
  Future<void> pumpUntilFound(
    Finder finder, {
    Duration timeout = const Duration(seconds: 60),
  }) async {
    bool timerFound = false;
    final timer = Timer(
      timeout,
      () {
        throw TimeoutException("Pump until found has timed out.");
      },
    );
    while (timerFound != true) {
      await pump();
      final found = any(finder);
      if (found) {
        timerFound = true;
      }
    }
    timer.cancel();
  }

  Future<void> delay(int milliseconds) async {
    await Future.delayed(Duration(milliseconds: milliseconds));
  }
}
