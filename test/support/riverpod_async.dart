// Riverpod 3 pauses any provider that has no listeners. On a bare
// ProviderContainer (no widget tree subscribing to anything) that means
// `await container.read(someAsyncProvider.future)` hangs forever: the
// provider is created, but its stream/future is never actually subscribed
// to, so the `.future` never completes and the test times out. Under
// Riverpod 2 the same call resolved, which is why this helper only became
// necessary with the 3.x upgrade.
//
// Holding a subscription while awaiting keeps the provider active. The
// subscription intentionally outlives the call — it is released when the
// container is disposed at the end of the test.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';

/// Awaits an async provider's first value on a listener-less [container].
///
/// Use instead of `container.read(provider.future)`:
///
/// ```dart
/// await readAsync(container, authStateProvider.future);
/// ```
Future<T> readAsync<T>(ProviderContainer container, Refreshable<Future<T>> future) {
  return container.listen(future, (_, _) {}).read();
}
