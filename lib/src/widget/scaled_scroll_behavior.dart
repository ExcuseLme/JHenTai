import 'package:flutter/material.dart';
import 'package:jhentai/src/widget/scaled_scroll_physics.dart';

/// 自定义滚动行为，根据配置的灵敏度放大滑动距离
class ScaledScrollBehavior extends MaterialScrollBehavior {
  final double scaleFactor;

  const ScaledScrollBehavior({this.scaleFactor = 1.0});

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return ScaledScrollPhysics(scaleFactor: scaleFactor);
  }
}
