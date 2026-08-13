import 'dart:convert';
import 'package:http/http.dart' as http;

class GpuZoneInfo {
  final String typezone; // U, A, N, Ah, Nh, AUc, AUs...
  final String libelle;
  final String libelong;
  final String? reglementPdf;

  const GpuZoneInfo({
    required this.typezone,
    required this.libelle,
    required this.libelong,
    this.reglementPdf,
  });

  String get resume {
    switch (typezone) {
      case 'N':
        return 'Zone naturelle et forestière — la plantation y est en général cohérente, mais toute construction/aménagement reste très encadré. Vérifie le règlement local.';
      case 'A':
        return 'Zone agricole — usage principalement dédié à l\'agriculture. La plantation citoyenne y est rarement le bon cadre sans accord du propriétaire/exploitant.';
      case 'U':
        return 'Zone urbanisée — c\'est ici que les dispositifs municipaux type "permis de végétaliser" s\'appliquent le plus souvent (voir les pastilles sur la carte).';
      default:
        return 'Zone à urbaniser ou constructible sous condition — vérifie le règlement local avant toute plantation.';
    }
  }
}

/// Client pour l'API REST officielle et gratuite du Géoportail de l'Urbanisme
/// (gouvernement français) — zonage PLU (U/A/N) pour n'importe quel point du
/// territoire français. Gratuit, sans clé API.
/// ATTENTION : ce zonage est une indication réglementaire, PAS une autorisation
/// de planter — toujours l'annoncer clairement dans l'UI.
class GpuService {
  static Future<GpuZoneInfo?> lookup(double lat, double lon) async {
    final uri = Uri.parse(
      'https://www.geoportail-urbanisme.gouv.fr/api/feature-info/du'
      '?lon=$lon&lat=$lat&typeName=zone_urba',
    );
    try {
      final res = await http.get(uri).timeout(const Duration(seconds: 8));
      if (res.statusCode != 200) return null;
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final features = data['features'] as List<dynamic>?;
      if (features == null || features.isEmpty) return null;
      final props = (features.first as Map<String, dynamic>)['properties'] as Map<String, dynamic>;
      final typezone = props['typezone'] as String?;
      if (typezone == null) return null;
      return GpuZoneInfo(
        typezone: typezone,
        libelle: props['libelle'] as String? ?? typezone,
        libelong: props['libelong'] as String? ?? '',
        reglementPdf: props['nomfic'] as String?,
      );
    } catch (_) {
      return null;
    }
  }
}
