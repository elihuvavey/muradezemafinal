import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';


class DeveloperModeChecker {
  static const MethodChannel _channel = MethodChannel('app.security');

  /// Combined detection - returns true if ANY dev mode/debugging method triggers
  static Future<bool> isDevModeActive() async {
    if (!Platform.isAndroid) return false;
    try {
      final bool active = await _channel.invokeMethod('isDevModeActive');
      return active;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> isDeveloperOptionsEnabled() async {
    if (!Platform.isAndroid) return false;
    try {
      final bool enabled =
          await _channel.invokeMethod('isDeveloperOptionsEnabled');
      return enabled;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> isUsbDebuggingEnabled() async {
    if (!Platform.isAndroid) return false;
    try {
      final bool enabled = await _channel.invokeMethod('isUsbDebuggingEnabled');
      return enabled;
    } catch (_) {
      return false;
    }
  }

  static Future<void> openDeveloperOptions() async {
    if (!Platform.isAndroid) return;
    try {
      await _channel.invokeMethod('openDeveloperOptions');
    } catch (_) {}
  }

  static Future<bool> appIsDebuggable() async {
    if (!Platform.isAndroid) return false;
    try {
      final bool isDebug = await _channel.invokeMethod('appIsDebuggable');
      return isDebug;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> debuggerAttached() async {
    if (!Platform.isAndroid) return false;
    try {
      final bool attached = await _channel.invokeMethod('debuggerAttached');
      return attached;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> adbViaSysProp() async {
    if (!Platform.isAndroid) return false;
    try {
      final bool adb = await _channel.invokeMethod('adbViaSysProp');
      return adb;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> isDevSettingsPkgPresent() async {
    if (!Platform.isAndroid) return false;
    try {
      final bool present =
          await _channel.invokeMethod('isDevSettingsPkgPresent');
      return present;
    } catch (_) {
      return false;
    }
  }
}


class DevModeNavigatorObserver extends NavigatorObserver {
  DevModeNavigatorObserver({required this.onRouteEvent});
  final VoidCallback onRouteEvent;

  @override
  void didPush(Route route, Route? previousRoute) {
    onRouteEvent();
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    onRouteEvent();
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    onRouteEvent();
  }
}
