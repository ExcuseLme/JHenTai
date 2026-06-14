import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

/// 自定义滚动物理效果，根据配置的灵敏度放大滑动距离
/// 同时支持拖动和惯性滚动（fling）
class ScaledScrollPhysics extends ScrollPhysics {
  final double scaleFactor;

  const ScaledScrollPhysics({this.scaleFactor = 1.0, ScrollPhysics? parent})
      : super(parent: parent);

  @override
  double applyPhysicsToUserOffset(ScrollMetrics position, double offset) {
    // 放大用户拖动的偏移量
    return super.applyPhysicsToUserOffset(position, offset * scaleFactor);
  }

  @override
  Simulation? createBallisticSimulation(ScrollMetrics position, double velocity) {
    // 放大 fling 速度
    return super.createBallisticSimulation(position, velocity * scaleFactor);
  }

  @override
  ScaledScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return ScaledScrollPhysics(
      scaleFactor: scaleFactor,
      parent: buildParent(ancestor),
    );
  }
}
