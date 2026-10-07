import 'package:cupertino_native_better/cupertino_native_better.dart';
import 'package:flutter/widgets.dart';

/// App-wide toast helper.
///
/// Always anchors to the **bottom** so content stays clear of the Dynamic Island
/// / notch and sits above the Liquid Glass tab bar.
abstract final class AppToast {
  static const _position = CNToastPosition.bottom;

  static void show(
    BuildContext context,
    String message, {
    CNToastStyle style = CNToastStyle.normal,
  }) {
    CNToast.show(
      context: context,
      message: message,
      style: style,
      position: _position,
    );
  }

  static void success(BuildContext context, String message) {
    CNToast.success(
      context: context,
      message: message,
      position: _position,
    );
  }

  static void error(BuildContext context, String message) {
    CNToast.error(
      context: context,
      message: message,
      position: _position,
    );
  }

  static void info(BuildContext context, String message) {
    CNToast.info(
      context: context,
      message: message,
      position: _position,
    );
  }
}
