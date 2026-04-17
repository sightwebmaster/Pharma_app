import 'package:flutter/material.dart';

/// MedicineIllustration - Affiche une illustration basée sur le type
class MedicineIllustration extends StatelessWidget {
  final String
  medicinType; // 'Capsule', 'Comprimé', 'Sirop', 'Injection', 'Poudre'
  final double height;
  final double width;

  const MedicineIllustration({
    Key? key,
    required this.medicinType,
    this.height = 200,
    this.width = 200,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    switch (medicinType.toLowerCase()) {
      case 'capsule':
        return _CapsuleIllustration(height: height, width: width);
      case 'injection':
      case 'seringue':
        return _SyringeIllustration(height: height, width: width);
      case 'sirop':
      case 'bouteille':
        return _BottleIllustration(height: height, width: width);
      case 'comprimé':
      case 'comprime':
      case 'tablet':
        return _TabletIllustration(height: height, width: width);
      default:
        return _DefaultPillIllustration(height: height, width: width);
    }
  }
}

/// Illustration Capsule (orange/jaune)
class _CapsuleIllustration extends StatelessWidget {
  final double height;
  final double width;

  const _CapsuleIllustration({required this.height, required this.width});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width,
      child: Center(
        child: CustomPaint(
          painter: CapsulePainter(),
          size: Size(width * 0.6, height * 0.7),
        ),
      ),
    );
  }
}

/// Illustration Seringue
class _SyringeIllustration extends StatelessWidget {
  final double height;
  final double width;

  const _SyringeIllustration({required this.height, required this.width});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width,
      child: Center(
        child: CustomPaint(
          painter: SyringePainter(),
          size: Size(width * 0.5, height * 0.8),
        ),
      ),
    );
  }
}

/// Illustration Bouteille
class _BottleIllustration extends StatelessWidget {
  final double height;
  final double width;

  const _BottleIllustration({required this.height, required this.width});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width,
      child: Center(
        child: CustomPaint(
          painter: BottlePainter(),
          size: Size(width * 0.5, height * 0.8),
        ),
      ),
    );
  }
}

/// Illustration Comprimé
class _TabletIllustration extends StatelessWidget {
  final double height;
  final double width;

  const _TabletIllustration({required this.height, required this.width});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width,
      child: Center(
        child: CustomPaint(
          painter: TabletPainter(),
          size: Size(width * 0.6, height * 0.5),
        ),
      ),
    );
  }
}

/// Illustration par défaut
class _DefaultPillIllustration extends StatelessWidget {
  final double height;
  final double width;

  const _DefaultPillIllustration({required this.height, required this.width});

  @override
  Widget build(BuildContext context) {
    return _CapsuleIllustration(height: height, width: width);
  }
}

/// Painter pour Capsule
class CapsulePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.1)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // Ombre
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(centerX, centerY + 4),
          width: size.width,
          height: size.height * 0.8,
        ),
        Radius.circular(size.height * 0.4),
      ),
      shadowPaint,
    );

    // Demi-capsule rouge/orange (droite)
    paint.color = const Color(0xFFFF8800);
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(centerX + size.width * 0.2, centerY),
        width: size.width * 0.5,
        height: size.height,
      ),
      0,
      3.14,
      true,
      paint,
    );

    // Demi-capsule jaune (gauche)
    paint.color = const Color(0xFFFFA500);
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(centerX - size.width * 0.2, centerY),
        width: size.width * 0.5,
        height: size.height,
      ),
      3.14,
      3.14,
      true,
      paint,
    );

    // Reflet diagonal
    final reflectPaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          centerX - size.width * 0.1,
          centerY - size.height * 0.3,
          size.width * 0.2,
          size.height * 0.2,
        ),
        Radius.circular(size.width * 0.1),
      ),
      reflectPaint,
    );
  }

  @override
  bool shouldRepaint(CapsulePainter oldDelegate) => false;
}

