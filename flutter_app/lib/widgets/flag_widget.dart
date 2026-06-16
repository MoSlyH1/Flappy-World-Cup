// lib/widgets/flag_widget.dart
// Draws a simplified flag from Country colour data — no image assets,
// so it looks the same on mobile and web.

import 'package:flutter/material.dart';
import '../data/world_cup_teams.dart';

class FlagWidget extends StatelessWidget {
  final Country country;
  final double width;
  final double height;
  final double radius;

  const FlagWidget({
    super.key,
    required this.country,
    this.width = 36,
    this.height = 24,
    this.radius = 4,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black12, width: 0.5),
          borderRadius: BorderRadius.circular(radius),
        ),
        child: CustomPaint(
          size: Size(width, height),
          painter: _FlagPainter(country),
        ),
      ),
    );
  }
}

class _FlagPainter extends CustomPainter {
  final Country country;
  _FlagPainter(this.country);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final paint = Paint()..style = PaintingStyle.fill;

    switch (country.style) {
      case FlagStyle.vertical:
        final n = country.colors.length;
        final stripeW = w / n;
        for (var i = 0; i < n; i++) {
          paint.color = country.colors[i];
          canvas.drawRect(Rect.fromLTWH(i * stripeW, 0, stripeW + 0.5, h), paint);
        }
        break;

      case FlagStyle.horizontal:
        final n = country.colors.length;
        final stripeH = h / n;
        for (var i = 0; i < n; i++) {
          paint.color = country.colors[i];
          canvas.drawRect(Rect.fromLTWH(0, i * stripeH, w, stripeH + 0.5), paint);
        }
        break;

      case FlagStyle.cross:
        // colors[0] = background, colors[1] = cross
        paint.color = country.colors[0];
        canvas.drawRect(Rect.fromLTWH(0, 0, w, h), paint);
        paint.color = country.colors.length > 1 ? country.colors[1] : Colors.white;
        final bar = h * 0.22;
        canvas.drawRect(Rect.fromLTWH(0, h / 2 - bar / 2, w, bar), paint);
        canvas.drawRect(Rect.fromLTWH(w / 2 - bar / 2, 0, bar, h), paint);
        break;

      case FlagStyle.saltire:
        // colors[0] = background, colors[1] = X
        paint.color = country.colors[0];
        canvas.drawRect(Rect.fromLTWH(0, 0, w, h), paint);
        final line = Paint()
          ..color = country.colors.length > 1 ? country.colors[1] : Colors.white
          ..strokeWidth = h * 0.18
          ..style = PaintingStyle.stroke;
        canvas.drawLine(const Offset(0, 0), Offset(w, h), line);
        canvas.drawLine(Offset(0, h), Offset(w, 0), line);
        break;
    }

    // Optional centre emblem.
    if (country.emblem != null) {
      canvas.drawCircle(
        Offset(w / 2, h / 2),
        h * 0.22,
        Paint()..color = country.emblem!,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _FlagPainter old) => old.country != country;
}
