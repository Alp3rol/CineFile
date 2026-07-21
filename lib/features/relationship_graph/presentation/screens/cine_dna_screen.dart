import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../domain/cine_dna_calculator.dart';
import '../../domain/graph_models.dart';
import '../widgets/graph_style.dart';

/// Full-screen Spotify Wrapped style analytics page for CineDNA.
class CineDnaScreen extends StatelessWidget {
  final RelationshipGraph graph;

  const CineDnaScreen({
    super.key,
    required this.graph,
  });

  static void navigate(BuildContext context, RelationshipGraph graph) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CineDnaScreen(graph: graph),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dna = CineDnaCalculator.calculate(graph);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: const [
            Text('🧬 ', style: TextStyle(fontSize: 20)),
            Text('CineDNA Analitiği',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close_rounded),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Persona Header Banner (Spotify Wrapped Style)
            GlassContainer(
              borderRadius: 24,
              padding: const EdgeInsets.all(20),
              color: AppTheme.accentColor.withValues(alpha: 0.15),
              border: Border.all(
                color: AppTheme.accentColor.withValues(alpha: 0.4),
                width: 1.5,
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.accentColor.withValues(alpha: 0.25),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.accentColor.withValues(alpha: 0.4),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                    child: Text(
                      dna.persona.emoji,
                      style: const TextStyle(fontSize: 42),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    dna.persona.title,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dna.persona.subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.ratingColor,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    dna.persona.description,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.4,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 2. The Anchor Person (Kütüphanenin Omurgası)
            const Text(
              '👑 Kütüphanenin Omurgası',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            if (dna.anchorPerson != null)
              GlassContainer(
                borderRadius: 18,
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: GraphStyle.colorFor(dna.anchorPerson!.type),
                          width: 2.5,
                        ),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: (dna.anchorPerson!.imageUrl != null &&
                              dna.anchorPerson!.imageUrl!.isNotEmpty)
                          ? AppNetworkImage(
                              imageUrl: dna.anchorPerson!.imageUrl!,
                              seed: dna.anchorPerson!.label,
                              fit: BoxFit.cover,
                            )
                          : Center(
                              child: Icon(
                                GraphStyle.iconFor(dna.anchorPerson!.type),
                                color: GraphStyle.colorFor(dna.anchorPerson!.type),
                              ),
                            ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            dna.anchorPerson!.label,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Kütüphanendeki ${dna.anchorPerson!.degree} farklı yapımı birbirine bağlıyor.',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 24),

            // 3. Quick Stats Grid
            Row(
              children: [
                Expanded(
                  child: GlassContainer(
                    borderRadius: 16,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('🎬 Toplam Yapım',
                            style: TextStyle(
                                fontSize: 11, color: AppTheme.textSecondary)),
                        const SizedBox(height: 6),
                        Text(
                          '${dna.totalTitles}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GlassContainer(
                    borderRadius: 16,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('🔗 Bağlantı Ağı',
                            style: TextStyle(
                                fontSize: 11, color: AppTheme.textSecondary)),
                        const SizedBox(height: 6),
                        Text(
                          '${dna.totalConnections}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2FD8C0),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 4. Top Bridge Connectors
            const Text(
              '🌉 En Etkili Bağlantı Köprüleri',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            GlassContainer(
              borderRadius: 18,
              padding: const EdgeInsets.all(14),
              child: Column(
                children: dna.topBridgePeople.map((person) {
                  final color = GraphStyle.colorFor(person.type);
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        Icon(GraphStyle.iconFor(person.type),
                            size: 16, color: color),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            person.label,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${person.degree} Bağlantı',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: color,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
