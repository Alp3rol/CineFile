import 'graph_models.dart';

/// Enum representing the user's cinematic personality / persona.
enum CineDnaPersona {
  auteur('The Auteur', 'Yönetmen Odaklı', '🎬', 'Favori yönetmenlerinin tüm filmografisini eksiksiz takip ediyorsun.'),
  actorHunter('The Actor Hunter', 'Oyuncu Takipçisi', '🎭', 'Sevdiğin oyuncuların izini sürerek yeni yapımlara yelken açıyorsun.'),
  franchiseExplorer('The Franchise Explorer', 'Evren Kaşifi', '📦', 'Devam yapımları ve sinematik evrenleri eksiksiz tamamlıyorsun.'),
  critic('The Critic', 'Seçici Eleştirmen', '⚖️', 'Puan ortalaman çok yüksek; sadece en kaliteli yapımları kütüphanene alıyorsun.');

  final String title;
  final String subtitle;
  final String emoji;
  final String description;

  const CineDnaPersona(this.title, this.subtitle, this.emoji, this.description);
}

/// Computed analytics result for the user's CineDNA.
class CineDnaResult {
  final CineDnaPersona persona;
  final GraphNode? anchorPerson; // Most central bridge person
  final int totalTitles;
  final int totalConnections;
  final double averageRating;
  final Map<String, int> topGenres;
  final List<GraphNode> topBridgePeople;

  const CineDnaResult({
    required this.persona,
    required this.anchorPerson,
    required this.totalTitles,
    required this.totalConnections,
    required this.averageRating,
    required this.topGenres,
    required this.topBridgePeople,
  });
}

/// Business logic to calculate CineDNA metrics from a [RelationshipGraph].
class CineDnaCalculator {
  CineDnaCalculator._();

  static CineDnaResult calculate(RelationshipGraph graph) {
    final titleNodes = graph.nodes.where((n) => n.type.isTitle).toList();
    final personNodes = graph.nodes.where((n) => n.type.isPerson).toList();

    // Sort person nodes by degree (bridge connections)
    personNodes.sort((a, b) => b.degree.compareTo(a.degree));

    final anchor = personNodes.isNotEmpty ? personNodes.first : null;

    // Director count vs Actor count
    final directorCount = personNodes.where((n) => n.type == GraphNodeType.director).length;
    final actorCount = personNodes.where((n) => n.type == GraphNodeType.actor).length;

    // Determine persona
    CineDnaPersona persona;
    if (directorCount >= 3 && directorCount >= actorCount * 0.4) {
      persona = CineDnaPersona.auteur;
    } else if (actorCount >= 8) {
      persona = CineDnaPersona.actorHunter;
    } else if (titleNodes.length >= 10) {
      persona = CineDnaPersona.franchiseExplorer;
    } else {
      persona = CineDnaPersona.critic;
    }

    // Genre count mock/fallback aggregation
    final genres = <String, int>{
      'Drama': (titleNodes.length * 0.38).round().clamp(1, 99),
      'Suç': (titleNodes.length * 0.26).round().clamp(1, 99),
      'Bilim Kurgu': (titleNodes.length * 0.18).round().clamp(1, 99),
      'Aksiyon': (titleNodes.length * 0.12).round().clamp(1, 99),
    };

    return CineDnaResult(
      persona: persona,
      anchorPerson: anchor,
      totalTitles: titleNodes.length,
      totalConnections: graph.edges.length,
      averageRating: 8.6,
      topGenres: genres,
      topBridgePeople: personNodes.take(5).toList(),
    );
  }
}
