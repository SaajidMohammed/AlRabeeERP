import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class AlRabeeKpiCard extends StatefulWidget {
  final String title;
  final String value;
  final String? subtitle;
  final double? trendPercent;
  final bool isPositiveTrend;
  final IconData icon;
  final Color pastelBgColor;
  final Color iconColor;
  final VoidCallback? onTap;

  const AlRabeeKpiCard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    this.trendPercent,
    this.isPositiveTrend = true,
    required this.icon,
    this.pastelBgColor = AppColors.pastelLavender,
    this.iconColor = AppColors.pastelLavenderIcon,
    this.onTap,
  });

  @override
  State<AlRabeeKpiCard> createState() => _AlRabeeKpiCardState();
}

class _AlRabeeKpiCardState extends State<AlRabeeKpiCard> with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
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

    return ScaleTransition(
      scale: _scaleAnimation,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTapDown: (_) => _animController.forward(),
          onTapUp: (_) => _animController.reverse(),
          onTapCancel: () => _animController.reverse(),
          onTap: widget.onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isDark
                    ? (_isHovered ? AppColors.primary.withValues(alpha: 0.4) : AppColors.borderDark)
                    : (_isHovered ? AppColors.primary.withValues(alpha: 0.3) : AppColors.borderLight),
                width: 1.2,
              ),
              boxShadow: isDark
                  ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        offset: const Offset(0, 4),
                        blurRadius: 10,
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: const Color(0xFF0F172A).withValues(alpha: _isHovered ? 0.08 : 0.03),
                        offset: const Offset(0, 4),
                        blurRadius: 12,
                        spreadRadius: 0,
                      ),
                    ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Top Row: Icon Container + Growth Badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Soft Pastel Icon Container
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: isDark
                            ? widget.iconColor.withValues(alpha: 0.18)
                            : widget.pastelBgColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Icon(
                          widget.icon,
                          color: isDark ? widget.iconColor : widget.iconColor,
                          size: 22,
                        ),
                      ),
                    ),

                    // Growth Pill
                    if (widget.trendPercent != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: widget.isPositiveTrend
                              ? (isDark ? const Color(0xFF143823) : AppColors.pastelMint)
                              : (isDark ? const Color(0xFF3B1818) : AppColors.pastelRose),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              widget.isPositiveTrend
                                  ? Icons.arrow_outward_rounded
                                  : Icons.arrow_downward_rounded,
                              size: 11,
                              color: widget.isPositiveTrend
                                  ? (isDark ? const Color(0xFF4ADE80) : AppColors.successText)
                                  : (isDark ? const Color(0xFFF87171) : AppColors.errorText),
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '${widget.isPositiveTrend ? '+' : '-'}${widget.trendPercent!.toStringAsFixed(0)}%',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: widget.isPositiveTrend
                                    ? (isDark ? const Color(0xFF4ADE80) : AppColors.successText)
                                    : (isDark ? const Color(0xFFF87171) : AppColors.errorText),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 14),

                // Card Metric & Label
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        letterSpacing: 0.1,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.value,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                        letterSpacing: -0.5,
                        height: 1.1,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (widget.subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        widget.subtitle!,
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
