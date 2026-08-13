import 'package:flutter/material.dart';

import '../models/zone.dart';
import '../models/species.dart';
import '../state/catalog.dart';
import '../theme/app_theme.dart';
import '../widgets/species_card.dart';

class ZoneSheet extends StatelessWidget {
  final Zone zone;
  final Catalog catalog;
  final VoidCallback onPlantHere;

  const ZoneSheet({super.key, required this.zone, required this.catalog, required this.onPlantHere});

  Color _badgeColor() {
    switch (zone.type) {
      case 'naturelle':
        return AppColors.arcane;
      case 'association':
        return AppColors.gold;
      default:
        return AppColors.forest;
    }
  }

  @override
  Widget build(BuildContext context) {
    final speciesWidgets = zone.especes
        .map((id) => catalog.speciesById[id])
        .whereType<Species>()
        .map((s) => SpeciesCard(species: s, catalog: catalog))
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(22, 8, 22, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(color: _badgeColor(), borderRadius: BorderRadius.circular(999)),
            child: Text(kTypeLabels[zone.type] ?? zone.type, style: AppTheme.title(size: 12, color: Colors.white)),
          ),
          const SizedBox(height: 10),
          Text(zone.nom, style: AppTheme.title(size: 22)),
          const SizedBox(height: 4),
          Text('${zone.ville}, ${zone.pays}', style: AppTheme.ui(size: 13, color: AppColors.inkSoft)),
          const SizedBox(height: 14),
          Text(zone.description, style: AppTheme.body(size: 16)),
          const SizedBox(height: 18),
          Text('RÈGLES À RESPECTER', style: AppTheme.ui(size: 13, color: AppColors.arcane)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8),
              border: const Border(left: BorderSide(color: AppColors.goldBright, width: 3)),
            ),
            child: Text(zone.regles, style: AppTheme.body(size: 15, color: AppColors.inkSoft)),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text('Source : ${zone.source}', style: AppTheme.ui(size: 11, color: AppColors.inkSoft.withValues(alpha: 0.8))),
          ),
          if (speciesWidgets.isNotEmpty) ...[
            const SizedBox(height: 18),
            Text('ESPÈCES RECOMMANDÉES', style: AppTheme.ui(size: 13, color: AppColors.arcane)),
            const SizedBox(height: 8),
            ...speciesWidgets,
          ],
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onPlantHere,
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.arcaneLight, foregroundColor: Colors.white),
              child: const Text("🪄 J'ai planté ici"),
            ),
          ),
        ],
      ),
    );
  }
}
