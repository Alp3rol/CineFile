import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/tmdb_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/premium_toast.dart';
import '../../domain/graph_models.dart';
import '../graph_overrides_provider.dart';

/// Bottom sheet to manually attach a person (searched on TMDb) to a watched
/// title — how the user fixes bridges TMDb missed (e.g. Halil Babür → Behzat
/// Ç.). Writes a graph override; the graph re-curates reactively.
class AddPersonSheet extends ConsumerStatefulWidget {
  final int tmdbId;
  final bool isTv;
  final String titleLabel;

  const AddPersonSheet({
    super.key,
    required this.tmdbId,
    required this.isTv,
    required this.titleLabel,
  });

  static void show(
    BuildContext context, {
    required int tmdbId,
    required bool isTv,
    required String titleLabel,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (c) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(c).viewInsets.bottom),
        child: AddPersonSheet(
            tmdbId: tmdbId, isTv: isTv, titleLabel: titleLabel),
      ),
    );
  }

  @override
  ConsumerState<AddPersonSheet> createState() => _AddPersonSheetState();
}

class _AddPersonSheetState extends ConsumerState<AddPersonSheet> {
  final _controller = TextEditingController();
  Timer? _debounce;
  bool _loading = false;
  bool _asDirector = false;
  List<Map<String, dynamic>> _results = const [];
  int _reqId = 0;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String q) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () => _search(q));
  }

  Future<void> _search(String q) async {
    final query = q.trim();
    if (query.isEmpty) {
      setState(() {
        _results = const [];
        _loading = false;
      });
      return;
    }
    final req = ++_reqId;
    setState(() => _loading = true);
    try {
      final res = await ref.read(tmdbServiceProvider).searchPeople(query);
      if (!mounted || req != _reqId) return; // a newer query superseded this
      setState(() {
        _results = res;
        _loading = false;
      });
    } catch (_) {
      if (!mounted || req != _reqId) return;
      setState(() {
        _results = const [];
        _loading = false;
      });
    }
  }

  Future<void> _pick(Map<String, dynamic> person) async {
    final id = person['id'] as int?;
    final name = (person['name'] as String?)?.trim() ?? '';
    if (name.isEmpty) return;
    final credit = CreditPerson(
      id: id,
      name: name,
      profilePath: person['profile_path'] as String?,
      isDirector: _asDirector,
    );
    await ref
        .read(graphOverridesControllerProvider)
        .addPersonToTitle(widget.tmdbId, widget.isTv, credit);
    if (!mounted) return;
    Navigator.of(context).pop();
    showPremiumToast(context, '$name, "${widget.titleLabel}" yapımına eklendi.');
  }

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      borderRadius: 24,
      opacity: 0.92,
      padding: const EdgeInsets.all(20),
      child: ConstrainedBox(
        constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.75),
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
            Text('Kişi Ekle',
                style: Theme.of(context).textTheme.titleLarge),
            Text('"${widget.titleLabel}" yapımına bağlanacak kişiyi ara.',
                style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 14),
            TextField(
              controller: _controller,
              autofocus: true,
              onChanged: _onChanged,
              decoration: const InputDecoration(
                hintText: 'Oyuncu / yönetmen adı…',
                prefixIcon: Icon(Icons.search_rounded),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Text('Rol:',
                    style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                const SizedBox(width: 10),
                _roleChip('Oyuncu', !_asDirector, () => setState(() => _asDirector = false)),
                const SizedBox(width: 8),
                _roleChip('Yönetmen', _asDirector, () => setState(() => _asDirector = true)),
              ],
            ),
            const SizedBox(height: 12),
            Flexible(child: _resultsList()),
          ],
        ),
      ),
    );
  }

  Widget _roleChip(String label, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: active
              ? AppTheme.accentColor.withValues(alpha: 0.18)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: active ? AppTheme.accentColor : AppTheme.borderColor),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 12,
                color: active ? AppTheme.textPrimary : AppTheme.textSecondary)),
      ),
    );
  }

  Widget _resultsList() {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentColor),
          ),
        ),
      );
    }
    if (_results.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text('Aramak için yazmaya başla.',
              style: TextStyle(color: AppTheme.textSecondary)),
        ),
      );
    }
    return ListView.separated(
      shrinkWrap: true,
      itemCount: _results.length,
      separatorBuilder: (_, _) => const SizedBox(height: 4),
      itemBuilder: (context, i) {
        final p = _results[i];
        final path = p['profile_path'] as String?;
        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 40,
              height: 40,
              child: AppNetworkImage(
                imageUrl:
                    path == null ? '' : '${ApiConstants.imagePathW185}$path',
                seed: (p['name'] as String?) ?? '',
              ),
            ),
          ),
          title: Text((p['name'] as String?) ?? '',
              style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14)),
          subtitle: (p['known_for_department'] as String?) == null
              ? null
              : Text(p['known_for_department'] as String,
                  style: const TextStyle(
                      color: AppTheme.textSecondary, fontSize: 12)),
          trailing: const Icon(Icons.add_circle_outline_rounded,
              color: AppTheme.accentColor),
          onTap: () => _pick(p),
        );
      },
    );
  }
}
