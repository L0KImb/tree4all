class Rank {
  final String id;
  final int seuilXp;
  final String nom;
  final String icone;
  final String flavor;
  final String? inspiration;

  const Rank({
    required this.id,
    required this.seuilXp,
    required this.nom,
    required this.icone,
    required this.flavor,
    this.inspiration,
  });

  factory Rank.fromJson(Map<String, dynamic> json) {
    return Rank(
      id: json['id'] as String,
      seuilXp: (json['seuilXp'] as num).toInt(),
      nom: json['nom'] as String,
      icone: json['icone'] as String,
      flavor: json['flavor'] as String? ?? '',
      inspiration: json['inspiration'] as String?,
    );
  }
}
