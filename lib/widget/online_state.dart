import 'package:flutter/material.dart';

///小车连接状态
Widget onlineState(bool isOnline) {
  return Container(
    width: 20,
    height: 20,
    alignment: Alignment.center,
    decoration: ShapeDecoration(
        color: isOnline ? Colors.green : Colors.red,
        shape: const CircleBorder()),
  );
}
