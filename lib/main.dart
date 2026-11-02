import 'package:flutter/material.dart';

import 'screens/display_screen.dart';
import 'screens/host_screen.dart';
import 'services/game_sync_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MiniGameShowApp());
}

class MiniGameShowApp extends StatefulWidget {
  const MiniGameShowApp({super.key});

  @override
  State<MiniGameShowApp> createState() => _MiniGameShowAppState();
}

class _MiniGameShowAppState extends State<MiniGameShowApp> {
  late final GameSyncService _sync;
  late final bool _isDisplayMode;

  @override
  void initState() {
    super.initState();

    _sync = GameSyncService();
    _isDisplayMode = Uri.base.queryParameters['mode'] == 'display';
  }

  @override
  void dispose() {
    _sync.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mini Game Show',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF7C3AED),
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F5FB),
      ),
      home: _isDisplayMode
          ? AnimatedBuilder(
        animation: _sync,
        builder: (context, _) {
          return DisplayScreen(state: _sync.state);
        },
      )
          : HostScreen(sync: _sync),
    );
  }
}