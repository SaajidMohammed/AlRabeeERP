import 'package:flutter/material.dart';

class AlRabeeSkeleton extends StatefulWidget {

  final double? width;
  final double height;
  final double borderRadius;
  final ShapeBorder? shape;

  const AlRabeeSkeleton({
    super.key,
    this.width,
    required this.height,
    this.borderRadius = 8.0,
    this.shape,
  });

  const AlRabeeSkeleton.circular({
    super.key,
    required double size,
  })  : width = size,
        height = size,
        borderRadius = 999.0,
        shape = const CircleBorder();

  @override
  State<AlRabeeSkeleton> createState() => _AlRabeeSkeletonState();
}

class _AlRabeeSkeletonState extends State<AlRabeeSkeleton> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _opacityAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _opacityAnim = Tween<double>(begin: 0.35, end: 0.85).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);

    return AnimatedBuilder(
      animation: _opacityAnim,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnim.value,
          child: Container(
            width: widget.width,
            height: widget.height,
            decoration: widget.shape != null
                ? ShapeDecoration(color: baseColor, shape: widget.shape!)
                : BoxDecoration(
                    color: baseColor,
                    borderRadius: BorderRadius.circular(widget.borderRadius),
                  ),
          ),
        );
      },
    );
  }
}
