import 'dart:io';

import 'package:pycar_control/udp/udp_config.dart';

/// udp 发送接口
abstract class UdpSender {
  ///设置发送目标地址
  ///param [host] 目标地址
  UdpSender setRemoteHost(String host);

  ///设置发送目标端口
  ///param [port] 目标端口
  UdpSender setPort(int port);

  ///发送数据
  ///param [data] 数据
  UdpSender send(List<int> data);

  ///发送udp广播
  ///param [data] 数据
  UdpSender sendBroadcast(List<int> data);
}

/// udp发送实例
class UdpSenderImpl extends UdpSender {
  ///广播地址
  final String _broadcastHost = "255.255.255.255";

  ///目标地址
  String _remoteHost = "127.0.0.1";

  ///默认端口
  int _port = UdpConfig.defaultListenPort;

  ///udp发送核心
  final UdpSenderCore _udpSenderCore = UdpSenderCore();

  @override
  UdpSender send(List<int> data) {
    _udpSenderCore.sendData(data, _remoteHost, _port);
    return this;
  }

  @override
  UdpSender sendBroadcast(List<int> data) {
    _udpSenderCore.sendData(data, _broadcastHost, _port);
    return this;
  }

  @override
  UdpSender setPort(int port) {
    _port = port;
    return this;
  }

  @override
  UdpSender setRemoteHost(String host) {
    _remoteHost = host;
    return this;
  }
}

class UdpSenderCore {
  late RawDatagramSocket _datagramSocket;
  InternetAddress? _address;

  UdpSenderCore() {
    RawDatagramSocket.bind(InternetAddress.anyIPv4, UdpConfig.defaultListenPort)
        .then((udpSocket) {
      udpSocket.broadcastEnabled = true;
      _datagramSocket = udpSocket;
    });
  }

  /// udp 发送数据
  /// param [data] 数据
  /// param [host] 目标地址
  /// param [port] 目标端口
  void sendData(List<int> data, String host, int port) async {
    InternetAddress address;
    if (_address?.host == host) {
      address = _address ?? _createAddress(host);
    } else {
      address = _createAddress(host);
    }
    _datagramSocket.send(data, address, port);
  }

  InternetAddress _createAddress(String host) {
    InternetAddress address = InternetAddress(host);
    _address = address;
    return address;
  }
}
