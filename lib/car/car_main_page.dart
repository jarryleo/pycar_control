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
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          head(),
          const Spacer(flex: 2),
          arrow(),
          const Spacer(),
        ],
      ),
    );
  }

  /// 连接状态，车速，车灯
  Widget head() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        //小车连接状态指示灯
        Consumer<CarViewModel>(builder: (context, model, child) {
          return onlineState(model.connectState);
        }),
        //车速进度条
        Consumer<CarViewModel>(builder: (context, model, child) {
          return Expanded(
              child: Slider(
                  value: model.speed.toDouble(),
                  min: 512.0,
                  max: 1023.0,
                  label: "speed: ${model.speed}",
                  onChangeEnd: (value) => model.setSpeed(value.toInt(), true),
                  onChanged: (value) => model.setSpeed(value.toInt())));
        }),
        //车灯按钮
        Consumer<CarViewModel>(builder: (context, model, child) {
          return IconButton(
              icon: Icon(
                model.lightState ? Icons.lightbulb : Icons.lightbulb_outline,
                color: Colors.blue,
                size: 30,
              ),
              onPressed: () => model.lightSwitch());
        })
      ],
    );
  }

  /// 车子方向键
  Widget arrow() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
                icon: const Icon(
                  Icons.arrow_upward,
                  color: Colors.blue,
                  size: 30,
                ),
                onPressed: () => viewModel.forward()),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.blue,
                  size: 30,
                ),
                onPressed: () => viewModel.turnLeft()),
            IconButton(
                icon: const Icon(
                  Icons.stop,
                  color: Colors.blue,
                  size: 30,
                ),
                onPressed: () => viewModel.stop()),
            IconButton(
                icon: const Icon(
                  Icons.arrow_forward,
                  color: Colors.blue,
                  size: 30,
                ),
                onPressed: () => viewModel.turnRight()),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
                icon: const Icon(
                  Icons.arrow_downward,
                  color: Colors.blue,
                  size: 30,
                ),
                onPressed: () => viewModel.backward()),
          ],
        ),
      ],
    );
  }
}
