import 'package:flutter/material.dart';

import '../models/rank.dart';
import '../models/species.dart';
import '../theme/app_theme.dart';

/// Sheet affichée après une plantation : soit une simple confirmation
/// (+XP), soit une célébration de montée de rang si le seuil est franchi.
class LevelUpSheet extends StatelessWidget {
  final Species species;
  final int xpGained;
  final bool firstTimeBonus;
  final bool zoneBonus;
  final Rank? newRank;
  final VoidCallback onContinue;

  const LevelUpSheet({
    super.key,
    required this.species,
    required this.xpGained,
    required this.firstTimeBonus,
    required this.zoneBonus,
    required this.newRank,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final isRankUp = newRank != null;
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 30, 22, 40),
      child: Column(
        children: [
          Text(isRankUp ? newRank!.icone : species.icone, style: const TextStyle(fontSize: 64)),
          const SizedBox(height: 12),
          Text(
            isRankUp ? 'Nouveau rang atteint !' : '${species.nom} planté(e) !',
            style: AppTheme.titleDecorative(size: 22, color: AppColors.arcane),
            textAlign: TextAlign.center,
          ),
          if (isRankUp) ...[
            const SizedBox(height: 6),
            Text('Te voici « ${newRank!.nom} »', style: AppTheme.body(size: 15, color: AppColors.inkSoft, fontStyle: FontStyle.italic)),
            const SizedBox(height: 4),
            Text('"${newRank!.flavor}"', style: AppTheme.body(size: 14, color: AppColors.inkSoft, fontStyle: FontStyle.italic), textAlign: TextAlign.center),
          ],
          const SizedBox(height: 10),
          Text(
            '+$xpGained XP'
            '${firstTimeBonus ? ' (bonus première fois ✨)' : ''}'
            '${zoneBonus ? ' (bonus zone officielle 🛡️)' : ''}',
            style: AppTheme.ui(size: 14, color: AppColors.forest, weight: FontWeight.w800),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onContinue,
              child: Text(isRankUp ? "Continuer l'aventure" : 'Voir mon grimoire'),
            ),
          ),
        ],
      ),
    );
  }
}
