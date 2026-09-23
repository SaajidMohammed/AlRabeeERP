import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_tokens.dart';

enum AlRabeeButtonVariant { primary, secondary, tonal, outlined, danger, text }

class AlRabeeButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final AlRabeeButtonVariant variant;
  final bool isLoading;
  final bool isFullWidth;
  final double? height;
  final EdgeInsetsGeometry? padding;

  const AlRabeeButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.variant = AlRabeeButtonVariant.primary,
    this.isLoading = false,
    this.isFullWidth = false,
    this.height,
    this.padding,
  });

  const AlRabeeButton.secondary({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.height,
    this.padding,
  }) : variant = AlRabeeButtonVariant.secondary;

  const AlRabeeButton.tonal({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.height,
    this.padding,
  }) : variant = AlRabeeButtonVariant.tonal;

  const AlRabeeButton.outlined({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.height,
    this.padding,
  }) : variant = AlRabeeButtonVariant.outlined;

  const AlRabeeButton.danger({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.height,
    this.padding,
  }) : variant = AlRabeeButtonVariant.danger;

  const AlRabeeButton.text({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.height,
    this.padding,
  }) : variant = AlRabeeButtonVariant.text;

  @override
  State<AlRabeeButton> createState() => _AlRabeeButtonState();
}

class _AlRabeeButtonState extends State<AlRabeeButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color bg;
    Color fg;
    BorderSide border = BorderSide.none;

    switch (widget.variant) {
      case AlRabeeButtonVariant.primary:
        bg = AppColors.primary;
        fg = Colors.white;
        break;
      case AlRabeeButtonVariant.secondary:
        bg = isDark ? AppColors.surfaceDark : const Color(0xFF1E293B);
        fg = Colors.white;
        break;
      case AlRabeeButtonVariant.tonal:
        bg = isDark ? AppColors.primaryDark.withValues(alpha: 0.3) : AppColors.primaryContainer;
        fg = isDark ? AppColors.primaryLight : AppColors.onPrimaryContainer;
        break;
      case AlRabeeButtonVariant.outlined:
        bg = Colors.transparent;
        fg = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
        border = BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight, width: 1.2);
        break;
      case AlRabeeButtonVariant.danger:
        bg = AppColors.error;
        fg = Colors.white;
        break;
      case AlRabeeButtonVariant.text:
        bg = Colors.transparent;
        fg = AppColors.primary;
        break;
    }

    final buttonContent = widget.isLoading
        ? SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(fg),
            ),
          )
        : Row(
            mainAxisSize: widget.isFullWidth ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, size: 18, color: fg),
                const SizedBox(width: 8),
              ],
              Text(
                widget.label,
                style: TextStyle(
                  color: fg,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          );

    return ScaleTransition(
      scale: _scaleAnimation,
      child: SizedBox(
        width: widget.isFullWidth ? double.infinity : null,
        height: widget.height ?? AppTokens.buttonHeightMd,
        child: Material(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: widget.isLoading ? null : widget.onPressed,
            onTapDown: (_) => _controller.forward(),
            onTapUp: (_) => _controller.reverse(),
            onTapCancel: () => _controller.reverse(),
            child: Container(
              padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.fromBorderSide(border),
              ),
              alignment: Alignment.center,
              child: buttonContent,
            ),
          ),
        ),
      ),
    );
  }
}
