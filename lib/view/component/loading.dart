import 'package:flutter/material.dart';

import 'color.dart';


class MyCircularLoading extends StatefulWidget {
  final double? size;
  final double strokeWidth;
  final List<Color> colors;

  MyCircularLoading({Key? key, double? strokeWidth, this.size, required List<Color> colors}) :
        strokeWidth = strokeWidth ?? 2,
        colors = [...colors, colors.first],
        super(key: key);

  @override
  State<MyCircularLoading> createState() => _MyCircularLoadingState();
}

class _MyCircularLoadingState extends State<MyCircularLoading> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 1, milliseconds: 500));
    _controller.repeat(reverse: true);
  }

  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: CircularProgressIndicator(
        strokeWidth: widget.strokeWidth,
        valueColor: TweenSequence(
          [
            for(int i = 0, len = widget.colors.length - 1; i < len; i++) TweenSequenceItem(
              tween: ColorTween(
                begin: widget.colors[i],
                end: widget.colors[i + 1],
              ),
              weight: 1,
            ),
          ],
        ).animate(_controller),
      ),
    );
  }
}

class MyDefaultCircularLoading extends StatelessWidget {
  final double? size;
  final double? strokeWidth;

  const MyDefaultCircularLoading({Key? key, this.size, this.strokeWidth}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MyCircularLoading(
      size: size,
      strokeWidth: strokeWidth,
      colors: const [
        MyColor.purple, MyColor.sky, MyColor.purpleOnSky,
      ],
    );
  }
}


