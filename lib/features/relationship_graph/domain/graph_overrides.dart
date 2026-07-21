import 'graph_models.dart';

/// The user's manual curation for one title: people they added (that TMDb
/// missed or billed too low) and person keys they removed from just this title.
class TitleOverride {
  final List<CreditPerson> added;
  final Set<String> removedKeys;

  const TitleOverride({this.added = const [], this.removedKeys = const {}});
}

/// All of a user's graph curation, merged into the graph build:
/// per-title adds/removes plus a global set of hidden person keys.
///
/// [perTitle] is keyed by the graph title id (`'title:$tmdbId:$isTv'`) so it
/// drops straight into the builder without a separate MovieKey lookup.
class GraphOverrides {
  final Map<String, TitleOverride> perTitle;
  final Set<String> hiddenKeys;

  const GraphOverrides({this.perTitle = const {}, this.hiddenKeys = const {}});

  static const GraphOverrides empty = GraphOverrides();

  TitleOverride forTitle(String titleId) =>
      perTitle[titleId] ?? const TitleOverride();

  /// Keys of every person the user has manually added anywhere. Such a person
  /// is "promoted": included in EVERY title they appear in (bypassing the
  /// prominence filter), so the intended bridge actually forms even when they're
  /// billed low in their other title.
  Set<String> get promotedKeys => {
        for (final t in perTitle.values)
          for (final p in t.added) personKey(p),
      };
}
