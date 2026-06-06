import 'package:flutter/services.dart';
import 'dart:io' show Platform;

class ScreenshotService {
  static const _channel = MethodChannel('murihpay/screenshot');

  static Future<void> enableProtection() async {
    if (!Platform.isAndroid) return;
    try {
      await _channel.invokeMethod('enableScreenshotProtection');
    } catch (_) {}
  }

  static Future<void> disableProtection() async {
    if (!Platform.isAndroid) return;
    try {
      await _channel.invokeMethod('disableScreenshotProtection');
    } catch (_) {}
  }
}
