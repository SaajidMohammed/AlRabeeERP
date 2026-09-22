import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_tokens.dart';

enum BadgeVariant { success, warning, error, info, neutral, purple, gold }

class StatusBadge extends StatelessWidget {
  final String label;
  final BadgeVariant variant;
  final IconData? icon;
  final bool isPill;

  const StatusBadge({
    super.key,
    required this.label,
    required this.variant,
    this.icon,
    this.isPill = true,
  });

  factory StatusBadge.success(String label, {IconData? icon}) =>
      StatusBadge(label: label, variant: BadgeVariant.success, icon: icon);

  factory StatusBadge.warning(String label, {IconData? icon}) =>
      StatusBadge(label: label, variant: BadgeVariant.warning, icon: icon);

  factory StatusBadge.error(String label, {IconData? icon}) =>
      StatusBadge(label: label, variant: BadgeVariant.error, icon: icon);

  factory StatusBadge.info(String label, {IconData? icon}) =>
      StatusBadge(label: label, variant: BadgeVariant.info, icon: icon);

  factory StatusBadge.neutral(String label, {IconData? icon}) =>
      StatusBadge(label: label, variant: BadgeVariant.neutral, icon: icon);

  factory StatusBadge.gold(String label, {IconData? icon}) =>
      StatusBadge(label: label, variant: BadgeVariant.gold, icon: icon);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color bg;
    Color text;

    switch (variant) {
      case BadgeVariant.success:
        bg = isDark ? const Color(0xFF143823) : AppColors.successBg;
        text = isDark ? const Color(0xFF4ADE80) : AppColors.successText;
        break;
      case BadgeVariant.warning:
        bg = isDark ? const Color(0xFF382A12) : AppColors.warningBg;
        text = isDark ? const Color(0xFFFBBF24) : AppColors.warningText;
        break;
      case BadgeVariant.error:
        bg = isDark ? const Color(0xFF3B1818) : AppColors.errorBg;
        text = isDark ? const Color(0xFFF87171) : AppColors.errorText;
        break;
      case BadgeVariant.info:
        bg = isDark ? const Color(0xFF132B45) : AppColors.infoBg;
        text = isDark ? const Color(0xFF38BDF8) : AppColors.infoText;
        break;
      case BadgeVariant.gold:
        bg = isDark ? const Color(0xFF3B2F11) : AppColors.saffronGoldLight;
        text = isDark ? const Color(0xFFFCD34D) : const Color(0xFFB45309);
        break;
      case BadgeVariant.purple:
        bg = isDark ? const Color(0xFF2C1947) : const Color(0xFFF3E8FF);
        text = isDark ? const Color(0xFFC084FC) : const Color(0xFF7E22CE);
        break;
      case BadgeVariant.neutral:
        bg = isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9);
        text = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: isPill ? AppTokens.borderRadiusFull : AppTokens.borderRadiusSm,
        border: Border.all(color: text.withValues(alpha: 0.25), width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: text),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: text,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
