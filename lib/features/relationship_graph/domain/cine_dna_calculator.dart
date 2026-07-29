import 'graph_models.dart';
import '../../../core/constants/tmdb_genres.dart';
import '../../../l10n/app_localizations.dart';

/// Enum representing the user's cinematic personality / persona.
///
/// [title] stays on the enum because it is a fixed English epithet the design
/// shows verbatim in both languages, like a brand. The subtitle and
/// description are copy, so they moved to [CineDnaPersonaLabels] — a const
/// enum cannot localize them.
enum CineDnaPersona {
  auteur('The Auteur', '🎬'),
  actorHunter('The Actor Hunter', '🎭'),
  franchiseExplorer('The Franchise Explorer', '📦'),
  critic('The Critic', '⚖️');

  final String title;
  final String emoji;

  const CineDnaPersona(this.title, this.emoji);
}

extension CineDnaPersonaLabels on CineDnaPersona {
  String subtitle(AppLocalizations l10n) => switch (this) {
        CineDnaPersona.auteur => l10n.cineDnaPersonaAuteurTitle,
        CineDnaPersona.actorHunter => l10n.cineDnaPersonaActorHunterTitle,
        CineDnaPersona.franchiseExplorer => l10n.cineDnaPersonaFranchiseTitle,
        CineDnaPersona.critic => l10n.cineDnaPersonaCriticTitle,
      };

  String description(AppLocalizations l10n) => switch (this) {
        CineDnaPersona.auteur => l10n.cineDnaPersonaAuteurDescription,
        CineDnaPersona.actorHunter => l10n.cineDnaPersonaActorHunterDescription,
        CineDnaPersona.franchiseExplorer => l10n.cineDnaPersonaFranchiseDescription,
        CineDnaPersona.critic => l10n.cineDnaPersonaCriticDescription,
      };
}

/// Computed analytics result for the user's CineDNA.
class CineDnaResult {
  final CineDnaPersona persona;
  final GraphNode? anchorPerson; // Most central bridge person
  final int totalTitles;
  final int totalConnections;
  final double averageRating;
  final Map<int, int> topGenres;
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

    // Genre count mock/fallback aggregation. Keyed by TMDb genre id rather
    // than a Turkish name — these are fabricated numbers, but the key still
    // has to be language-independent so the screen can render the name in
    // whatever language the user is reading.
    final genres = <int, int>{
      TmdbGenre.drama: (titleNodes.length * 0.38).round().clamp(1, 99),
      TmdbGenre.crime: (titleNodes.length * 0.26).round().clamp(1, 99),
      TmdbGenre.scienceFiction: (titleNodes.length * 0.18).round().clamp(1, 99),
      TmdbGenre.action: (titleNodes.length * 0.12).round().clamp(1, 99),
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
