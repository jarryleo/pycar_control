import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:pycar_control/base/base_view_model.dart';
import 'package:pycar_control/udp/udp_frame.dart';
import 'package:pycar_control/udp/udp_interface.dart';
import 'package:pycar_control/udp/udp_sender.dart';

class CarViewModel extends BaseViewModel implements OnDataArrivedListener {
  /// 车辆连接状态
  bool _connectState = false;

  /// 车灯状态
  bool _lightState = false;

  /// 车速
  int _speed = 1023;

  /// 上次车辆发送的心跳时间
  int _heartbeatTime = 0;

  bool get lightState => _lightState;

  bool get connectState => _connectState;

  /// udp 框架
  final UdpFrame _udpFrame = UdpFrame();

  /// 广播发送器
  final UdpSender _broadcastSender = UdpFrame.getSender(null, 27890);

  /// udp 发送器
  late UdpSender? _sender;

  CarViewModel() {
    // 遥控器广播自己地址 循环1秒1次
    var data = utf8.encode("broadcast");
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      _broadcastSender.send(data);
      _connectState =
          DateTime.now().millisecondsSinceEpoch - _heartbeatTime < 1000;
      notifyListeners();
      return true;
    });

    //订阅小车消息，目前只有小车心跳消息
    _udpFrame.subscribe(17890, this);
  }

  /// 接收到小车发来的消息
  @override
  void onDataArrived(List<int> data, String host) {
    _sender ??= UdpFrame.getSender(host, 27890);
    var text = String.fromCharCodes(data);
    if (text == "heartbeat") {
      _heartbeatTime = DateTime.now().millisecondsSinceEpoch;
    }
  }

  /// 小车灯光开关切换
  void lightSwitch() {
    if (_lightState) {
      lightOff();
    } else {
      lightOn();
    }
  }

  /// 小车灯光开启
  void lightOn() {
    _lightState = true;
    _send("light_on");
  }

  /// 小车灯光关闭
  void lightOff() {
    _lightState = true;
    _send("light_off");
  }

  ///发送指令到小车
  void _send(String text) {
    var data = utf8.encode(text);
    if (kDebugMode) {
      print(data);
    }
    _sender?.send(data);
  }
}
