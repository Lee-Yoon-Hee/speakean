import 'dart:math';

import 'package:flutter/material.dart';


class MyProgressbar extends StatelessWidget {
  final double height;
  final double min;
  final double max;
  final double value;
  final double barPadding;
  final double borderRadius;
  final Gradient barGradient;

  const MyProgressbar({
    Key? key,
    required this.height,
    required this.min,
    required this.max,
    required this.value,
    required this.barPadding,
    required this.borderRadius,
    required this.barGradient,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        color: Colors.white,
      ),
      child: Padding(
        padding: EdgeInsets.all(barPadding),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: LayoutBuilder(
            builder: (context1, constraints) {
              return Stack(

                children: [
                  Positioned(
                    top: 0,
                    bottom: 0,
                    width: constraints.maxWidth * ((value - min) / (max - min)),
                    child: Container(
                      width: constraints.maxWidth,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(borderRadius),
                        gradient: barGradient,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}


class MyCircularProgressbar extends StatelessWidget {
  final double min;
  final double max;
  final double value;
  final double thickness;
  final Color backgroundColor;
  final Color color;

  const MyCircularProgressbar({
    Key? key,
    required this.min,
    required this.max,
    required this.value,
    this.thickness = 4,
    required this.backgroundColor,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context1, constraints) {
        final width = constraints.maxWidth;

        return Stack(
          fit: StackFit.passthrough,
          alignment: Alignment.center,
          children: [
            Padding(
              padding: EdgeInsets.all(width / 10),
              child: Transform.rotate(
                alignment: Alignment.center,
                angle: pi * 2 / 3,
                child: CircularProgressIndicator(
                  value: value / (max - min),
                  strokeWidth: thickness,
                  backgroundColor: backgroundColor,
                  color: color,
                ),
              ),
            ),
            Center(
              child: Text(
                (value / (max - min) * 100).toStringAsFixed(0),
                style: TextStyle(
                  color: color,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Positioned(
              left: width * 0.64,
              top : width * 0.64,
              width: width / 3,
              height: width / 3,
              child: Container(
                decoration: const ShapeDecoration(
                  shape: CircleBorder(),
                  color: Colors.white,
                ),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: FittedBox(
                      fit: BoxFit.fitWidth,
                      child: Text(
                        "%",
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}







// class MyProgressBar extends StatefulWidget {
//   final double? width;
//   final double borderRadius;
//   final double borderWidth;
//   final double height;
//   final double value;
//   final double min;
//   final double max;
//   final int loopCount;
//   final Gradient? trackGradient;
//   final Color? trackColor;
//   final Gradient? thumbGradient;
//   final Color? thumbColor;
//   final double padding;
//
//   const MyProgressBar({
//     Key? key,
//     this.width,
//     required this.borderRadius,
//     required this.height,
//     required this.value,
//     required this.min,
//     required this.max,
//     required this.loopCount,
//     this.borderWidth = 0,
//     this.trackGradient,
//     this.trackColor,
//     this.thumbGradient,
//     this.thumbColor,
//     this.padding = 0,
//   }) : super(key: key);
//
//   @override
//   State<MyProgressBar> createState() => _MyProgressBarState();
// }
//
// class _MyProgressBarState extends State<MyProgressBar> with SingleTickerProviderStateMixin {
//   late double _endValue;
//   late AnimationController _animationController;
//   bool _isAnimationControllerDisposed = false;
//   int _loopCount = 0;
//   double _width = 0;
//
//   late final double _minus;
//   late final double _minus2;
//
//   void initState() {
//     super.initState();
//     _endValue =  (widget.value - widget.min) / (widget.max - widget.min);
//     _animationController = AnimationController(
//       duration: const Duration(seconds: 1),
//       vsync: this,
//     );
//     _minus = widget.borderWidth + widget.padding;
//     _minus2 = _minus * 2;
//
//     _animationController.addListener(() {
//       setState(() {
//         _width = _animationController.value;
//       });
//     });
//
//     _animationController.addStatusListener((status) async {
//       if(status == AnimationStatus.completed) {
//         await Future.delayed(const Duration(milliseconds: 300));
//
//         if(_isAnimationControllerDisposed) {
//           return; // dispose된 controller에 접근하지 못하도록 함
//         }
//
//         if(_loopCount < widget.loopCount) {
//           _animationController.forward(from: 0);
//         } else if(_loopCount == widget.loopCount) {
//           _animationController.value = 0;
//           _animationController.animateTo(_endValue);
//         }
//
//         _loopCount++;
//       }
//     });
//
//     _animationController.animateTo(0);
//   }
//
//   void dispose() {
//     _animationController.dispose();
//     _isAnimationControllerDisposed = true;
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: widget.width,
//       height: widget.height,
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(widget.borderRadius),
//         border: widget.borderWidth == 0 ? null : Border.all(
//           color: Colors.black,
//           width: widget.borderWidth,
//         ),
//         gradient: widget.trackGradient,
//         color: widget.trackColor,
//       ),
//       child: LayoutBuilder(
//         builder: (context1, constraints) {
//           final width = constraints.maxWidth;
//
//           return Padding(
//             padding: EdgeInsets.all(widget.padding),
//             child: ClipRRect(
//               borderRadius: BorderRadius.circular(widget.borderRadius - _minus),
//               child: SizedBox(
//                 width: width - _minus2,
//                 height: widget.height - _minus2,
//                 child: Stack(
//                   children: [
//                     Positioned(
//                       left: (width - _minus2) * (_width - 1/* 길이 아님; screenutil 적용x */),
//                       top: 0,
//                       child: Container(
//                         width: (width - _minus2),
//                         height: widget.height - _minus2,
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(widget.borderRadius - _minus),
//                           gradient: widget.thumbGradient,
//                           color: widget.thumbColor,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
//
