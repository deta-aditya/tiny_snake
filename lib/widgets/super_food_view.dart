import 'package:flutter/material.dart';

import '../model/position.dart';

class SuperFoodView extends StatelessWidget {
  static const double positionModifier = 0.25;
  static const double sizeModifier = 1.5;

  const SuperFoodView({
    Key? key,
    required this.position,
    required this.unitSize,
  }) : super(key: key);

  final Position position;
  final int unitSize;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: position.top.toDouble() * unitSize - positionModifier,
      left: position.left.toDouble() * unitSize - positionModifier,
      child: CustomPaint(
        size: Size(
          unitSize.toDouble() * sizeModifier,
          unitSize.toDouble() * sizeModifier,
        ),
        painter: SuperFoodPainter(),
      ),
    );
  }
}

class SuperFoodPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Colors.brown[300]!, Colors.brown[800]!],
    ).createShader(rect);

    final paint = Paint()
      ..strokeWidth = 1
      ..shader = gradient;

    // It will create 180/pi radian or 45deg rotated square
    final path = Path()
      ..moveTo(0, size.height / 2)
      ..lineTo(size.width / 2, 0)
      ..lineTo(size.width, size.height / 2)
      ..lineTo(size.width / 2, size.height);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
