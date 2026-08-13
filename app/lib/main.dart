import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'state/catalog.dart';
import 'state/player_state.dart';
import 'theme/app_theme.dart';
import 'screens/map_screen.dart';

void main() {
  runApp(const Tree4AllApp());
}

class Tree4AllApp extends StatelessWidget {
  const Tree4AllApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tree4All',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const _AppLoader(),
    );
  }
}

class _AppLoader extends StatefulWidget {
  const _AppLoader();

  @override
  State<_AppLoader> createState() => _AppLoaderState();
}

class _AppLoaderState extends State<_AppLoader> {
  late final Future<Catalog> _catalogFuture;
  final PlayerState _playerState = PlayerState();

  @override
  void initState() {
    super.initState();
    _catalogFuture = Catalog.load();
    _playerState.load();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Catalog>(
      future: _catalogFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Scaffold(
            backgroundColor: AppColors.nightDeep,
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🌳', style: TextStyle(fontSize: 48)),
                  const SizedBox(height: 16),
                  Text('Tree4All', style: AppTheme.titleDecorative(size: 24)),
                  const SizedBox(height: 20),
                  const CircularProgressIndicator(color: AppColors.goldBright),
                ],
              ),
            ),
          );
        }
        return ChangeNotifierProvider<PlayerState>.value(
          value: _playerState,
          child: MapScreen(catalog: snapshot.data!),
        );
      },
    );
  }
}
