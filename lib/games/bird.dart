import 'dart:math' as math;
import 'package:flutter/material.dart';

class Bird {
  static const double radiusX = 17.0;
  static const double radiusY = 13.0;
  static const double gravity = 880.0;
  static const double jumpImpulse = -290.0;
  static const double maxFallSpeed = 480.0;

  double x = 85.0;
  double y = 280.0;
  double vy = 0.0;
  double rotation = 0.0;

  double idleTimer = 0.0;
  double wingTimer = 0.0;
  int wingState = 1; // 0: up, 1: mid, 2: down

  void reset(double startY) {
    x = 85.0;
    y = startY;
    vy = 0.0;
    rotation = 0.0;
    idleTimer = 0.0;
    wingTimer = 0.0;
    wingState = 1;
  }

  void jump() {
    vy = jumpImpulse;
    wingState = 0;
  }

  void updateIdle(double dt) {
    idleTimer += dt * 4.0;
    y = 270.0 + math.sin(idleTimer) * 9.0;
    rotation = 0.0;
    updateWings(dt * 2.0);
  }

  void update(double dt) {
    vy += gravity * dt;
    if (vy > maxFallSpeed) vy = maxFallSpeed;
    y += vy * dt;

    // Angle rotation: -25 deg when rising, up to +75 deg diving down
    if (vy < 0) {
      rotation = (vy / 300.0) * (math.pi / 7.0);
      if (rotation < -math.pi / 7.0) rotation = -math.pi / 7.0;
    } else {
      rotation = (vy / maxFallSpeed) * (math.pi / 2.3);
      if (rotation > math.pi / 2.3) rotation = math.pi / 2.3;
    }

    updateWings(dt);
  }

  void updateWings(double dt) {
    wingTimer += dt * 10.0;
    if (wingTimer > 1.0) {
      wingTimer = 0.0;
      wingState = (wingState + 1) % 3;
    }
  }

  Rect get hitBox => Rect.fromCenter(
    center: Offset(x, y),
    width: radiusX * 1.7,
    height: radiusY * 1.6,
  );
}
