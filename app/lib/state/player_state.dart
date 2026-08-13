import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/plantation.dart';

class PlantResult {
  final Plantation plantation;
  final bool leveledUp;
  PlantResult(this.plantation, this.leveledUp);
}

/// État du joueur : XP et journal de plantations, persistés en local
/// (équivalent du localStorage du prototype web).
class PlayerState extends ChangeNotifier {
  static const _prefsKey = 'tree4all_grimoire_v1';

  int xp = 0;
  final List<Plantation> plantations = [];
  bool _loaded = false;

  Future<void> load() async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw != null) {
      final data = jsonDecode(raw) as Map<String, dynamic>;
      xp = (data['xp'] as num?)?.toInt() ?? 0;
      plantations.clear();
      for (final e in (data['plantations'] as List<dynamic>? ?? [])) {
        plantations.add(Plantation.fromJson(e as Map<String, dynamic>));
      }
    }
    _loaded = true;
    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, jsonEncode({
      'xp': xp,
      'plantations': plantations.map((p) => p.toJson()).toList(),
    }));
  }

  /// Ajoute une plantation, calcule l'XP (base * bonus première fois * bonus zone),
  /// persiste, et notifie. Le calcul de montée de rang est fait par l'appelant
  /// (il a besoin du Catalog pour comparer l'ancien/nouveau rang).
  Future<Plantation> addPlantation({
    required String especeId,
    required int xpBase,
    String? zoneId,
    required String date,
  }) async {
    final isFirstTime = !plantations.any((p) => p.especeId == especeId);
    final zoneBonus = zoneId != null;
    final multiplier = 1 + (isFirstTime ? 0.5 : 0) + (zoneBonus ? 0.2 : 0);
    final gained = (xpBase * multiplier).round();

    final plantation = Plantation(especeId: especeId, zoneId: zoneId, date: date, xpGained: gained);
    plantations.add(plantation);
    xp += gained;
    await _persist();
    notifyListeners();
    return plantation;
  }
}
