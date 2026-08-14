import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/legendary_place.dart';
import '../theme/app_theme.dart';

class LegendaryPlaceSheet extends StatelessWidget {
  final LegendaryPlace place;
  final bool visited;
  final VoidCallback onVisit;

  const LegendaryPlaceSheet({super.key, required this.place, required this.visited, required this.onVisit});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(22, 8, 22, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(color: AppColors.night, borderRadius: BorderRadius.circular(999)),
            child: Text(kLegendaryCategoryLabels[place.categorie] ?? place.categorie,
                style: AppTheme.title(size: 12, color: AppColors.glow)),
          ),
          const SizedBox(height: 10),
          Text(place.nom, style: AppTheme.title(size: 22)),
          const SizedBox(height: 4),
          Text('${place.ville}, ${place.pays}${place.periode.isNotEmpty ? " — ${place.periode}" : ""}',
              style: AppTheme.ui(size: 13, color: AppColors.inkSoft)),
          const SizedBox(height: 16),
          if (!visited) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.arcaneLight.withValues(alpha: 0.4)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(place.teaser, style: AppTheme.body(size: 15, fontStyle: FontStyle.italic)),
                  const SizedBox(height: 10),
                  Text('L\'histoire complète de ce lieu se dévoile une fois que tu l\'as visité.',
                      style: AppTheme.ui(size: 12, color: AppColors.inkSoft)),
                ],
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onVisit,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.night, foregroundColor: AppColors.glow),
                child: const Text('🔮 J\'ai visité ce lieu'),
              ),
            ),
          ] else ...[
            Text(place.recit, style: AppTheme.body(size: 16)),
            const SizedBox(height: 14),
            GestureDetector(
              onTap: () => launchUrl(Uri.parse(place.source), mode: LaunchMode.externalApplication),
              child: Text('Source : ${place.source}', style: AppTheme.ui(size: 11.5, color: AppColors.arcane)),
            ),
            const SizedBox(height: 6),
            Text('Ce lieu fait maintenant partie de tes découvertes, visible dans ton grimoire.',
                style: AppTheme.ui(size: 12, color: AppColors.forest)),
          ],
          const SizedBox(height: 14),
          Text(
            'Contenu historique et folklorique à but culturel — ne remplace pas une visite respectueuse des lieux, parfois privés, et de leur histoire.',
            style: AppTheme.ui(size: 10.5, color: AppColors.inkSoft),
          ),
        ],
      ),
    );
  }
}
