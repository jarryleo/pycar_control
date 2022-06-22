import 'dart:io';

import 'package:pycar_control/udp/udp_interface.dart';

/// udp 订阅接收核心
class UdpListenCore {
  late final int _port;
  late RawDatagramSocket? _datagramSocket;
  OnDataArrivedListener? _onDataArrivedListener;

  UdpListenCore(this._port) {
    _listen();
  }

  set onDataArrivedListener(OnDataArrivedListener listener) {
    _onDataArrivedListener = listener;
  }

  void _listen() async {
    RawDatagramSocket.bind(InternetAddress.anyIPv4, _port).then((udpSocket) {
      _datagramSocket = udpSocket;
      udpSocket.listen((event) {
        Datagram? datagram = udpSocket.receive();
        if (datagram != null) {
          List<int> data = datagram.data;
          _onDataArrivedListener?.onDataArrived(data, datagram.address.host);
        }
      });
    });
  }

  void close() {
    _datagramSocket?.close();
  }
}
