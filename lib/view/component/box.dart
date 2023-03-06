import 'package:flutter/material.dart';


class MyRoundedBox extends StatelessWidget {
  final double? width;
  final double? height;
  final Color? color;
  final Color? shadowColor;
  final Color? surfaceTintColor;
  final double? elevation;
  final Color? borderColor;
  final double? borderWidth;
  final double? borderRadius;
  final Widget? child;

  const MyRoundedBox({
    Key? key,
    this.width,
    this.height,
    this.color,
    this.shadowColor,
    this.surfaceTintColor,
    this.elevation,
    this.borderColor,
    this.borderWidth,
    this.borderRadius,
    this.child
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final CardTheme cardTheme = CardTheme.of(context);

    return SizedBox(
      width: width,
      height: height,
      child: Material(
        type: MaterialType.card,
        color: color ?? cardTheme.color,
        shadowColor: shadowColor ?? cardTheme.shadowColor,
        surfaceTintColor: surfaceTintColor ?? cardTheme.surfaceTintColor,
        elevation: elevation ?? cardTheme.elevation ?? 0,
        shape: RoundedRectangleBorder(
          side: BorderSide(
            color: borderColor ?? Colors.white,
            width: borderWidth ?? 0,
          ),
          borderRadius: BorderRadius.circular(borderRadius ?? 0),
        ),
        child: child,
      ),
    );
  }
}