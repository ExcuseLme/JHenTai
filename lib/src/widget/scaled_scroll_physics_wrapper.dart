import 'package:flutter/material.dart';
import 'package:jhentai/src/setting/preference_setting.dart';
import 'package:jhentai/src/widget/scaled_scroll_physics.dart';

/// 根据配置的灵敏度包装 ScrollPhysics
/// 如果灵敏度为 1.0，返回原始 physics
/// 否则返回包装后的 ScaledScrollPhysics
ScrollPhysics? wrapWithScaledPhysics(ScrollPhysics? physics) {
  double sensitivity = preferenceSetting.scrollSensitivity.value;
  if (sensitivity == 1.0) {
    return physics;
  }
  return ScaledScrollPhysics(scaleFactor: sensitivity).applyTo(physics);
}
