import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/database/database_provider.dart';
import '../../../../core/database/duplicate_cleanup.dart';
import '../../../../core/observability/error_reporting.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/premium_toast.dart';

// Lets the user review and bulk-delete duplicate diary entries left behind
// by the old "+" quick-add bug (see episode_logging.dart's
// advanceEpisodeProgress) — multiple log entries for the same show on the
// same day. Reachable from Settings → Veri Yönetimi & Yedekleme.
class DuplicateCleanupScreen extends ConsumerStatefulWidget {
  const DuplicateCleanupScreen({super.key});

  @override
  ConsumerState<DuplicateCleanupScreen> createState() =>
      _DuplicateCleanupScreenState();
}

class _DuplicateCleanupScreenState
    extends ConsumerState<DuplicateCleanupScreen> {
  final Set<String> _selectedKeys = {};
  bool _selectionInitialized = false;
  bool _isCleaning = false;

  String _formatDay(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';

  Future<void> _cleanupSelected(List<DuplicateWatchGroup> groups) async {
    final toClean = groups.where((g) => _selectedKeys.contains(g.key)).toList();
    if (toClean.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        title: Text(
          AppLocalizations.of(context).duplicateCleanupConfirmTitle,
          style: const TextStyle(color: Colors.white),
        ),
        content: Text(
          AppLocalizations.of(
            context,
          ).duplicateCleanupConfirmBody(toClean.length),
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(
              AppLocalizations.of(context).commonCancel,
              style: const TextStyle(color: Colors.white70),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(
              AppLocalizations.of(context).commonDelete,
              style: const TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _isCleaning = true);
    // Each group targets a different show, so its Firestore/DB calls are
    // independent — run them concurrently instead of one group at a time.
    final results = await Future.wait(
      toClean.map((group) async {
        try {
          await cleanupDuplicateGroup(ref, group);
          return true;
        } catch (error, stackTrace) {
          reportError(error, stackTrace, where: 'duplicateCleanup.group');
          return false;
        }
      }),
    );
    final failureCount = results.where((success) => !success).length;
    if (!mounted) return;
    setState(() {
      _isCleaning = false;
      _selectedKeys.clear();
    });

    if (failureCount == 0) {
      showPremiumToast(
        context,
        AppLocalizations.of(context).duplicateCleanupCleaned(toClean.length),
      );
    } else {
      showPremiumToast(
        context,
        AppLocalizations.of(
          context,
        ).duplicateCleanupPartial(toClean.length - failureCount, failureCount),
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final recordsAsync = ref.watch(allWatchRecordsProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.arrow_back_rounded,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      AppLocalizations.of(context).settingsCleanDuplicates,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: recordsAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AppTheme.accentColor),
                ),
                error: (e, _) => Center(
                  child: Text(
                    AppLocalizations.of(
                      context,
                    ).duplicateCleanupLoadError(e.toString()),
                    style: const TextStyle(color: AppTheme.textSecondary),
                  ),
                ),
                data: (records) {
                  final groups = findDuplicateWatchGroups(records);
                  if (groups.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          AppLocalizations.of(context).duplicateCleanupNone,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    );
                  }

                  // Default: everything pre-selected the first time groups load.
                  if (!_selectionInitialized) {
                    _selectionInitialized = true;
                    _selectedKeys.addAll(groups.map((g) => g.key));
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          AppLocalizations.of(
                            context,
                          ).duplicateCleanupIntro(groups.length),
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: groups.length,
                          itemBuilder: (context, index) {
                            final group = groups[index];
                            final selected = _selectedKeys.contains(group.key);
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: GlassContainer(
                                padding: const EdgeInsets.all(12),
                                borderRadius: 14,
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: AppNetworkImage(
                                        imageUrl: group.movie.posterPath != null
                                            ? '${ApiConstants.imagePathW500}${group.movie.posterPath}'
                                            : '',
                                        seed: group.movie.title,
                                        width: 44,
                                        height: 64,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            group.movie.title,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.copyWith(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            AppLocalizations.of(
                                              context,
                                            ).duplicateCleanupGroupSummary(
                                              _formatDay(group.day),
                                              group.records.length,
                                              group.toDelete.length,
                                            ),
                                            style: Theme.of(
                                              context,
                                            ).textTheme.labelLarge,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Checkbox(
                                      value: selected,
                                      activeColor: AppTheme.accentColor,
                                      onChanged: _isCleaning
                                          ? null
                                          : (v) {
                                              setState(() {
                                                if (v == true) {
                                                  _selectedKeys.add(group.key);
                                                } else {
                                                  _selectedKeys.remove(
                                                    group.key,
                                                  );
                                                }
                                              });
                                            },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.accentColor,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: _isCleaning || _selectedKeys.isEmpty
                                ? null
                                : () => _cleanupSelected(groups),
                            child: _isCleaning
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.black,
                                    ),
                                  )
                                : Text(
                                    AppLocalizations.of(
                                      context,
                                    ).duplicateCleanupAction(
                                      _selectedKeys.length,
                                    ),
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
