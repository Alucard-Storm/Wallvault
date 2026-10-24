// Regression test for a race in WallpaperProvider.loadWallpapers: a filter
// change that fires while an earlier request is still in flight must not let
// that earlier request's results land after the newer one's, mixing two
// different filters' wallpapers into one list.
import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:wallvault/models/wallpaper.dart';
import 'package:wallvault/providers/wallpaper_provider.dart';
import 'package:wallvault/services/wallhaven_api.dart';

Wallpaper _fakeWallpaper(String id) {
  return Wallpaper(
    id: id,
    url: 'https://wallhaven.cc/w/$id',
    shortUrl: 'https://whvn.cc/$id',
    views: 0,
    favorites: 0,
    source: '',
    purity: 'sfw',
    category: 'general',
    dimensionX: 1920,
    dimensionY: 1080,
    resolution: '1920x1080',
    ratio: '1.78',
    fileSize: 0,
    fileType: 'image/png',
    createdAt: DateTime(2024),
    colors: const [],
    path: 'https://wallhaven.cc/full/$id.png',
    thumbs: 'https://wallhaven.cc/thumb/$id.png',
    tags: const [],
  );
}

/// A fake [WallhavenApi] whose [getWallpapers] calls don't resolve until the
/// test explicitly completes them, so the test can control which request
/// "finishes" first regardless of call order.
class _ControlledWallhavenApi extends WallhavenApi {
  final List<Completer<List<Wallpaper>>> requests = [];

  @override
  Future<List<Wallpaper>> getWallpapers({
    int page = 1,
    String? categories,
    String? purity,
    String? sorting,
    String? order,
    String? topRange,
    String? atleast,
    String? resolutions,
    String? ratios,
    String? colors,
    String? apiKey,
  }) {
    final completer = Completer<List<Wallpaper>>();
    requests.add(completer);
    return completer.future;
  }
}

void main() {
  test(
    'a filter change discards an earlier in-flight request instead of '
    'merging its stale results',
    () async {
      final api = _ControlledWallhavenApi();
      final provider = WallpaperProvider(api: api);

      // Start the first request (e.g. the initial feed load).
      unawaited(provider.loadWallpapers(refresh: true));
      // Before it resolves, the user changes a filter, starting a second,
      // superseding request.
      provider.updateFilters(categories: 'anime');

      expect(api.requests, hasLength(2));

      // The newer request resolves first.
      api.requests[1].complete([_fakeWallpaper('new-result')]);
      await Future.microtask(() {});

      expect(provider.wallpapers.map((w) => w.id), ['new-result']);
      expect(provider.isLoading, isFalse);

      // The stale first request resolves late; its result must be ignored.
      api.requests[0].complete([_fakeWallpaper('stale-result')]);
      await Future.microtask(() {});

      expect(provider.wallpapers.map((w) => w.id), ['new-result']);
    },
  );
}
