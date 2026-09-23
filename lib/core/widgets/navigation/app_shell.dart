import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../utils/responsive.dart';
import '../../../providers/command_palette_provider.dart';
import '../command_palette/command_palette_modal.dart';
import '../toast/toast_overlay.dart';
import 'sidebar.dart';
import 'topbar.dart';
import 'mobile_bottom_nav.dart';
import 'notification_drawer.dart';

class AppShell extends StatefulWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isSidebarCollapsed = false;

  void _handleKey(KeyEvent event) {
    if (event is KeyDownEvent) {
      final isCtrlOrCmd = HardwareKeyboard.instance.isControlPressed ||
          HardwareKeyboard.instance.isMetaPressed;
      if (isCtrlOrCmd && event.logicalKey == LogicalKeyboardKey.keyK) {
        final palette = context.read<CommandPaletteProvider>();
        if (palette.isOpen) {
          palette.close();
        } else {
          palette.open();
        }
      } else if (event.logicalKey == LogicalKeyboardKey.escape) {
        final palette = context.read<CommandPaletteProvider>();
        if (palette.isOpen) {
          palette.close();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = Responsive.isDesktop(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return KeyboardListener(
      focusNode: FocusNode()..requestFocus(),
      autofocus: true,
      onKeyEvent: _handleKey,
      child: ToastOverlay(
        child: Stack(
          children: [
            Scaffold(
              key: _scaffoldKey,
              backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
              endDrawer: const NotificationDrawer(),
              bottomNavigationBar: !isDesktop ? const MobileBottomNav() : null,
              body: Row(
                children: [
                  // Desktop Sidebar
                  if (isDesktop)
                    Sidebar(
                      isCollapsed: _isSidebarCollapsed,
                      onToggleCollapse: () {
                        setState(() {
                          _isSidebarCollapsed = !_isSidebarCollapsed;
                        });
                      },
                    ),

                  // Main Content Area
                  Expanded(
                    child: Column(
                      children: [
                        Topbar(
                          onOpenDrawer: () => _scaffoldKey.currentState?.openDrawer(),
                          onOpenNotifications: () => _scaffoldKey.currentState?.openEndDrawer(),
                        ),
                        Expanded(
                          child: widget.child,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Command Palette Overlay (Ctrl + K)
            const CommandPaletteModal(),
          ],
        ),
      ),
    );
  }
}
