import 'package:flutter/material.dart';
import 'package:speakean/constant.dart';


class MyDialog extends StatelessWidget {
  final double? width;
  final double? height;
  final Widget? child;

  const MyDialog({
    Key? key,
    this.width,
    this.height,
    this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      content: SizedBox(
        width: width ?? myDialogContentWidth,
        height: height,
        child: child,
      ),
    );
  }
}


class MyLogoDialog extends StatelessWidget {
  final double? width;
  final double? height;
  final Widget? child;

  const MyLogoDialog({
    Key? key,
    this.width,
    this.height,
    this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MyDialog(
      width: width,
      height: height,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Image.asset(
              "images/common/logo.png",
              width: 40,
            ),
          ),
          if(child != null) child!,
        ],
      ),
    );
  }
}

