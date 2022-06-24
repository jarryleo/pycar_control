import 'dart:collection';

import 'package:pycar_control/udp/udp_interface.dart';
import 'package:pycar_control/udp/udp_receiver.dart';
import 'package:pycar_control/udp/udp_sender.dart';
import 'package:pycar_control/udp/udp_subscriber.dart';

class UdpFrame extends UdpInterface {
  static final UdpSender _udpSender = UdpSenderImpl();
  static final HashMap<int, UdpSubscriber> _subscribeMap = HashMap();
  static final HashMap<OnDataArrivedListener, int> _portMap = HashMap();

  UdpFrame();

  @override
  void subscribe(int port, OnDataArrivedListener onDataArrivedListener) {
    if (_subscribeMap.containsKey(port)) {
      var udpSubscriber = _subscribeMap[port];
      udpSubscriber?.subscribeDataArrivedListener(onDataArrivedListener);
    } else {
      var udpListenCore = UdpListenCore(port);
      var udpSubscriber = UdpSubscriber(udpListenCore);
      udpSubscriber.subscribeDataArrivedListener(onDataArrivedListener);
      _subscribeMap[port] = udpSubscriber;
    }
    _portMap[onDataArrivedListener] = port;
  }

  @override
  void unSubscribe(OnDataArrivedListener onDataArrivedListener) {
    var port = _portMap[onDataArrivedListener];
    if (port == null) return;
    var udpSubscriber = _subscribeMap[port];
    var size =
        udpSubscriber?.unsubscribeDataArrivedListener(onDataArrivedListener) ??
            0;
    if (size <= 0) {
      closePort(port);
      _subscribeMap.remove(port);
      _portMap.remove(onDataArrivedListener);
    }
  }

  @override
  void closePort(int port) {
    var udpSubscriber = _subscribeMap[port];
    udpSubscriber?.close();
  }

  static UdpSender getSender({String? host, int? port}) {
    if (port == null) return _udpSender;
    var sender = UdpSenderImpl().setPort(port);
    if (host != null) sender.setRemoteHost(host);
    return sender;
  }
}
