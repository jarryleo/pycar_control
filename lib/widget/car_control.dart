import 'dart:math';

import 'package:flutter/material.dart';

enum CarState {
  idle, //停止，空闲
  forward, //前进
  backward, //后退
  turnLeft, //左转
  turnRight //右转
}

class Car extends StatefulWidget {
  const Car({Key? key, required this.stateCallback}) : super(key: key);

  final Function(CarState state) stateCallback;

  @override
  State<StatefulWidget> createState() => _CarState();
}

class _CarState extends State<Car> {
  CarState _state = CarState.idle;
  Offset _offset = Offset.zero;
  double _angel = 0.0;

  //指令回调
  void _setCarState(CarState state){
    if(state == _state) return; //去重
    _state = state;
    widget.stateCallback(_state);
  }

  //图片平移
  void _changeOffset(Offset offset) {
    setState(() {
      _offset = offset;
    });
  }
  
  //图片旋转
  void _rotate(angel){
    setState((){
      _angel = angel;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 240,
      height: 360,
      child: Listener(
        onPointerMove: (event) {
          var delta = event.delta;
          if(delta.distance < 5) return;
          var direction = delta.direction;
          if (direction < -pi/4 && direction > -pi* 3/4) {
            _setCarState(CarState.forward);
            _changeOffset(const Offset(0, -30));
            _rotate(2*pi);
          } else if (direction < pi* 3/4 && direction > pi/4) {
            _setCarState(CarState.backward);
            _changeOffset(const Offset(0, 30));
            _rotate(2*pi);
          }else if (direction < pi/4 && direction > -pi/4) {
            _setCarState(CarState.turnRight);
            _rotate(pi/9);
            _changeOffset(Offset.zero);
          }else if (direction < -pi*3/4 || direction > pi * 3/4) {
            _setCarState(CarState.turnLeft);
            _rotate(-pi/9);
            _changeOffset(Offset.zero);
          }
        },
        onPointerUp: (event) {
          _setCarState(CarState.idle);
          _changeOffset(Offset.zero);
          _rotate(2*pi);
        },
        child: Transform.translate(
          offset: _offset,
          child: Transform.rotate(
            angle: _angel,
            child: Image.asset(
              "images/car.jpg",
              width: 200,
              height: 300,
            ),
          ),
        ),
      ),
    );
  }
}
