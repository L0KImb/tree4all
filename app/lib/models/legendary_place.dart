class LegendaryPlace {
  final String id;
  final String nom;
  final String ville;
  final String pays;
  final String categorie; // megalithe | sorcellerie | folklore | paien
  final String periode;
  final double lat;
  final double lng;
  final String teaser;
  final String recit;
  final String source;

  const LegendaryPlace({
    required this.id,
    required this.nom,
    required this.ville,
    required this.pays,
    required this.categorie,
    required this.periode,
    required this.lat,
    required this.lng,
    required this.teaser,
    required this.recit,
    required this.source,
  });

  factory LegendaryPlace.fromJson(Map<String, dynamic> json) {
    return LegendaryPlace(
      id: json['id'] as String,
      nom: json['nom'] as String,
      ville: json['ville'] as String,
      pays: json['pays'] as String,
      categorie: json['categorie'] as String,
      periode: json['periode'] as String? ?? '',
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      teaser: json['teaser'] as String? ?? '',
      recit: json['recit'] as String? ?? '',
      source: json['source'] as String? ?? '',
    );
  }
}

const Map<String, String> kLegendaryCategoryLabels = {
  'megalithe': '🗿 Mégalithe',
  'sorcellerie': '🕯️ Histoire de sorcellerie',
  'folklore': '👹 Folklore local',
  'paien': '🌙 Site païen',
};

const String kLegendaryIcon = '🔮';
