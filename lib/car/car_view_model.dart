import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:pycar_control/base/base_view_model.dart';
import 'package:pycar_control/udp/udp_config.dart';
import 'package:udp/udp.dart';

class CarViewModel extends BaseViewModel {
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

  int get speed => _speed;

  /// udp 发送器
  UDP? _sender;

  /// udp 接收器
  UDP? _receiver;

  ///小车ip地址
  InternetAddress? _carAddress;

  CarViewModel() {
    Future.sync(() => init());
  }

  void init() async {
    //消息发送器
    _sender = await UDP.bind(Endpoint.any());
    //小车消息接收器
    _receiver = await UDP
        .bind(Endpoint.loopback(port: const Port(UdpConfig.carListenPort)));
    //订阅小车消息，目前只有小车心跳消息
    _receiver
        ?.asStream(timeout: const Duration(seconds: 30))
        .listen((datagram) {
      if (datagram != null) {
        onDataArrived(datagram);
      }
    });
    //发送广播
    sendBroadcast();
  }

  ///发送广播，告知小车遥控器地址
  void sendBroadcast() async {
    // 遥控器广播自己地址 循环1秒1次
    var data = utf8.encode("broadcast");
    //计时器循环发送广播
    Timer.periodic(const Duration(seconds: 1), (timer) async {
      _sender?.send(
          data, Endpoint.broadcast(port: const Port(UdpConfig.broadcastPort)));
      _connectState =
          DateTime.now().millisecondsSinceEpoch - _heartbeatTime < 1000;
      notifyListeners();
    });
  }

  /// 接收到小车发来的消息
  void onDataArrived(Datagram dg) async {
    _carAddress = dg.address;
    var text = String.fromCharCodes(dg.data);
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
    notifyListeners();
    _send("light_on");
  }

  /// 小车灯光关闭
  void lightOff() {
    _lightState = false;
    notifyListeners();
    _send("light_off");
  }

  ///设置车速
  void setSpeed(int speed, [bool send = false]) {
    _speed = speed;
    notifyListeners();
    if (send) {
      _send("speed$speed");
    }
  }

  ///前进
  void forward() {
    _send("forward");
  }

  ///后退
  void backward() {
    _send("backward");
  }

  ///左转
  void turnLeft() {
    _send("turn_left");
  }

  ///右转
  void turnRight() {
    _send("turn_right");
  }

  ///停止
  void stop() {
    _send("stop");
  }

  ///发送指令到小车
  void _send(String text) {
    if (kDebugMode) {
      print(text);
    }
    var data = utf8.encode(text);
    if (_carAddress != null) {
      //异步发送消息到小车
      Future.sync(() => (){
        _sender?.send(
            data,
            Endpoint.unicast(_carAddress,
                port: const Port(UdpConfig.carListenPort)));
      });
    }
  }
}
