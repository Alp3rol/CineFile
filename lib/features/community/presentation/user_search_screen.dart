import 'dart:async';
import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/ui/ui.dart';
import 'user_search_provider.dart';
import 'widgets/user_search_result_tile.dart';

class UserSearchScreen extends ConsumerStatefulWidget {
  const UserSearchScreen({super.key});

  @override
  ConsumerState<UserSearchScreen> createState() => _UserSearchScreenState();
}

class _UserSearchScreenState extends ConsumerState<UserSearchScreen> {
  final TextEditingController _controller = TextEditingController();
  Timer? _debounceTimer;

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    setState(() {}); // updates the clear-button visibility
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 350), () {
      ref.read(userSearchQueryProvider.notifier).state = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final resultsAsync = ref.watch(userSearchResultsProvider);
    final query = ref.watch(userSearchQueryProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).userSearchTitle, style: Theme.of(context).textTheme.titleSmall),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: TextField(
                controller: _controller,
                autofocus: true,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context).userSearchHint,
                  hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                  prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textSecondary),
                  suffixIcon: _controller.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, color: AppColors.textSecondary),
                          onPressed: () {
                            _controller.clear();
                            _onChanged('');
                          },
                        )
                      : null,
                ),
                onChanged: _onChanged,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: resultsAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.accent),
                ),
                error: (err, stack) => Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      AppLocalizations.of(context).userSearchFailed,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.error),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                data: (results) {
                  if (query.trim().isEmpty) {
                    return _buildMessage(
                      icon: Icons.person_search_rounded,
                      title: AppLocalizations.of(context).userSearchTitle,
                      subtitle: AppLocalizations.of(context).userSearchPrompt,
                    );
                  }
                  if (results.isEmpty) {
                    return _buildMessage(
                      icon: Icons.search_off_rounded,
                      title: AppLocalizations.of(context).userSearchNotFound,
                      subtitle: AppLocalizations.of(context).userSearchNoMatch(query),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: results.length,
                    itemBuilder: (context, index) => UserSearchResultTile(user: results[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessage({required IconData icon, required String title, required String subtitle}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: AppColors.textSecondary.withValues(alpha: 0.5)),
          const SizedBox(height: 12),
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
