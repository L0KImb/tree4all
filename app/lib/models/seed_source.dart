class SeedSource {
  final String id;
  final String nom;
  final String pays;
  final String type;
  final String icone;
  final String description;
  final String? url;
  final String? urlFr;
  final String? urlFrLabel;
  final String? urlBe;
  final String? urlBeLabel;

  const SeedSource({
    required this.id,
    required this.nom,
    required this.pays,
    required this.type,
    required this.icone,
    required this.description,
    this.url,
    this.urlFr,
    this.urlFrLabel,
    this.urlBe,
    this.urlBeLabel,
  });

  factory SeedSource.fromJson(Map<String, dynamic> json) {
    return SeedSource(
      id: json['id'] as String,
      nom: json['nom'] as String,
      pays: json['pays'] as String,
      type: json['type'] as String,
      icone: json['icone'] as String,
      description: json['description'] as String? ?? '',
      url: json['url'] as String?,
      urlFr: json['urlFr'] as String?,
      urlFrLabel: json['urlFrLabel'] as String?,
      urlBe: json['urlBe'] as String?,
      urlBeLabel: json['urlBeLabel'] as String?,
    );
  }

  /// Un lien "principal" utilisable pour un bouton simple.
  String? get primaryUrl => url ?? urlFr ?? urlBe;
}
