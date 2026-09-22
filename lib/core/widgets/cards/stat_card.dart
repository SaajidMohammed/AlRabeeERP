import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_tokens.dart';

class StatCard extends StatefulWidget {
  final String title;
  final String value;
  final String? subtitle;
  final double? trendPercent;
  final bool isPositiveTrend;
  final IconData icon;
  final Color? iconColor;
  final VoidCallback? onTap;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    this.trendPercent,
    this.isPositiveTrend = true,
    required this.icon,
    this.iconColor,
    this.onTap,
  });

  @override
  State<StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<StatCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = widget.iconColor ?? AppColors.primary;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: AppTokens.durationFast,
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.cardLight,
          borderRadius: AppTokens.borderRadiusLg,
          border: Border.all(
            color: _isHovered
                ? primaryColor.withValues(alpha: 0.5)
                : (isDark ? AppColors.borderDark : AppColors.borderLight),
            width: _isHovered ? 1.4 : 1.0,
          ),
          boxShadow: _isHovered
              ? (isDark ? AppTokens.shadowMd : AppTokens.shadowCardHover)
              : (isDark ? [] : AppTokens.shadowSm),
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: AppTokens.borderRadiusLg,
            child: Padding(
              padding: const EdgeInsets.all(18.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.title,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: primaryColor.withValues(alpha: isDark ? 0.2 : 0.1),
                          borderRadius: AppTokens.borderRadiusMd,
                        ),
                        child: Icon(widget.icon, size: 20, color: primaryColor),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.value,
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 22,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (widget.trendPercent != null) ...[
                        Icon(
                          widget.isPositiveTrend
                              ? Icons.trending_up_rounded
                              : Icons.trending_down_rounded,
                          size: 16,
                          color: widget.isPositiveTrend
                              ? AppColors.success
                              : AppColors.error,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${widget.trendPercent!.toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: widget.isPositiveTrend
                                ? AppColors.success
                                : AppColors.error,
                          ),
                        ),
                        const SizedBox(width: 6),
                      ],
                      if (widget.subtitle != null)
                        Expanded(
                          child: Text(
                            widget.subtitle!,
                            style: Theme.of(context).textTheme.bodySmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
