import 'package:flutter/material.dart';
import 'package:pycar_control/base/base_page.dart';
import 'package:pycar_control/car/car_view_model.dart';

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

    );
  }
}
