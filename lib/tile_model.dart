import 'package:flutter/material.dart';

class TileModel {
  final int x;
  final int y;
  int value;

  late Animation<double> animatedX;
  late Animation<double> animatedY;
  late Animation<int> animationValue;
  late Animation<double> scaleAnimation;

  TileModel({required this.x, required this.y, required this.value}) {
    resetAnimation();
  }

  void resetAnimation() {
    animatedX = AlwaysStoppedAnimation(x.toDouble());
    animatedY = AlwaysStoppedAnimation(y.toDouble());
    animationValue = AlwaysStoppedAnimation(value);
    scaleAnimation = const AlwaysStoppedAnimation(1.0);
  }

  void moveTo(Animation<double> parent, int x, int y) {
    animatedX = Tween(begin: this.x.toDouble(), end: x.toDouble()).animate(
      CurvedAnimation(
        parent: parent,
        curve: const Interval(
          0.0,
          1.0,
          curve: Curves.easeOut,
        ),
      ),
    );
    animatedY = Tween(begin: this.y.toDouble(), end: y.toDouble()).animate(
      CurvedAnimation(
        parent: parent,
        curve: const Interval(
          0.0,
          1.0,
          curve: Curves.easeOut,
        ),
      ),
    );
  }

  void bounce(Animation<double> parent) {
    scaleAnimation = TweenSequence([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.2),
        weight: 1.0,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.2, end: 1.0),
        weight: 1.0,
      ),
    ]).animate(
      CurvedAnimation(
        parent: parent,
        curve: const Interval(.5, 1.0),
      ),
    );
  }

  void appear(Animation<double> parent) {
    scaleAnimation = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: parent,
        curve: const Interval(.5, 1.0),
      ),
    );
  }

  void changeNumber(Animation<double> parent, int newValue) {
    animationValue = TweenSequence([
      TweenSequenceItem(
        tween: ConstantTween(value),
        weight: .01,
      ),
      TweenSequenceItem(
        tween: ConstantTween(value),
        weight: .99,
      ),
    ]).animate(
      CurvedAnimation(
        parent: parent,
        curve: const Interval(.5, 1.0),
      ),
    );
  }
}
