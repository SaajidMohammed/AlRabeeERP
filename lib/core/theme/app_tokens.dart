import 'package:flutter/material.dart';

class AppTokens {
  AppTokens._();

  // Spacing Scale
  static const double space2 = 2.0;
  static const double space4 = 4.0;
  static const double space6 = 6.0;
  static const double space8 = 8.0;
  static const double space10 = 10.0;
  static const double space12 = 12.0;
  static const double space16 = 16.0;
  static const double space20 = 20.0;
  static const double space24 = 24.0;
  static const double space28 = 28.0;
  static const double space32 = 32.0;
  static const double space40 = 40.0;
  static const double space48 = 48.0;
  static const double space56 = 56.0;
  static const double space64 = 64.0;

  // Border Radius Scale
  static const double radiusXs = 4.0;
  static const double radiusSm = 6.0;
  static const double radiusMd = 10.0;
  static const double radiusLg = 14.0;
  static const double radiusXl = 20.0;
  static const double radiusFull = 999.0;

  static const BorderRadius borderRadiusXs = BorderRadius.all(Radius.circular(radiusXs));
  static const BorderRadius borderRadiusSm = BorderRadius.all(Radius.circular(radiusSm));
  static const BorderRadius borderRadiusMd = BorderRadius.all(Radius.circular(radiusMd));
  static const BorderRadius borderRadiusLg = BorderRadius.all(Radius.circular(radiusLg));
  static const BorderRadius borderRadiusXl = BorderRadius.all(Radius.circular(radiusXl));
  static const BorderRadius borderRadiusFull = BorderRadius.all(Radius.circular(radiusFull));

  // Component Heights
  static const double buttonHeightSm = 34.0;
  static const double buttonHeightMd = 42.0;
  static const double buttonHeightLg = 48.0;
  static const double inputHeight = 44.0;
  static const double topbarHeight = 64.0;
  static const double sidebarWidthExpanded = 260.0;
  static const double sidebarWidthCollapsed = 72.0;
  static const double bottomNavHeight = 64.0;

  // Breakpoints
  static const double breakpointMobile = 640.0;
  static const double breakpointTablet = 1024.0;
  static const double breakpointDesktop = 1440.0;

  // Animation Durations
  static const Duration durationFast = Duration(milliseconds: 150);
  static const Duration durationNormal = Duration(milliseconds: 250);
  static const Duration durationSlow = Duration(milliseconds: 400);

  // Shadows
  static const List<BoxShadow> shadowSm = [
    BoxShadow(
      color: Color(0x08000000),
      offset: Offset(0, 1),
      blurRadius: 2,
    ),
  ];

  static const List<BoxShadow> shadowMd = [
    BoxShadow(
      color: Color(0x0C000000),
      offset: Offset(0, 4),
      blurRadius: 8,
      spreadRadius: -1,
    ),
  ];

  static const List<BoxShadow> shadowLg = [
    BoxShadow(
      color: Color(0x14000000),
      offset: Offset(0, 10),
      blurRadius: 15,
      spreadRadius: -3,
    ),
  ];

  static const List<BoxShadow> shadowCardHover = [
    BoxShadow(
      color: Color(0x180D683D),
      offset: Offset(0, 8),
      blurRadius: 20,
      spreadRadius: -2,
    ),
  ];
}
