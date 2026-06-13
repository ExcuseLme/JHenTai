import 'package:flutter/material.dart';

/// 自定义滚动物理效果，根据配置的灵敏度放大滑动距离
class ScaledScrollPhysics extends ScrollPhysics {
  final double scaleFactor;

  const ScaledScrollPhysics({this.scaleFactor = 1.0, ScrollPhysics? parent})
      : super(parent: parent);

  @override
  double applyPhysicsToUserOffset(ScrollMetrics position, double offset) {
    return super.applyPhysicsToUserOffset(position, offset * scaleFactor);
  }

  @override
  ScaledScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return ScaledScrollPhysics(
      scaleFactor: scaleFactor,
      parent: buildParent(ancestor),
    );
  }
}
