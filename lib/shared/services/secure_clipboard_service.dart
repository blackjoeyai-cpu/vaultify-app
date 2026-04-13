import 'dart:async';
import 'package:flutter/services.dart';

class SecureClipboardService {
  static Timer? _clearTimer;
  static const _defaultClearDelay = 30;

  static Future<void> copyWithAutoClear(
    String text, {
    int clearAfterSeconds = _defaultClearDelay,
  }) async {
    await Clipboard.setData(ClipboardData(text: text));
  }

  static Future<void> copyWithAutoClearSetting(
    String text,
    bool autoClearEnabled, {
    int clearAfterSeconds = _defaultClearDelay,
  }) async {
    await Clipboard.setData(ClipboardData(text: text));

    if (autoClearEnabled) {
      _scheduleClear(clearAfterSeconds);
    }
  }

  static void _scheduleClear(int seconds) {
    _clearTimer?.cancel();
    _clearTimer = Timer(Duration(seconds: seconds), () async {
      await clearClipboard();
    });
  }

  static Future<void> clearClipboard() async {
    await Clipboard.setData(const ClipboardData(text: ''));
  }

  static void dispose() {
    _clearTimer?.cancel();
    _clearTimer = null;
  }
}
