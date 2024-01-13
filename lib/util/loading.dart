import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class ProgressIndication {
  static void showProgressBar(BuildContext context, _animationcontroller) {
    showDialog(
      context: context,
      builder: (_) => SpinKitFadingCircle(
        color: Colors.black,
        size: 50,
        controller: _animationcontroller,
      ),
    );
  }
}
