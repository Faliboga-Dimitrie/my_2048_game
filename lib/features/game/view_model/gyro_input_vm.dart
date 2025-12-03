import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:my_2048_game/features/game/model/board.dart'; // Direction

class GyroInputViewModel extends ChangeNotifier {
  final double tiltThreshold;
  final Duration cooldown;

  StreamSubscription<GyroscopeEvent>? _subscription;
  DateTime _lastMoveTime = DateTime.fromMillisecondsSinceEpoch(0);
  Direction? _lastDirection;

  GyroInputViewModel({
    this.tiltThreshold = 0.8,
    this.cooldown = const Duration(milliseconds: 400),
  });

  Direction? get lastDirection => _lastDirection;

  void start() {
    _subscription?.cancel();
    _subscription = gyroscopeEvents.listen(_handleGyroEvent);
  }

  void stop() {
    _subscription?.cancel();
    _subscription = null;
  }

  void _handleGyroEvent(GyroscopeEvent event) {
    final now = DateTime.now();

    // Global cooldown so we don't spam moves
    if (now.difference(_lastMoveTime) < cooldown) {
      return;
    }

    final x = event.x;
    final y = event.y;

    Direction? dir;

    // Decide dominant axis
    if (x.abs() > y.abs()) {
      // "vertical" motion: up/down
      if (x > tiltThreshold) {
        dir = Direction.down;
      } else if (x < -tiltThreshold) {
        dir = Direction.up;
      }
    } else {
      // "horizontal" motion: left/right
      if (y > tiltThreshold) {
        dir = Direction.right;
      } else if (y < -tiltThreshold) {
        dir = Direction.left;
      }
    }

    if (dir == null) return;

    // Optional additional protection:
    // ignore immediate opposite direction if it's likely "coming back"
    if (_lastDirection != null) {
      final isOpposite = _isOpposite(dir, _lastDirection!);
      if (isOpposite) {
        // Require a stronger tilt for the opposite move
        final strongTilt = (x.abs() > tiltThreshold * 1.5) ||
                           (y.abs() > tiltThreshold * 1.5);
        if (!strongTilt) {
          return;
        }
      }
    }

    _lastDirection = dir;
    _lastMoveTime = now;
    notifyListeners();
  }

  bool _isOpposite(Direction a, Direction b) {
    return (a == Direction.left && b == Direction.right) ||
           (a == Direction.right && b == Direction.left) ||
           (a == Direction.up && b == Direction.down) ||
           (a == Direction.down && b == Direction.up);
  }

  @override
  void dispose() {
    stop();
    super.dispose();
  }
}
