class Species {
  final String id;
  final String nom;
  final String latin;
  final String icone;
  final String categorie; // arbre | arbuste | fleur | legume-fruit
  final List<String> tags;
  final String description;
  final int xpBase;
  final List<String> sourcesGraines;

  const Species({
    required this.id,
    required this.nom,
    required this.latin,
    required this.icone,
    required this.categorie,
    required this.tags,
    required this.description,
    required this.xpBase,
    required this.sourcesGraines,
  });

  factory Species.fromJson(Map<String, dynamic> json) {
    return Species(
      id: json['id'] as String,
      nom: json['nom'] as String,
      latin: json['latin'] as String,
      icone: json['icone'] as String,
      categorie: json['categorie'] as String,
      tags: (json['tags'] as List<dynamic>? ?? []).cast<String>(),
      description: json['description'] as String? ?? '',
      xpBase: (json['xpBase'] as num?)?.toInt() ?? 10,
      sourcesGraines: (json['sourcesGraines'] as List<dynamic>? ?? []).cast<String>(),
    );
  }
}
