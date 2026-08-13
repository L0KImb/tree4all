import 'package:flutter/material.dart';

import '../models/species.dart';
import '../models/zone.dart';
import '../state/catalog.dart';
import '../theme/app_theme.dart';

class AddPlantationSheet extends StatefulWidget {
  final Catalog catalog;
  final Zone? preselectedZone;
  final VoidCallback onBack;
  final void Function(Species species, Zone? zone) onConfirm;

  const AddPlantationSheet({
    super.key,
    required this.catalog,
    required this.preselectedZone,
    required this.onBack,
    required this.onConfirm,
  });

  @override
  State<AddPlantationSheet> createState() => _AddPlantationSheetState();
}

class _AddPlantationSheetState extends State<AddPlantationSheet> {
  String _category = 'arbre';
  Species? _selected;
  Zone? _zone;

  @override
  void initState() {
    super.initState();
    _zone = widget.preselectedZone;
  }

  @override
  Widget build(BuildContext context) {
    final speciesInCategory = widget.catalog.speciesByCategory(_category);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(22, 8, 22, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: widget.onBack,
            child: Text('← Retour au grimoire', style: AppTheme.ui(size: 13, color: AppColors.arcane)),
          ),
          const SizedBox(height: 10),
          Text('Ajouter une plantation', style: AppTheme.title(size: 21)),
          const SizedBox(height: 6),
          Text('Choisis ce que tu as planté : chaque pousse nourrit ton grimoire.', style: AppTheme.body(size: 15)),
          const SizedBox(height: 14),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: kCategoryLabels.entries.map((e) {
                final active = e.key == _category;
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ChoiceChip(
                    label: Text(e.value, style: AppTheme.ui(size: 13, color: active ? Colors.white : AppColors.ink)),
                    selected: active,
                    selectedColor: AppColors.arcane,
                    backgroundColor: Colors.white.withValues(alpha: 0.5),
                    onSelected: (_) => setState(() {
                      _category = e.key;
                      _selected = null;
                    }),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 14),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 1.1,
            children: speciesInCategory.map((s) {
              final selected = s.id == _selected?.id;
              return GestureDetector(
                onTap: () => setState(() => _selected = s),
                child: Container(
                  decoration: BoxDecoration(
                    color: selected ? AppColors.goldBright.withValues(alpha: 0.25) : Colors.white.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: selected ? AppColors.goldBright : Colors.transparent, width: 2),
                  ),
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(s.icone, style: const TextStyle(fontSize: 24)),
                      const SizedBox(height: 4),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Text(s.nom, textAlign: TextAlign.center, style: AppTheme.ui(size: 11)),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          Text('ZONE (OPTIONNEL)', style: AppTheme.ui(size: 13, color: AppColors.arcane)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.gold.withValues(alpha: 0.5)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<Zone?>(
                isExpanded: true,
                value: _zone,
                hint: const Text('Ailleurs / mon jardin'),
                items: [
                  const DropdownMenuItem<Zone?>(value: null, child: Text('Ailleurs / mon jardin')),
                  // Limite d'affichage pour la liste déroulante (perf UI) — les 1800 zones
                  // restent toutes visibles/cliquables sur la carte, seul ce sélecteur manuel est plafonné.
                  ...widget.catalog.zones.take(500).map((z) => DropdownMenuItem<Zone?>(
                        value: z,
                        child: Text('${z.nom} — ${z.ville}', overflow: TextOverflow.ellipsis),
                      )),
                ],
                onChanged: (z) => setState(() => _zone = z),
              ),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _selected == null ? null : () => widget.onConfirm(_selected!, _zone),
              child: const Text('🪄 Planter'),
            ),
          ),
        ],
      ),
    );
  }
}
