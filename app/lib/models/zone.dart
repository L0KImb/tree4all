class Zone {
  final String id;
  final String nom;
  final String ville;
  final String pays;
  final String type; // permis | naturelle | association
  final String sousType;
  final double lat;
  final double lng;
  final String description;
  final String regles;
  final String source;
  final List<String> especes;

  const Zone({
    required this.id,
    required this.nom,
    required this.ville,
    required this.pays,
    required this.type,
    required this.sousType,
    required this.lat,
    required this.lng,
    required this.description,
    required this.regles,
    required this.source,
    required this.especes,
  });

  factory Zone.fromJson(Map<String, dynamic> json) {
    return Zone(
      id: json['id'] as String,
      nom: json['nom'] as String,
      ville: json['ville'] as String,
      pays: json['pays'] as String,
      type: json['type'] as String,
      sousType: json['sousType'] as String? ?? '',
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      description: json['description'] as String? ?? '',
      regles: json['regles'] as String? ?? '',
      source: json['source'] as String? ?? '',
      especes: (json['especes'] as List<dynamic>? ?? []).cast<String>(),
    );
  }
}
