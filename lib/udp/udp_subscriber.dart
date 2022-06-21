import 'package:pycar_control/udp/udp_interface.dart';
import 'package:pycar_control/udp/udp_receiver.dart';

///udp 消息订阅
class UdpSubscriber extends OnDataArrivedListener {
  late final UdpListenCore _udpListenCore;
  final List<OnDataArrivedListener> _onDataArrivedListenerList =
      List.empty(growable: true);

  UdpSubscriber(this._udpListenCore) {
    _udpListenCore.onDataArrivedListener = this;
  }

  @override
  void onDataArrived(List<int> data, String host) {
    for (var onDataArrivedListener in _onDataArrivedListenerList) {
      onDataArrivedListener.onDataArrived(data, host);
    }
  }

  ///订阅消息回调
  void subscribeDataArrivedListener(
      OnDataArrivedListener onDataArrivedListener) {
    _onDataArrivedListenerList.add(onDataArrivedListener);
  }

  ///取消订阅
  ///return 还剩订阅数量
  int unsubscribeDataArrivedListener(
      OnDataArrivedListener onDataArrivedListener) {
    _onDataArrivedListenerList.remove(onDataArrivedListener);
    return _onDataArrivedListenerList.length;
  }

  ///关闭端口
  void close(){
    _udpListenCore.close();
  }
}
