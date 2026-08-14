import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../models/zone.dart';
import '../models/species.dart';
import '../services/gpu_service.dart';
import '../state/catalog.dart';
import '../state/player_state.dart';
import '../theme/app_theme.dart';
import '../sheets/zone_sheet.dart';
import '../sheets/grimoire_sheet.dart';
import '../sheets/add_plantation_sheet.dart';
import '../sheets/levelup_sheet.dart';

class MapScreen extends StatefulWidget {
  final Catalog catalog;
  const MapScreen({super.key, required this.catalog});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  String _filter = 'all';
  bool _checkZoningMode = false;
  bool _checkingZoning = false;
  bool _showDemoBanner = true;

  List<Zone> get _filteredZones {
    if (_filter == 'all') return widget.catalog.zones;
    return widget.catalog.zones.where((z) => z.type == _filter).toList();
  }

  Color _zoneColor(String type) {
    switch (type) {
      case 'naturelle':
        return AppColors.arcane;
      case 'association':
        return AppColors.gold;
      default:
        return AppColors.forest;
    }
  }

  String _zoneIcon(String type) {
    switch (type) {
      case 'naturelle':
        return '🌲';
      case 'association':
        return '🤝';
      default:
        return '🌱';
    }
  }

  void _openZoneSheet(Zone zone) {
    _showSheet(
      ZoneSheet(
        zone: zone,
        catalog: widget.catalog,
        onPlantHere: () {
          Navigator.pop(context);
          _openAddPlantation(preselectedZone: zone);
        },
      ),
    );
    _mapController.move(LatLng(zone.lat, zone.lng), _mapController.camera.zoom < 14 ? 14 : _mapController.camera.zoom);
  }

  void _openGrimoire() {
    final player = context.read<PlayerState>();
    _showSheet(
      GrimoireSheet(
        catalog: widget.catalog,
        player: player,
        onAddPlantation: () {
          Navigator.pop(context);
          _openAddPlantation(preselectedZone: null);
        },
      ),
    );
  }

  void _openAddPlantation({Zone? preselectedZone}) {
    _showSheet(
      AddPlantationSheet(
        catalog: widget.catalog,
        preselectedZone: preselectedZone,
        onBack: () {
          Navigator.pop(context);
          _openGrimoire();
        },
        onConfirm: (species, zone) => _confirmPlant(species, zone),
      ),
    );
  }

  Future<void> _confirmPlant(Species species, Zone? zone) async {
    final player = context.read<PlayerState>();
    final before = widget.catalog.rankForXp(player.xp).current;
    final isFirstTime = !player.plantations.any((p) => p.especeId == species.id);
    final zoneBonus = zone != null;

    final now = DateTime.now();
    final date = '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    final plantation = await player.addPlantation(
      especeId: species.id,
      xpBase: species.xpBase,
      zoneId: zone?.id,
      date: date,
    );

    final after = widget.catalog.rankForXp(player.xp).current;
    final rankChanged = after.id != before.id;

    if (!mounted) return;
    Navigator.pop(context); // ferme le formulaire