/// Painter pour Seringue
class SyringePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Aiguille (gris)
    paint.color = const Color(0xFF999999);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.4,
          0,
          size.width * 0.2,
          size.height * 0.25,
        ),
        Radius.circular(2),
      ),
      paint,
    );

    // Pointe aiguille
    final path = Path();
    path.moveTo(size.width * 0.4, size.height * 0.25);
    path.lineTo(size.width * 0.5, size.height * 0.35);
    path.lineTo(size.width * 0.6, size.height * 0.25);
    path.close();
    paint.color = const Color(0xFF666666);
    canvas.drawPath(path, paint);

    // Cylindre seringue (transparent avec bordure)
    final cylinderPaint = Paint()
      ..color = const Color(0xFFE8F4F8)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.15,
          size.height * 0.25,
          size.width * 0.7,
          size.height * 0.5,
        ),
        Radius.circular(4),
      ),
      cylinderPaint,
    );

    // Bordure cylindre
    final borderPaint = Paint()
      ..color = const Color(0xFF2E73C9)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.15,
          size.height * 0.25,
          size.width * 0.7,
          size.height * 0.5,
        ),
        Radius.circular(4),
      ),
      borderPaint,
    );

    // Piston (blanc)
    paint.color = Colors.white;
    canvas.drawRect(
      Rect.fromLTWH(
        size.width * 0.05,
        size.height * 0.35,
        size.width * 0.15,
        size.height * 0.3,
      ),
      paint,
    );

    // Tige piston (grise)
    paint.color = const Color(0xFFCCCCCC);
    canvas.drawRect(
      Rect.fromLTWH(
        size.width * 0.08,
        size.height * 0.38,
        size.width * 0.09,
        size.height * 0.24,
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(SyringePainter oldDelegate) => false;
}

/// Painter pour Bouteille
class BottlePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Bouchon (blanc)
    paint.color = Colors.white;
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.25, 0, size.width * 0.5, size.height * 0.15),
      paint,
    );

    // Ombre bouchon
    paint.color = Colors.black.withOpacity(0.1);
    canvas.drawRect(
      Rect.fromLTWH(
        size.width * 0.25,
        size.height * 0.12,
        size.width * 0.5,
        size.height * 0.05,
      ),
      paint,
    );

    // Col (bleu pâle)
    paint.color = const Color(0xFFD6ECFF);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.3,
          size.height * 0.12,
          size.width * 0.4,
          size.height * 0.2,
        ),
        Radius.circular(4),
      ),
      paint,
    );

    // Bordure col
    final borderPaint = Paint()
      ..color = const Color(0xFF2E73C9)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.3,
          size.height * 0.12,
          size.width * 0.4,
          size.height * 0.2,
        ),
        Radius.circular(4),
      ),
      borderPaint,
    );

    // Bouteille (bleu clair dégradé)
    paint.color = const Color(0xFFB3D9FF);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.1,
          size.height * 0.3,
          size.width * 0.8,
          size.height * 0.7,
        ),
        Radius.circular(8),
      ),
      paint,
    );

    // Limite du liquide (blanc/pâle)
    paint.color = Colors.white.withOpacity(0.3);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.1,
          size.height * 0.5,
          size.width * 0.8,
          size.height * 0.5,
        ),
        Radius.circular(8),
      ),
      paint,
    );

    // Reflet fenêtre (blanc)
    final reflectPaint = Paint()
      ..color = Colors.white.withOpacity(0.4)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.2,
          size.height * 0.4,
          size.width * 0.1,
          size.height * 0.3,
        ),
        Radius.circular(4),
      ),
      reflectPaint,
    );
  }

  @override
  bool shouldRepaint(BottlePainter oldDelegate) => false;
}

/// Painter pour Comprimé
class TabletPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // Ombre
    canvas.drawCircle(
      Offset(centerX, centerY + 4),
      size.width * 0.45,
      shadowPaint,
    );

    // Comprimé blanc
    paint.color = const Color(0xFFF5F5F5);
    canvas.drawCircle(Offset(centerX, centerY), size.width * 0.45, paint);

    // Bordure comprimé
    paint
      ..color = const Color(0xFFE0E0E0)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(Offset(centerX, centerY), size.width * 0.45, paint);

    // Reflet (blanc)
    paint
      ..color = Colors.white.withOpacity(0.5)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(centerX - size.width * 0.15, centerY - size.height * 0.2),
      size.width * 0.15,
      paint,
    );

    // Encoche au centre (trait gris)
    paint
      ..color = const Color(0xFFCCCCCC)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(centerX, centerY - size.height * 0.1),
      Offset(centerX, centerY + size.height * 0.1),
      paint,
    );
  }

  @override
  bool shouldRepaint(TabletPainter oldDelegate) => false;
}
