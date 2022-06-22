import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pycar_control/base/base_page.dart';
import 'package:pycar_control/car/car_view_model.dart';
import 'package:pycar_control/widget/online_state.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MainPageState();
}

class _MainPageState extends BasePage<MainPage, CarViewModel> {
  @override
  createViewModel() => CarViewModel();

  @override
  Widget contentView(BuildContext context) {
    return Row(
      children: [
        //小车连接状态指示灯
        Consumer<CarViewModel>(builder: (context, model, child) {
          return onlineState(model.connectState);
        }),
        //车速进度条

      ],
    );
  }
}
