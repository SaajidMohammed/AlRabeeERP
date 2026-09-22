import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_tokens.dart';
import '../../utils/responsive.dart';
import 'toast_service.dart';

class ToastOverlay extends StatelessWidget {
  final Widget child;

  const ToastOverlay({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        Positioned.fill(
          child: IgnorePointer(
            ignoring: false,
            child: Consumer<ToastService>(
              builder: (context, service, _) {
                if (service.toasts.isEmpty) return const SizedBox.shrink();

                final isDesktop = Responsive.isDesktop(context);

                return Align(
                  alignment: isDesktop ? Alignment.topRight : Alignment.bottomCenter,
                  child: Container(
                    width: isDesktop ? 380 : double.infinity,
                    margin: EdgeInsets.only(
                      top: isDesktop ? 76 : 0,
                      right: isDesktop ? 20 : 16,
                      left: isDesktop ? 0 : 16,
                      bottom: isDesktop ? 0 : 76,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment:
                          isDesktop ? CrossAxisAlignment.end : CrossAxisAlignment.center,
                      children: service.toasts.map((toast) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _ToastCard(toast: toast),
                        );
                      }).toList(),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _ToastCard extends StatefulWidget {
  final ToastItem toast;

  const _ToastCard({required this.toast});

  @override
  State<_ToastCard> createState() => _ToastCardState();
}

class _ToastCardState extends State<_ToastCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppTokens.durationNormal,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.3, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getBorderColor() {
    switch (widget.toast.type) {
      case ToastType.success:
        return AppColors.success;
      case ToastType.warning:
        return AppColors.warning;
      case ToastType.error:
        return AppColors.error;
      case ToastType.info:
        return AppColors.info;
    }
  }

  IconData _getIcon() {
    switch (widget.toast.type) {
      case ToastType.success:
        return Icons.check_circle_rounded;
      case ToastType.warning:
        return Icons.warning_amber_rounded;
      case ToastType.error:
        return Icons.error_outline_rounded;
      case ToastType.info:
        return Icons.info_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = _getBorderColor();

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Material(
          type: MaterialType.transparency,
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : Colors.white,
              borderRadius: AppTokens.borderRadiusMd,
              border: Border.all(
                color: color.withValues(alpha: 0.35),
                width: 1.2,
              ),
              boxShadow: isDark ? AppTokens.shadowMd : AppTokens.shadowLg,
            ),
            child: ClipRRect(
              borderRadius: AppTokens.borderRadiusMd,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(_getIcon(), color: color, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.toast.title,
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                              if (widget.toast.message != null) ...[
                                const SizedBox(height: 2),
                                Text(
                                  widget.toast.message!,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ],
                          ),
                        ),
                        if (widget.toast.actionLabel != null) ...[
                          const SizedBox(width: 8),
                          TextButton(
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              minimumSize: const Size(0, 28),
                            ),
                            onPressed: () {
                              widget.toast.onAction?.call();
                              ToastService().remove(widget.toast.id);
                            },
                            child: Text(widget.toast.actionLabel!),
                          ),
                        ],
                        const SizedBox(width: 4),
                        InkWell(
                          onTap: () => ToastService().remove(widget.toast.id),
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: Icon(
                              Icons.close,
                              size: 16,
                              color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _LinearProgress(duration: widget.toast.duration, color: color),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LinearProgress extends StatefulWidget {
  final Duration duration;
  final Color color;

  const _LinearProgress({required this.duration, required this.color});

  @override
  State<_LinearProgress> createState() => _LinearProgressState();
}

class _LinearProgressState extends State<_LinearProgress>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return LinearProgressIndicator(
          value: 1.0 - _controller.value,
          minHeight: 2.5,
          backgroundColor: Colors.transparent,
          valueColor: AlwaysStoppedAnimation(widget.color.withValues(alpha: 0.6)),
        );
      },
    );
  }
}
