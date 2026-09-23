import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_tokens.dart';

class SectionCard extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final Widget? trailing;
  final Widget child;
  final EdgeInsetsGeometry padding;
  final bool hasHeaderDivider;
  final bool isExpanded;

  const SectionCard({
    super.key,
    this.title,
    this.subtitle,
    this.trailing,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.hasHeaderDivider = true,
    this.isExpanded = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: AppTokens.borderRadiusLg,
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
        boxShadow: isDark ? [] : AppTokens.shadowSm,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final shouldExpand = isExpanded && constraints.hasBoundedHeight;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: shouldExpand ? MainAxisSize.max : MainAxisSize.min,
            children: [
              if (title != null || trailing != null) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (title != null)
                              Text(
                                title!,
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            if (subtitle != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                subtitle!,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ],
                        ),
                      ),
                      ?trailing,
                    ],
                  ),
                ),

                if (hasHeaderDivider)
                  Divider(
                    color: isDark ? AppColors.borderDark : AppColors.borderLight,
                    height: 1,
                  ),
              ],
              if (shouldExpand)
                Expanded(
                  child: Padding(
                    padding: padding,
                    child: child,
                  ),
                )
              else
                Padding(
                  padding: padding,
                  child: child,
                ),
            ],
          );
        },
      ),
    );
  }
}