    _showSheet(
      LevelUpSheet(
        species: species,
        xpGained: plantation.xpGained,
        firstTimeBonus: isFirstTime,
        zoneBonus: zoneBonus,
        newRank: rankChanged ? after : null,
        onContinue: () {
          Navigator.pop(context);
          _openGrimoire();
        },
      ),
    );
  }

  void _showSheet(Widget content) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.parchment,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.82),
      builder: (context) => SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: content,
        ),
      ),
    );
  }

  Future<void> _handleMapTap(LatLng point) async {
    if (!_checkZoningMode) return;
    setState(() => _checkingZoning = true);
    final results = await Future.wait([
      GpuService.lookup(point.latitude, point.longitude),
      GpuService.lookupNature(point.latitude, point.longitude),
    ]);
    setState(() => _checkingZoning = false);
    if (!mounted) return;
    final info = results[0] as GpuZoneInfo?;
    final natureInfos = results[1] as List<NatureZoneInfo>;

    if (info == null && natureInfos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Aucune donnée de zonage disponible ici (hors France, ou zone non numérisée)."),
      ));
      return;
    }
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.parchment,
        title: Text(info != null ? 'Zonage : ${info.libelle} (${info.typezone})' : 'Zones protégées', style: AppTheme.title(size: 16)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (info != null) ...[
                if (info.libelong.isNotEmpty) Text(info.libelong, style: AppTheme.body(size: 14, color: AppColors.inkSoft)),
                const SizedBox(height: 8),
                Text(info.resume, style: AppTheme.body(size: 14)),
              ],
              if (natureInfos.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text('ZONES PROTÉGÉES À CET ENDROIT', style: AppTheme.ui(size: 12, color: AppColors.arcane)),
                const SizedBox(height: 6),
                ...natureInfos.map((n) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text('🛡️ ${n.label} — ${n.nom}', style: AppTheme.body(size: 14)),
                    )),
              ],
              const SizedBox(height: 10),
              Text('Source : Géoportail de l\'Urbanisme et API Nature (IGN, gouvernement français). Une indication favorable n\'est jamais une autorisation automatique de planter.',
                  style: AppTheme.ui(size: 11, color: AppColors.inkSoft)),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Fermer')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerState>();
    final r = widget.catalog.rankForXp(player.xp);
    double progress = 1;
    if (r.next != null) {
      final span = r.next!.seuilXp - r.current.seuilXp;
      progress = span > 0 ? ((player.xp - r.current.seuilXp) / span).clamp(0, 1).toDouble() : 1;
    }

    final markers = _filteredZones.map((zone) {
      return Marker(
        point: LatLng(zone.lat, zone.lng),
        width: 38,
        height: 38,
        child: GestureDetector(
          onTap: () => _openZoneSheet(zone),
          child: _ZoneMarker(color: _zoneColor(zone.type), icon: _zoneIcon(zone.type)),
        ),
      );
    }).toList();

    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: const LatLng(48.86, 2.35),
              initialZoom: 12,
              onTap: (tapPos, point) => _handleMapTap(point),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.tree4all.app',
              ),
              MarkerClusterLayerWidget(
                options: MarkerClusterLayerOptions(
                  maxClusterRadius: 50,
                  size: const Size(42, 42),
                  markers: markers,
                  builder: (context, clusterMarkers) => Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.arcane,
                      border: Border.all(color: AppColors.goldBright, width: 2),
                    ),
                    alignment: Alignment.center,
                    child: Text('${clusterMarkers.length}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ),
              ),
            ],
          ),

          if (_showDemoBanner)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(14, 8, 44, 8),
                color: const Color(0xFF5C3A1E),
                child: Stack(
                  children: [
                    Text(
                      '🌍 ${widget.catalog.zones.length} zones réelles (Paris, GPSO, Bruxelles). Couverture partielle ailleurs — touche 🔍 pour vérifier un zonage n\'importe où en France.',
                      style: AppTheme.ui(size: 12, color: AppColors.glow, weight: FontWeight.w500),
                    ),
                    Positioned(
                      right: -30,
                      top: -6,
                      child: IconButton(
                        icon: const Icon(Icons.close, color: AppColors.glow, size: 20),
                        onPressed: () => setState(() => _showDemoBanner = false),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          Positioned(
            top: _showDemoBanner ? 52 : 12,
            left: 12,
            right: 12,
            child: Row(
              children: [
                Text('🌳', style: const TextStyle(fontSize: 22)),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.95), borderRadius: BorderRadius.circular(999)),
                    child: TextField(
                      decoration: InputDecoration(border: InputBorder.none, hintText: 'Chercher une ville…', hintStyle: AppTheme.body(size: 14, color: Colors.grey)),
                      style: AppTheme.body(size: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _openGrimoire,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [Color(0xFF3A2760), AppColors.night])),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 40,
                          height: 40,
                          child: CircularProgressIndicator(value: progress.toDouble(), strokeWidth: 2.5, color: AppColors.goldBright, backgroundColor: Colors.white24),
                        ),
                        Text(r.current.icone, style: const TextStyle(fontSize: 16)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          Positioned(
            left: 12,
            right: 12,
            bottom: 20,
            child: SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _FilterChip(label: 'Tout', active: _filter == 'all', onTap: () => setState(() => _filter = 'all')),
                  _FilterChip(label: '🌱 Permis', active: _filter == 'permis', onTap: () => setState(() => _filter = 'permis')),
                  _FilterChip(label: '🌲 Naturelle', active: _filter == 'naturelle', onTap: () => setState(() => _filter = 'naturelle')),
                  _FilterChip(label: '🤝 Associatif', active: _filter == 'association', onTap: () => setState(() => _filter = 'association')),
                ],
              ),
            ),
          ),

          Positioned(
            right: 12,
            bottom: 74,
            child: FloatingActionButton(
              heroTag: 'zoning',
              backgroundColor: _checkZoningMode ? AppColors.goldBright : Colors.white,
              onPressed: () => setState(() => _checkZoningMode = !_checkZoningMode),
              child: _checkingZoning
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('🔍', style: TextStyle(fontSize: 18)),
            ),
          ),
          Positioned(
            right: 12,
            bottom: 138,
            child: FloatingActionButton(
              heroTag: 'plant',
              backgroundColor: AppColors.arcane,
              onPressed: () => _openAddPlantation(),
              child: const Text('🪄', style: TextStyle(fontSize: 20)),
            ),
          ),
        ],
      ),
    );
  }
}

class _ZoneMarker extends StatelessWidget {
  final Color color;
  final String icon;
  const _ZoneMarker({required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [Colors.white, color]),
        border: Border.all(color: AppColors.gold, width: 2),
        boxShadow: [BoxShadow(color: AppColors.goldBright.withValues(alpha: 0.4), blurRadius: 6, spreadRadius: 1)],
      ),
      alignment: Alignment.center,
      child: Text(icon, style: const TextStyle(fontSize: 16)),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _FilterChip({required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            gradient: active ? const LinearGradient(colors: [AppColors.arcaneLight, AppColors.arcane]) : null,
            color: active ? null : Colors.white.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(999),
          ),
          alignment: Alignment.center,
          child: Text(label, style: AppTheme.ui(size: 13, color: active ? Colors.white : AppColors.forestDeep)),
        ),
      ),
    );
  }
}
