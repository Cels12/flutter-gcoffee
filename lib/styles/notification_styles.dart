import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

void showToast(
  BuildContext context, {
  required String title,
  required String message,
  // ignore: non_constant_identifier_names
  ToastificationType Type = ToastificationType.info,
}) {
  toastification.show(
    context: context,
    title: Text(title),
    description: Text(message),
    type: Type,
    autoCloseDuration: Duration(seconds: 3),
    alignment: Alignment.topRight,
    style: ToastificationStyle.fillColored,
    primaryColor: _getToastColor(Type),
    icon: _getToastIcon(Type),
  );
}

Color _getToastColor(ToastificationType type) {
  switch (type) {
    case ToastificationType.success:
      return Colors.green;
    case ToastificationType.error:
      return Colors.red;
    case ToastificationType.warning:
      return Colors.yellow;
    case ToastificationType.info:
    default:
      return Colors.blue;
  }
}

Icon _getToastIcon(ToastificationType type) {
  switch (type) {
    case ToastificationType.success:
      return Icon(Icons.check, color: Colors.white);
    case ToastificationType.error:
      return Icon(Icons.error, color: Colors.white);
    case ToastificationType.warning:
      return Icon(Icons.warning, color: Colors.white);
    case ToastificationType.info:
    default:
      return Icon(Icons.info, color: Colors.white);
  }
}
