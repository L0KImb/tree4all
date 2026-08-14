import 'package:flutter/material.dart';

import '../models/legendary_place.dart';
import '../state/catalog.dart';
import '../state/player_state.dart';
import '../theme/app_theme.dart';

class GrimoireSheet extends StatelessWidget {
  final Catalog catalog;
  final PlayerState player;
  final VoidCallback onAddPlantation;

  const GrimoireSheet({super.key, required this.catalog, required this.player, required this.onAddPlantation});

  @override
  Widget build(BuildContext context) {
    final r = catalog.rankForXp(player.xp);
    double progress = 1;
    String xpText;
    if (r.next != null) {
      final span = r.next!.seuilXp - r.current.seuilXp;
      progress = span > 0 ? ((player.xp - r.current.seuilXp) / span).clamp(0, 1).toDouble() : 1;
      xpText = '${player.xp} XP — ${r.next!.seuilXp - player.xp} XP avant « ${r.next!.nom} »';
    } else {
      xpText = '${player.xp} XP — rang légendaire atteint !';
    }

    final entries = player.plantations.reversed.toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(22, 8, 22, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(r.current.icone, style: const TextStyle(fontSize: 40)),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(r.current.nom, style: AppTheme.title(size: 19)),
                    Text(xpText, style: AppTheme.ui(size: 12.5, color: AppColors.inkSoft)),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: progress.toDouble(),
                        minHeight: 10,
                        backgroundColor: Colors.black.withValues(alpha: 0.12),
                        valueColor: const AlwaysStoppedAnimation(AppColors.goldBright),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 26, color: AppColors.gold),
          Text('"${r.current.flavor}"', style: AppTheme.body(size: 14.5, color: AppColors.inkSoft, fontStyle: FontStyle.italic)),
          const SizedBox(height: 18),
          Text('JOURNAL DE PLANTATION (${player.plantations.length})', style: AppTheme.ui(size: 13, color: AppColors.arcane)),
          const SizedBox(height: 6),
          if (entries.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  'Ton grimoire est encore vierge. Plante ta première pousse de vie !',
                  textAlign: TextAlign.center,
                  style: AppTheme.body(size: 14.5, color: AppColors.inkSoft, fontStyle: FontStyle.italic),
                ),
              ),
            )
          else
            ...entries.map((p) {
              final species = catalog.speciesById[p.especeId];
              return Container(
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Color(0x33C9A961))),
                ),
                child: Row(
                  children: [
                    Text(species?.icone ?? '🌱', style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(species?.nom ?? p.especeId, style: AppTheme.title(size: 14)),
                          Text(p.date, style: AppTheme.ui(size: 11.5, color: AppColors.inkSoft)),
                        ],
                      ),
                    ),
                    Text('+${p.xpGained} XP', style: AppTheme.ui(size: 12.5, color: AppColors.forest)),
                  ],
                ),
              );
            }),
          const SizedBox(height: 24),
          Text('LIEUX LÉGENDAIRES DÉCOUVERTS (${player.visitedPlaceIds.length}/${catalog.legendaryPlaces.length})',
              style: AppTheme.ui(size: 13, color: AppColors.arcane)),
          const SizedBox(height: 6),
          if (player.visitedPlaceIds.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'Touche 🔮 sur la carte pour révéler les mégalithes, sites païens et récits de sorcellerie autour de toi.',
                style: AppTheme.body(size: 14.5, color: AppColors.inkSoft, fontStyle: FontStyle.italic),
              ),
            )
          else
            ...catalog.legendaryPlaces.where((p) => player.hasVisited(p.id)).map((LegendaryPlace p) {
              return Container(
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Color(0x33C9A961))),
                ),
                child: Row(
                  children: [
                    const Text(kLegendaryIcon, style: TextStyle(fontSize: 18)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(p.nom, style: AppTheme.title(size: 14)),
                          Text(p.ville, style: AppTheme.ui(size: 11.5, color: AppColors.inkSoft)),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onAddPlantation,
              child: const Text('🪄 Ajouter une plantation'),
            ),
          ),
        ],
      ),
    );
  }
}
