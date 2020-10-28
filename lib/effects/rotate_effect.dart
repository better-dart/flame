import 'package:flutter/animation.dart';
import 'package:meta/meta.dart';

import 'effects.dart';

class RotateEffect extends SimplePositionComponentEffect {
  double angle;
  double _startAngle;
  double _delta;

  RotateEffect({
    @required this.angle, // As many radians as you want to rotate
    double duration, // How long it should take for completion
    double speed, // The speed of rotation in radians/s
    Curve curve,
    bool isInfinite = false,
    bool isAlternating = false,
    bool isRelative = false,
    void Function() onComplete,
  })  : assert(duration != null || speed != null),
        super(
          isInfinite,
          isAlternating,
          duration: duration,
          speed: speed,
          curve: curve,
          isRelative: isRelative,
          onComplete: onComplete,
        );

  @override
  void initialize(_comp) {
    super.initialize(_comp);
    if (!isAlternating) {
      endAngle = _comp.angle + angle;
    }
    _startAngle = component.angle;
    _delta = isRelative ? angle : angle - _startAngle;
    speed ??= _delta / duration;
    duration ??= _delta / speed;
    travelTime = duration;
  }

  @override
  void update(double dt) {
    super.update(dt);
    component.angle = _startAngle + _delta * curveProgress;
  }
}
