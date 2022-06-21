import 'package:pycar_control/base/base_view_model.dart';

class CarViewModel extends BaseViewModel {
  /// 车灯状态
  bool _lightState = false;

  bool get lightState => _lightState;
}
