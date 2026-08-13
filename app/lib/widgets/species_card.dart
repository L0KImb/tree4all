import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/species.dart';
import '../state/catalog.dart';
import '../theme/app_theme.dart';

class SpeciesCard extends StatelessWidget {
  final Species species;
  final Catalog catalog;

  const SpeciesCard({super.key, required this.species, required this.catalog});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(species.icone, style: const TextStyle(fontSize: 26)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(species.nom, style: AppTheme.title(size: 15)),
                Text(species.latin, style: AppTheme.body(size: 13, color: AppColors.inkSoft, fontStyle: FontStyle.italic)),
                const SizedBox(height: 4),
                Text(species.description, style: AppTheme.body(size: 14, color: AppColors.inkSoft)),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 5,
                  runSpacing: 5,
                  children: species.tags.map((t) => _Tag(t)).toList(),
                ),
                if (species.sourcesGraines.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text('OÙ TROUVER LES GRAINES', style: AppTheme.ui(size: 11, color: AppColors.arcane)),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: species.sourcesGraines.map((id) {
                      final s = catalog.seedSourcesById[id];
                      if (s == null) return const SizedBox.shrink();
                      final url = s.primaryUrl;
                      return _SeedChip(label: '${s.icone} ${s.nom}', onTap: url == null ? null : () => launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication));
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  const _Tag(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: AppColors.mossLight, borderRadius: BorderRadius.circular(999)),
      child: Text(label, style: AppTheme.ui(size: 10.5, color: AppColors.forestDeep)),
    );
  }
}

class _SeedChip extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  const _SeedChip({required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.gold.withValues(alpha: 0.18),
          border: Border.all(color: AppColors.gold.withValues(alpha: 0.5)),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(label, style: AppTheme.ui(size: 11.5)),
      ),
    );
  }
}
