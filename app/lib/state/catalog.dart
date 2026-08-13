import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

import '../models/zone.dart';
import '../models/species.dart';
import '../models/rank.dart';
import '../models/seed_source.dart';

/// Charge une fois toutes les données embarquées (assets/data/*.json)
/// et les rend disponibles en mémoire pour le reste de l'app.
class Catalog {
  final List<Zone> zones;
  final List<Species> species;
  final Map<String, Species> speciesById;
  final List<Rank> ranks;
  final Map<String, SeedSource> seedSourcesById;

  Catalog({
    required this.zones,
    required this.species,
    required this.ranks,
    required this.seedSourcesById,
  }) : speciesById = {for (final s in species) s.id: s};

  static Future<Catalog> load() async {
    final results = await Future.wait([
      rootBundle.loadString('assets/data/zones.json'),
      rootBundle.loadString('assets/data/especes.json'),
      rootBundle.loadString('assets/data/rangs.json'),
      rootBundle.loadString('assets/data/sources-graines.json'),
    ]);

    final zonesJson = jsonDecode(results[0]) as List<dynamic>;
    final speciesJson = jsonDecode(results[1]) as List<dynamic>;
    final ranksJson = jsonDecode(results[2]) as List<dynamic>;
    final sourcesJson = jsonDecode(results[3]) as List<dynamic>;

    final zones = zonesJson.map((e) => Zone.fromJson(e as Map<String, dynamic>)).toList();
    final species = speciesJson.map((e) => Species.fromJson(e as Map<String, dynamic>)).toList();
    final ranks = ranksJson.map((e) => Rank.fromJson(e as Map<String, dynamic>)).toList()
      ..sort((a, b) => a.seuilXp.compareTo(b.seuilXp));
    final sources = {
      for (final e in sourcesJson) (e as Map<String, dynamic>)['id'] as String: SeedSource.fromJson(e)
    };

    return Catalog(zones: zones, species: species, ranks: ranks, seedSourcesById: sources);
  }

  List<Species> speciesByCategory(String categorie) =>
      species.where((s) => s.categorie == categorie).toList();

  ({Rank current, Rank? next}) rankForXp(int xp) {
    Rank current = ranks.first;
    Rank? next = ranks.length > 1 ? ranks[1] : null;
    for (var i = 0; i < ranks.length; i++) {
      if (xp >= ranks[i].seuilXp) {
        current = ranks[i];
        next = i + 1 < ranks.length ? ranks[i + 1] : null;
      }
    }
    return (current: current, next: next);
  }
}
