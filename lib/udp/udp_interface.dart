///udp 接收数据回调
abstract class OnDataArrivedListener {
  void onDataArrived(List<int> data, String host);
}

///udp 方法封装
abstract class UdpInterface {
  /// 订阅监听端口
  /// param [port] 订阅端口号
  /// param [onDataArrivedListener] 数据回调
  void subscribe(int port, OnDataArrivedListener onDataArrivedListener);

  /// 关闭端口
  /// param [port] 端口号
  void closePort(int port);

  /// 取消端口的订阅监听
  /// param [onDataArrivedListener] 订阅的端口回调
  void unSubscribe(OnDataArrivedListener onDataArrivedListener);
}
