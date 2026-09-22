import 'package:flutter/material.dart';
import '../theme/app_tokens.dart';

enum ScreenType { mobile, tablet, desktop }

class Responsive extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget desktop;

  const Responsive({
    super.key,
    required this.mobile,
    this.tablet,
    required this.desktop,
  });

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < AppTokens.breakpointMobile;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= AppTokens.breakpointMobile &&
      MediaQuery.of(context).size.width < AppTokens.breakpointTablet;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= AppTokens.breakpointTablet;

  static ScreenType getScreenType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < AppTokens.breakpointMobile) return ScreenType.mobile;
    if (width < AppTokens.breakpointTablet) return ScreenType.tablet;
    return ScreenType.desktop;
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= AppTokens.breakpointTablet) {
      return desktop;
    } else if (width >= AppTokens.breakpointMobile && tablet != null) {
      return tablet!;
    } else {
      return mobile;
    }
  }
}
