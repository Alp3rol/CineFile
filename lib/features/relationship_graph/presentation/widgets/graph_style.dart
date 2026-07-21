import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/graph_models.dart';

/// Central color + icon vocabulary for the graph, so nodes, edges, the legend,
/// the filter bar and the minimap all read from one source. Adding a node type
/// later (v2: writer/company/genre) means filling in one branch here.
class GraphStyle {
  GraphStyle._();

  static const Color movie = Color(0xFF4F8FF0); // blue
  static const Color tv = Color(0xFF9B6DFF); // purple
  static const Color actor = Color(0xFF2FD8C0); // turquoise
  static const Color director = AppTheme.ratingColor; // warm gold
  static const Color writer = Color(0xFFEB6F92); // rose
  static const Color producer = Color(0xFFF6A94A); // orange
  static const Color company = Color(0xFF8A93A6); // slate
  static const Color genre = Color(0xFF6BCB77); // green

  static Color colorFor(GraphNodeType type) {
    switch (type) {
      case GraphNodeType.movie:
        return movie;
      case GraphNodeType.tv:
        return tv;
      case GraphNodeType.actor:
        return actor;
      case GraphNodeType.director:
        return director;
      case GraphNodeType.writer:
        return writer;
      case GraphNodeType.producer:
        return producer;
      case GraphNodeType.company:
        return company;
      case GraphNodeType.genre:
        return genre;
    }
  }

  static IconData iconFor(GraphNodeType type) {
    switch (type) {
      case GraphNodeType.movie:
        return Icons.movie_rounded;
      case GraphNodeType.tv:
        return Icons.live_tv_rounded;
      case GraphNodeType.actor:
        return Icons.person_rounded;
      case GraphNodeType.director:
        return Icons.movie_creation_rounded;
      case GraphNodeType.writer:
        return Icons.edit_note_rounded;
      case GraphNodeType.producer:
        return Icons.workspace_premium_rounded;
      case GraphNodeType.company:
        return Icons.business_rounded;
      case GraphNodeType.genre:
        return Icons.local_offer_rounded;
    }
  }

  static Color edgeColor(GraphEdgeType type) => colorFor(type.personType);

  static String labelFor(GraphNodeType type) {
    switch (type) {
      case GraphNodeType.movie:
        return 'Film';
      case GraphNodeType.tv:
        return 'Dizi';
      case GraphNodeType.actor:
        return 'Oyuncu';
      case GraphNodeType.director:
        return 'Yönetmen';
      case GraphNodeType.writer:
        return 'Senarist';
      case GraphNodeType.producer:
        return 'Yapımcı';
      case GraphNodeType.company:
        return 'Yapım Şirketi';
      case GraphNodeType.genre:
        return 'Tür';
    }
  }
}
