import 'dart:math';

import 'package:meta/meta.dart';

import '../components/position_component.dart';
import 'effects.dart';

class CombinedEffect extends PositionComponentEffect {
  final List<PositionComponentEffect> effects;
  final double offset;

  CombinedEffect({
    @required this.effects,
    this.offset = 0.0,
    bool isInfinite = false,
    bool isAlternating = false,
    void Function() onComplete,
  }) : super(isInfinite, isAlternating, onComplete: onComplete) {
    assert(
      effects.every((effect) => effect.component == null),
      'Each effect can only be added once',
    );
    final types = effects.map((e) => e.runtimeType);
    assert(
      types.toSet().length == types.length,
      "All effect types have to be different so that they don't clash",
    );
  }

  @override
  void initialize(PositionComponent _comp) {
    super.initialize(_comp);
    effects.forEach((effect) {
      effect.initialize(_comp);
      final isSameSize = effect.endSize == _comp.size;
      final isSamePosition = effect.endPosition == _comp.position;
      final isSameAngle = effect.endAngle == _comp.angle;
      endSize = isSameSize ? endSize : effect.endSize;
      endPosition = isSamePosition ? endPosition : effect.endPosition;
      endAngle = isSameAngle ? endAngle : effect.endAngle;
      peakTime = max(peakTime ?? 0,
          effect.iterationTime + offset * effects.indexOf(effect));
    });
  }

  @override
  void update(double dt) {
    super.update(dt);
    effects.forEach((effect) => _updateEffect(effect, dt));
    if (effects.every((effect) => effect.hasFinished())) {
      if (isAlternating && curveDirection.isNegative) {
        effects.forEach((effect) => effect.isAlternating = true);
      }
    }
  }

  @override
  void reset() {
    super.reset();
    if (component != null) {
      component.position = originalPosition;
      component.angle = originalAngle;
      component.size = originalSize;
      initialize(component);
    }
    effects.forEach((effect) => effect.reset());
  }

  @override
  void dispose() {
    super.dispose();
    effects.forEach((effect) => effect.dispose());
  }

  void _updateEffect(PositionComponentEffect effect, double dt) {
    final isReverse = curveDirection.isNegative;
    final initialOffset = effects.indexOf(effect) * offset;
    final effectOffset = isReverse
        ? peakTime - effect.peakTime - initialOffset
        : initialOffset;
    final passedOffset = isReverse ? peakTime - currentTime : currentTime;
    if (!effect.hasFinished() && effectOffset < passedOffset) {
      final time =
          effectOffset < passedOffset - dt ? dt : passedOffset - effectOffset;
      effect.update(time);
    }
    if (isMax()) {
      _maybeReverse(effect);
    }
  }

  @override
  bool hasFinished() {
    return super.hasFinished() && effects.every((e) => e.hasFinished());
  }

  void _maybeReverse(PositionComponentEffect effect) {
    if (isAlternating && !effect.isAlternating && effect.isMax()) {
      // Make the effect go in reverse
      effect.isAlternating = true;
    }
  }
}
