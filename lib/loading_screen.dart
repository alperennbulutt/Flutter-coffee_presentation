import 'package:flutter/material.dart';
import 'package:loading_animations/loading_animations.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({
    Key key,
    @required Size size,
  })  : _size = size,
        super(key: key);

  final Size _size;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          child: Center(
            child: LoadingBouncingGrid.circle(
              borderColor: Colors.blue,
              borderSize: 5.0,
              size: _size.height * 0.08,
            ),
          ),
        ),
      ),
    );
  }
}
