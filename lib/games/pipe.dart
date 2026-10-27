import 'package:flutter/material.dart';

class Pipe {
  static const double width = 56.0;
  static const double gap = 138.0;

  double x;
  final double topHeight;
  bool isPassed = false;

  Pipe({required this.x, required this.topHeight});

  void update(double dt, double speed) {
    x -= speed * dt;
  }

  Rect topRect() {
    return Rect.fromLTWH(x, 0, width, topHeight);
  }

  Rect bottomRect(double groundY) {
    final bottomY = topHeight + gap;
    return Rect.fromLTWH(x, bottomY, width, groundY - bottomY);
  }

  bool collidesWith(Rect birdBox, double groundY) {
    // Top pipe collision
    final top = topRect();
    if (birdBox.overlaps(top)) return true;

    // Bottom pipe collision
    final bottom = bottomRect(groundY);
    if (birdBox.overlaps(bottom)) return true;

    return false;
  }
}
