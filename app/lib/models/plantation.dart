class Plantation {
  final String especeId;
  final String? zoneId;
  final String date; // yyyy-MM-dd
  final int xpGained;

  const Plantation({
    required this.especeId,
    required this.zoneId,
    required this.date,
    required this.xpGained,
  });

  Map<String, dynamic> toJson() => {
        'especeId': especeId,
        'zoneId': zoneId,
        'date': date,
        'xpGained': xpGained,
      };

  factory Plantation.fromJson(Map<String, dynamic> json) {
    return Plantation(
      especeId: json['especeId'] as String,
      zoneId: json['zoneId'] as String?,
      date: json['date'] as String,
      xpGained: (json['xpGained'] as num).toInt(),
    );
  }
}
