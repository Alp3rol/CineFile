import 'package:flutter/material.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../domain/map_graph.dart';

/// Shown when the user taps a title↔title link: the people who connect the two
/// titles. Each can be opened (profile) or hidden from the whole graph.
class LinkPeopleSheet extends StatelessWidget {
  final String titleA;
  final String titleB;
  final TitleLink link;
  final ValueChanged<PersonRef> onOpenProfile;
  final ValueChanged<PersonRef> onHide;

  const LinkPeopleSheet({
    super.key,
    required this.titleA,
    required this.titleB,
    required this.link,
    required this.onOpenProfile,
    required this.onHide,
  });

  static void show(
    BuildContext context, {
    required String titleA,
    required String titleB,
    required TitleLink link,
    required ValueChanged<PersonRef> onOpenProfile,
    required ValueChanged<PersonRef> onHide,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (c) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(c).viewInsets.bottom),
        child: LinkPeopleSheet(
          titleA: titleA,
          titleB: titleB,
          link: link,
          onOpenProfile: onOpenProfile,
          onHide: onHide,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Deduplicate people by key (a person can be added under multiple pairs).
    final seen = <String>{};
    final people = [
      for (final p in link.people)
        if (seen.add(p.key)) p,
    ];
    return GlassContainer(
      borderRadius: 24,
      opacity: 0.92,
      padding: const EdgeInsets.all(20),
      child: ConstrainedBox(
        constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 16),
            Text('$titleA  ↔  $titleB',
                style: Theme.of(context).textTheme.titleMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
            Text('${people.length} ortak kişi',
                style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 12),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: people.length,
                separatorBuilder: (_, _) => const SizedBox(height: 4),
                itemBuilder: (context, i) => _tile(people[i]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tile(PersonRef p) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      onTap: () => onOpenProfile(p),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: SizedBox(
          width: 40,
          height: 40,
          child: AppNetworkImage(
            imageUrl: p.profilePath == null
                ? ''
                : '${ApiConstants.imagePathW185}${p.profilePath}',
            seed: p.name,
          ),
        ),
      ),
      title: Text(p.name,
          style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14)),
      subtitle: Text(p.isDirector ? 'Yönetmen' : 'Oyuncu',
          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
      trailing: IconButton(
        tooltip: 'Grafta gizle',
        onPressed: () => onHide(p),
        icon: const Icon(Icons.visibility_off_outlined,
            size: 18, color: AppTheme.textSecondary),
      ),
    );
  }
}
