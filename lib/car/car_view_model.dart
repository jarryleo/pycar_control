import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:pycar_control/base/base_view_model.dart';
import 'package:pycar_control/udp/udp_config.dart';
import 'package:udp/udp.dart';

import '../widget/car_control.dart';

class CarViewModel extends BaseViewModel {
  /// 车辆连接状态
  bool _connectState = false;

  /// 车灯状态
  bool _lightState = false;

  /// 车速
  int _speed = 1023;

  ///超声波测距
  double _distance = 0.0;

  /// 上次车辆发送的心跳时间
  int _heartbeatTime = 0;

  bool get lightState => _lightState;

  bool get connectState => _connectState;

  int get speed => _speed;

  /// udp 对象
  UDP? _udp;

  ///接收地址
  final _endpoint = Endpoint.loopback(
      port: const Port(UdpConfig.defaultPort));

  ///小车ip地址
  InternetAddress? _carAddress;

  CarViewModel() {
    Future.sync(() => init());
  }

  void init() async {
    //udp
    _udp = await UDP.bind(_endpoint);
    //订阅小车消息
    _udp?.asStream().listen((datagram) {
      if (datagram != null) {
        onDataArrived(datagram);
      }
    });
    //检测小车连接状态
    checkCarConnectState();
  }

  ///检测小车连接状态
  void checkCarConnectState() async {
    //计时器循环发送组播
    Timer.periodic(const Duration(seconds: 1), (timer) async {
      //更新连接状态(1.5秒没有数据表示小车断开连接)
      _connectState =
          DateTime.now().millisecondsSinceEpoch - _heartbeatTime < 1500;
      notifyListeners();
    });
  }

  /// 接收到小车发来的消息
  void onDataArrived(Datagram dg) async {
    _carAddress ??= dg.address;
    //如果是已经连接，并且新接受的地址不是已连接地址，抛弃数据
    if (_connectState) {
      if (_carAddress?.host != dg.address.host) {
        return;
      }
    } else {
      //如果已断开连接，则接收新的地址数据
      _carAddress = dg.address;
    }
    var text = String.fromCharCodes(dg.data);
    if (kDebugMode) {
      print("onDataArrived:$text");
      _heartbeatTime = DateTime.now().millisecondsSinceEpoch;
    }
    if (text.startsWith('car')) {
      //更新心跳时间
      _heartbeatTime = DateTime.now().millisecondsSinceEpoch;
      //获取雷达距离
      var distanceText = text.split(":")[1];
      _distance = double.parse(distanceText);
      notifyListeners();
      //防前方碰撞 前方障碍小于10 cm 小车停止前进
      if (_distance > 0 && _distance <10 ){
        stop();
      }
    }
  }

  ///小车状态改变
  void changeState(CarState state) {
    switch (state) {
      case CarState.idle:
        stop();
        break;
      case CarState.forward:
        forward();
        break;
      case CarState.backward:
        backward();
        break;
      case CarState.turnLeft:
        turnLeft();
        break;
      case CarState.turnRight:
        turnRight();
        break;
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
      //发送消息到小车
      var carEndpoint = Endpoint.unicast(_carAddress,
          port: const Port(UdpConfig.defaultPort));
      _udp?.send(data, carEndpoint);
    }
  }

  @override
  void dispose() {
    _udp?.close();
    super.dispose();
  }
}
