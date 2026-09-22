import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/routing/app_router.dart';
import 'core/widgets/toast/toast_service.dart';
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/erp_provider.dart';
import 'providers/command_palette_provider.dart';

import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Explicitly ensure MaterialIcons font is loaded in CanvasKit / Flutter Web
  try {
    final fontLoader = FontLoader('MaterialIcons');
    fontLoader.addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
    await fontLoader.load();
  } catch (e) {
    debugPrint('Icon font loader note: $e');
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ErpProvider()),
        ChangeNotifierProvider(create: (_) => ToastService()),
        ChangeNotifierProvider(create: (_) => CommandPaletteProvider()),
      ],
      child: const AlRabeeApp(),
    ),
  );
}

class AlRabeeApp extends StatelessWidget {
  const AlRabeeApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp.router(
      title: 'Al Rabee ERP — Enterprise Retail Management',
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.themeMode,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      routerConfig: appRouter,
    );
  }
}
