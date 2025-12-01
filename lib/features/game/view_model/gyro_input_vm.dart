import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:my_2048_game/features/game/model/board.dart'; // for Direction

class GyroInputViewModel extends ChangeNotifier {
  final double tiltThreshold; // tune this
  final Duration cooldown;    // delay between moves
  final double calibrationTolerance; // tolerance for considering device as "initial" position
  double? _initialX;
  double? _initialY;

  StreamSubscription<GyroscopeEvent>? _subscription;
  DateTime _lastMoveTime = DateTime.fromMillisecondsSinceEpoch(0);
  Direction? _lastDirection;

  GyroInputViewModel({
    this.tiltThreshold = 0.8,          // adjust via trial & error
    this.calibrationTolerance = 2.2,   // adjust via trial & error
    this.cooldown = const Duration(milliseconds: 400),
  });

  Direction? get lastDirection => _lastDirection;

  void start() {
    _subscription?.cancel();

    _subscription = gyroscopeEvents.listen((event) {
      if (_initialX == null || _initialY == null) {
        // Not calibrated yet.
        _initialX = event.x;
        _initialY = event.y;
      }
      _handleGyroEvent(event);
    });
  }

  void stop() {
    _subscription?.cancel();
    _subscription = null;
  }

  void _handleGyroEvent(GyroscopeEvent event) {
    final now = DateTime.now();
    if (now.difference(_lastMoveTime) < cooldown) {
      return; // avoid spamming moves
    }

    final x = event.x;
    final y = event.y;

    if ( (x - (_initialX ?? 0)).abs() < calibrationTolerance &&
         (y - (_initialY ?? 0)).abs() < calibrationTolerance) {
      // Device is close to initial position, ignore.
      return;
    }

    Direction? dir;

    // Heuristic: depending on device axis, you might have to swap or invert these.
    if (x.abs() > y.abs()) {
      // horizontal tilt
      if (x > tiltThreshold) {
        dir = Direction.down;
      } else if (x < -tiltThreshold) {
        dir = Direction.up;
      }
    } else {
      // vertical tilt
      if (y > tiltThreshold) {
        dir = Direction.right;
      } else if (y < -tiltThreshold) {
        dir = Direction.left;
      }
    }

    if (dir != null) {
      _lastDirection = dir;
      _lastMoveTime = now;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    stop();
    super.dispose();
  }
}

